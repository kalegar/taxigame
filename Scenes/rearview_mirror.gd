extends Node3D

@export var global_camera : Camera3D
@onready var camera : Camera3D = get_node("SubViewport/Camera3D")

func _process(delta: float) -> void:
	if global_camera != null:
		camera.global_transform = Transform3D(global_camera.global_transform)
