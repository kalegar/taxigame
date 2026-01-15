class_name PlayerVehicle
extends VehicleBody3D

signal door_open_close(index:int,open:bool)

var cam_first_person
var cam_3rd_person
var cam_rearview
var door_right : MeshInstance3D
var door_left : MeshInstance3D
var steering_wheel : MeshInstance3D
var steering_wheel_zero_basis
var spedometer : MeshInstance3D
var spedometer_zero_basis
var rpm_meter : MeshInstance3D
var rpm_zero_basis
var rpm_angle
var door_positions_left : Array
var door_positions_right : Array
var door_position_indexes : Array
var mirror:Mirror3D
var wheel_front_right : VehicleWheel3D
var wheel_front_left : VehicleWheel3D
var wheel_rear_right : VehicleWheel3D
var wheel_rear_left : VehicleWheel3D
var nav_arrow : MeshInstance3D
var current_job : TaxiJob:
	set(val):
		current_job = val
		if current_job != null:
			passenger.apply_job(current_job)
var passenger : Passenger
var path:PackedVector3Array = PackedVector3Array()
var nodes:Array[Node3D]

const MAX_STEER =  0.32
const MAX_RPM = 675
const MAX_TORQUE = 1500
const BRAKE_POWER = 35.0
const RPM_MAX_ANGLE = deg_to_rad(180)

func _ready():
	cam_first_person = get_node("CameraFirstPerson")
	cam_3rd_person = get_node("Camera3rdPerson")
	cam_rearview = get_node("CameraRearview")
	door_right = get_node("Door Right")
	door_left = get_node("Door Left")
	steering_wheel = get_node("Steering Wheel")
	spedometer = get_node("Spedometer Needle")
	rpm_meter = get_node("RPM Needle")
	mirror = get_node("Mirror3D")
	passenger = get_node("Passenger")
	wheel_front_right = get_node("WheelFrontRight")
	wheel_front_left = get_node("WheelFrontLeft")
	wheel_rear_right = get_node("WheelRearRight")
	wheel_rear_left = get_node("WheelRearLeft")
	nav_arrow = get_node("Arrow")
	rpm_zero_basis = rpm_meter.basis
	rpm_angle = 0
	steering_wheel_zero_basis = steering_wheel.basis
	spedometer_zero_basis = spedometer.basis
	door_positions_left = [door_left.transform.basis, door_left.transform.basis.rotated(Vector3(0,1,0), -0.9)]
	door_positions_right = [door_right.transform.basis, door_right.transform.basis.rotated(Vector3(0,1,0), .9)]
	door_position_indexes = [0,0]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func is_flipped() -> bool:
	return transform.basis.y.dot(Vector3.UP) < 0
	
func is_stuck() -> bool:
	var wheels:Array[VehicleWheel3D] = [wheel_front_right,wheel_front_left,wheel_rear_left,wheel_rear_right]
	var any_contacting = false
	for wheel in wheels:
		if wheel.is_in_contact():
			any_contacting = true
			break
	return linear_velocity.length_squared() < 1 and not any_contacting
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("action_unstuck"):
		# TODO: Implement "tow truck" or similar that respawns you at a nearby point.
		apply_central_force(Vector3(0,5000,0))
	
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("action_steer_right", "action_steer_left") * MAX_STEER, delta * 2.0)
	
	var RPM_left = abs(wheel_rear_left.get_rpm())
	var RPM_right = abs(wheel_rear_right.get_rpm())
	var RPM = (RPM_left + RPM_right) / 2.0
	var torque = Input.get_axis("action_decelerate", "action_accelerate") * (1.0 - RPM / MAX_RPM) * MAX_TORQUE
	engine_force = torque
	
	brake = float(Input.is_action_pressed("action_brake")) * BRAKE_POWER
	spedometer.basis = spedometer_zero_basis.rotated(Vector3(0,0,1),linear_velocity.length()*0.1)
	steering_wheel.basis = steering_wheel_zero_basis.rotated(Vector3(0,-.2,.8).normalized(),-steering*2.5)
	var angle_target = engine_force*.02 / RPM_MAX_ANGLE
	rpm_angle = move_toward(rpm_angle, angle_target, delta*3)
	rpm_meter.basis = rpm_zero_basis.rotated(Vector3(0,0,1),abs(rpm_angle))
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("action_change_view"):
		if cam_first_person.current:
			cam_3rd_person.current = true
		else:
			cam_first_person.current = true
			
	if Input.is_action_just_pressed("action_rearview"):
		if cam_rearview.current:
			cam_first_person.current = true
		else:
			cam_rearview.current = true
		
	if Input.is_action_just_pressed("action_open_doors"):
		toggle_door(1)
		
	if path != null and path.size() > 1:
		var dist = INF
		var closest = path[path.size()-1]
		for i in range(1, path.size()):
			var node = path[i]
			var d = node.distance_squared_to(global_position)
			if d < 20:
				continue
			if d < dist:
				dist = d
				closest = node
				
		closest.y += 1
		var old = nav_arrow.rotation
		nav_arrow.look_at(closest, Vector3.UP, true)
		var new = nav_arrow.rotation
		nav_arrow.rotation = lerp(old, new, .1)
		
		#var node_scene : Resource = load("res://Scenes/nav_path_node.tscn")
		#for node in nodes:
			#node.queue_free()
		#nodes.clear()
		
		#for i in range(1, path.size()):
			#var node = path[i]
			##print("Created node at ",node)
			#var instance : Node3D = node_scene.instantiate()
			#add_child(instance)
			#instance.global_position = node
			#instance.global_position.y += 2
			#if node == closest:
				#instance.global_position.y -= 1
			#nodes.append(instance)

func toggle_door(index:int) -> void:
	if is_door_open(index):
		close_door(index)
	else:
		open_door(index)

func is_door_open(index:int) -> bool:
	return door_position_indexes[index] == 1

func open_door(index:int) -> void:
	door_position_indexes[index] = 1
	door_left.basis = door_positions_left[door_position_indexes[0]]
	door_right.basis = door_positions_right[door_position_indexes[1]]
	door_open_close.emit(index,true)
	
func close_door(index:int) -> void:
	door_position_indexes[index] = 0
	door_left.basis = door_positions_left[door_position_indexes[1]]
	door_right.basis = door_positions_right[door_position_indexes[1]]
	door_open_close.emit(index,false)

func get_navigation_path(start:Vector3, end:Vector3) -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()
	
	var default_map_rid: RID = get_world_3d().get_navigation_map()
	return NavigationServer3D.map_get_path(
		default_map_rid,
		start,
		end,
		true
	)
	
func navigate_to_next_location() -> void:
	if passenger == null:
		return
	var start : Vector3 = global_position
	var end : Vector3 = Vector3(0,0,0)
	if passenger.pickup != null and passenger.pickup.visible:
		end = passenger.pickup.global_position
	elif passenger.destination != null and passenger.destination.visible:
		end = passenger.destination.global_position
	else:
		print("No pickup or dest!")
		return
	path = get_navigation_path(start,end)

func _on_passenger_dropoff_timer_started() -> void:
	open_door(1)

func _on_passenger_pickup_timer_started() -> void:
	open_door(1)

func _on_passenger_passenger_picked_up(_success: bool) -> void:
	close_door(1)

func _on_passenger_passenger_dropped_off(success: bool) -> void:
	close_door(1)
	if success:
		current_job = null


func _on_nav_timer_timeout() -> void:
	navigate_to_next_location()
