class_name TaxiLocation
extends Node3D

# TODO: Eliminate this class / scene and make a common 'TaxiLocation' class / scene that can be either a pickup OR destination?
# Or have a base class that both inherit from, so you can still place both on the map individually.
# Base class would have the collision signalling + logic, derived classes would just change the mesh appareance / color

signal area_entered(body: Node3D)
signal area_exited(body: Node3D)

@onready var area3D:Area3D = get_node("Area3D")
@onready var mesh_instance:MeshInstance3D = get_node("MeshInstance3D")

static var pickup_material:StandardMaterial3D
static var dropoff_material:StandardMaterial3D

enum LocationType {
	PICKUP,
	DROPOFF
}
var location_type:LocationType = LocationType.PICKUP:
	set(val):
		location_type=val
		match location_type:
			LocationType.PICKUP:
				if pickup_material == null:
					pickup_material = mesh_instance.material_override.duplicate()
					pickup_material.albedo_color = Color(0.0, 0.827, 0.976, 0.745)
				mesh_instance.material_override = pickup_material
				print(name, " loc type set to pickup")
			LocationType.DROPOFF:
				if dropoff_material == null:
					dropoff_material = mesh_instance.material_override.duplicate()
					dropoff_material.albedo_color = Color(0.749, 0.785, 0.0, 0.745)
				mesh_instance.material_override = dropoff_material
				print(name, " loc type set to dropoff")

@export var pickup:bool = true:
	set(val):
		pickup = val
		if pickup:
			add_to_group("pickups")
		else:
			remove_from_group("pickups")
@export var dropoff:bool = true:
	set(val):
		dropoff = val
		if dropoff:
			add_to_group("dropoffs")
		else:
			remove_from_group("dropoffs")

func _ready() -> void:
	if pickup:
		add_to_group("pickups")
	if dropoff:
		add_to_group("dropoffs")
	visible=false

func _on_area_3d_body_entered(body: Node3D) -> void:
	area_entered.emit(body)
	
func is_body_in_area(body: Node3D) -> bool:
	return area3D.overlaps_body(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	area_exited.emit(body)
