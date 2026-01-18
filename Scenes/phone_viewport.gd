extends Node3D

@onready var camera : Camera3D = get_node("PhoneSubViewport/PhoneCamera")

var orig_basis : Basis

func _ready() -> void:
	orig_basis = camera.basis

func _process(_delta: float) -> void:
	camera.basis = orig_basis
	camera.global_position = global_position
	camera.global_position.y += 20
	camera.rotation = rotation
