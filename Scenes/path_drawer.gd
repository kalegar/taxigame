class_name PathDrawer
extends Node3D

@export var path:PackedVector3Array:
	set(val):
		path=val
		rebuild_mesh()

var meshes:Array[MeshInstance3D]
static var mat : StandardMaterial3D

func _process(delta: float) -> void:
	global_position = Vector3.ZERO
	global_rotation = Vector3.ZERO
	if path != null:
		if meshes == null or meshes.size() == 0:
			rebuild_mesh()
			
func get_mat() -> StandardMaterial3D:
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1.474, 0.195, 0.125, 1.0)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat
			
func rebuild_mesh() -> void:
	#for mesh in meshes:
		#mesh.queue_free()
	#meshes.clear()
	if path.size() < 2:
		return
	for i in range(path.size()-1):
		var start : Vector3 = path[i]
		var end : Vector3 = path[i+1]
		
		
		var cyl_mesh : CylinderMesh = CylinderMesh.new()
		cyl_mesh.radial_segments = 3
		var length = (end-start).length()
		cyl_mesh.height = length
		cyl_mesh.top_radius = 2
		cyl_mesh.bottom_radius = 2
		
		var cyl_array = cyl_mesh.get_mesh_arrays()
		for n in range(0, cyl_array[0].size()):
			cyl_array[ArrayMesh.ARRAY_VERTEX][n] -= Vector3(0,length/2.0,0)
			cyl_array[ArrayMesh.ARRAY_VERTEX][n] = cyl_array[ArrayMesh.ARRAY_VERTEX][n].rotated(Vector3.RIGHT, PI/2.0)
			cyl_array[ArrayMesh.ARRAY_NORMAL][n] = cyl_array[ArrayMesh.ARRAY_NORMAL][n].rotated(Vector3.RIGHT, PI/2.0)
		
		var arr_mesh = ArrayMesh.new()
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, cyl_array)
		
		var cyl_inst : MeshInstance3D
		if i < meshes.size():
			cyl_inst = meshes[i]
		else:
			cyl_inst = MeshInstance3D.new()
			add_child(cyl_inst)
			meshes.append(cyl_inst)
		
		cyl_inst.mesh = arr_mesh
		cyl_inst.position = start
		cyl_inst.look_at(end, Vector3.UP)
		cyl_inst.mesh.surface_set_material(0,get_mat())
		cyl_inst.set_layer_mask_value(1,false)
		cyl_inst.set_layer_mask_value(19,true)
		
	for i in range(path.size()-1, meshes.size()):
		meshes[i].queue_free()

	meshes.resize(path.size()-1)
	
