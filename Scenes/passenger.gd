class_name Passenger
extends Node3D

signal pickup_timer_started
signal dropoff_timer_started
signal passenger_picked_up(success:bool)
signal passenger_dropped_off(success:bool)

@export var taxi_job:TaxiJob
@export var pickup:TaxiLocation
@export var destination:TaxiLocation
@export var passenger_scene:PackedScene
@export var player:PlayerVehicle:
	set(val):
		if player != null:
			player.door_open_close.disconnect(_on_player_door_toggle)
		player = val
		player.door_open_close.connect(_on_player_door_toggle)
@onready var timer_pickup:Timer = get_node("TimerPickup")
@onready var timer_dropoff:Timer = get_node("TimerDropoff")
var scene:Node
var picked_up:bool = false

func _on_player_door_toggle(index:int,open:bool) -> void:
	if index == 1:
		pass

func _on_pickup_area_entered(_body:Node3D) -> void:
	if picked_up:
		return
	timer_pickup.start()
	pickup_timer_started.emit()
	
func _on_destination_area_entered(_body:Node3D) -> void:
	if !picked_up:
		return
	timer_dropoff.start()
	dropoff_timer_started.emit()

func apply_job(job:TaxiJob) -> void:
	passenger_scene = job.passenger_scenes.pick_random()
	if scene != null:
		scene.queue_free()
	scene = passenger_scene.instantiate()
	scene.visible = false
	add_child(scene)
	print("Scene: ",scene.name)
	
	var pickups = get_tree().get_nodes_in_group("pickups")
	var destinations = get_tree().get_nodes_in_group("dropoffs")
	var dist:float = INF
	var tries_remaining:int = 32
	while tries_remaining > 0 and (dist < job.distance_min or dist > job.distance_max):
		tries_remaining -= 1
		pickup = (pickups.pick_random() as TaxiLocation)
		pickup.location_type = TaxiLocation.LocationType.PICKUP
		destination = (destinations.pick_random() as TaxiLocation)
		destination.location_type = TaxiLocation.LocationType.DROPOFF
		if pickup == destination:
			continue
		dist = pickup.global_position.distance_to(destination.global_position) # TODO: Generate navmesh path and test that length rather than point to point distance?
	
	if dist < job.distance_min or dist > job.distance_max:
		print("Failed to find pickup and destination in range!", dist, " ", job.distance_min, " ", job.distance_max)
	else:
		pickup.visible = true
		pickup.area_entered.connect(_on_pickup_area_entered)
		destination.area_entered.connect(_on_destination_area_entered)

func _ready() -> void:
	if taxi_job != null:
		apply_job(taxi_job)

func _process(_delta: float) -> void:
	if scene != null:
		scene.visible = picked_up

func _on_timer_pickup_timeout() -> void:
	timer_pickup.stop()
	if pickup.is_body_in_area(get_parent_node_3d()):
		picked_up = true
		pickup.visible = false
		destination.visible = true
		passenger_picked_up.emit(true)
		print("Passenger picked up!")
	else:
		passenger_picked_up.emit(false)

func _on_timer_dropoff_timeout() -> void:
	timer_dropoff.stop()
	if destination.is_body_in_area(get_parent_node_3d()):
		if not picked_up or not destination.visible:
			print("not picked up or not visible")
			return
		destination.visible = false
		pickup.visible = false
		picked_up = false
		passenger_dropped_off.emit(true)
		print("Passenger delivered!")
	else:
		passenger_picked_up.emit(false)
