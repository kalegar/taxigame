extends Node3D

@export var pickup:Node3D
@export var destination:Node3D

var path : PackedVector3Array = PackedVector3Array()
var nodes : Array[Node3D] = []

func get_navigation_path() -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()
	
	var default_map_rid: RID = get_world_3d().get_navigation_map()
	return NavigationServer3D.map_get_path(
		default_map_rid,
		pickup.position,
		destination.position,
		true
	)
	
func gen_and_draw_path():
	for node in nodes:
		node.queue_free()
	nodes.clear()
	if pickup != null and destination != null:
		path = get_navigation_path()
		print("Path length: ",path.size())
		var node_scene : Resource = load("res://Scenes/nav_path_node.tscn")
		for node in path:
			print("Created node at ",node)
			var instance : Node3D = node_scene.instantiate()
			add_child(instance)
			instance.global_position = node
			instance.global_position.y += 2
			nodes.append(instance)
	else:
		print("pickup or dest is null")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action_brake"):
		gen_and_draw_path()
