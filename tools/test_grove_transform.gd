
extends SceneTree
func _init():
	var scn = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = scn.instantiate()
	var mesh_inst = inst.get_node("Grove_Clean") as MeshInstance3D
	var mesh = mesh_inst.mesh as ArrayMesh
	var scale_factor = 2.4
	var offset = Vector3(-5.74, 1.38, 0.75)
	
	var near_pts = []
	for i in range(mesh.get_surface_count()):
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(mesh, i)
		for v in range(mdt.get_vertex_count()):
			var p = mesh_inst.transform * mdt.get_vertex(v)
			var wp = p * scale_factor + offset
			if abs(wp.x) < 4.0 and abs(wp.z) < 4.0:
				near_pts.append(wp)
	print("Vertices within 4m of (0,0): count=", near_pts.size())
	if near_pts.size() > 0:
		var min_y = 999.0
		var max_y = -999.0
		var sum_y = 0.0
		for p in near_pts:
			if p.y < min_y: min_y = p.y
			if p.y > max_y: max_y = p.y
			sum_y += p.y
		print("Y Range near (0,0): [", min_y, ", ", max_y, "] Avg Y=", sum_y / near_pts.size())
	quit(0)
