extends VehicleBody3D

var cam_first_person
var cam_3rd_person
const MAX_STEER =  0.3
const ENGINE_POWER = 200

func _ready():
	cam_first_person = get_node("CameraFirstPerson")
	cam_3rd_person = get_node("Camera3rdPerson")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("ui_accept"):
		cam_first_person.current = !cam_first_person.current
