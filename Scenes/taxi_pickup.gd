class_name TaxiPickup
extends Node3D

# TODO: Eliminate this class / scene and make a common 'TaxiLocation' class / scene that can be either a pickup OR destination?
# Or have a base class that both inherit from, so you can still place both on the map individually.
# Base class would have the collision signalling + logic, derived classes would just change the mesh appareance / color

signal area_entered(body: Node3D)

@onready var area3D:Area3D = get_node("Area3D")

func _ready() -> void:
	add_to_group("pickups")
	visible=false

func _on_area_3d_body_entered(body: Node3D) -> void:
	area_entered.emit(body)
	
func is_body_in_area(body: Node3D) -> bool:
	return area3D.overlaps_body(body)
