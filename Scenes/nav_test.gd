extends Node3D

@export var player:PlayerVehicle

var path : PackedVector3Array = PackedVector3Array()
var nodes : Array[Node3D] = []

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
	
func gen_and_draw_path():
	for node in nodes:
		node.queue_free()
	nodes.clear()
	if player != null:
		var start : Vector3 = player.global_position
		var end : Vector3 = Vector3(0,0,0)
		if player.passenger.pickup != null and player.passenger.pickup.visible:
			end = player.passenger.pickup.global_position
		elif player.passenger.destination != null and player.passenger.destination.visible:
			end = player.passenger.destination.global_position
		else:
			print("No pickup or dest!")
			return
		path = get_navigation_path(start,end)
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
