
extends SceneTree
func _init():
	var scn = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = scn.instantiate()
	var mesh_inst = inst.get_node("Grove_Clean") as MeshInstance3D
	var mesh = mesh_inst.mesh as ArrayMesh
	var min_p = Vector3(99999, 99999, 99999)
	var max_p = Vector3(-99999, -99999, -99999)
	for i in range(mesh.get_surface_count()):
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(mesh, i)
		for v in range(mdt.get_vertex_count()):
			var p = mesh_inst.transform * mdt.get_vertex(v)
			min_p.x = min(min_p.x, p.x)
			min_p.y = min(min_p.y, p.y)
			min_p.z = min(min_p.z, p.z)
			max_p.x = max(max_p.x, p.x)
			max_p.y = max(max_p.y, p.y)
			max_p.z = max(max_p.z, p.z)
	print("Transformed Mesh Bounds:")
	print("Min: ", min_p)
	print("Max: ", max_p)
	print("Center: ", (min_p + max_p) * 0.5)
	print("Size: ", max_p - min_p)
	quit(0)
