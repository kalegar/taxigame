class_name TaxiDestination
extends Node3D

signal area_entered(body:Node3D)

@onready var area3D:Area3D = get_node("Area3D")

func _ready() -> void:
	add_to_group("destinations")
	visible = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	area_entered.emit(body) # Replace with function body.

func is_body_in_area(body: Node3D) -> bool:
	return area3D.overlaps_body(body)
