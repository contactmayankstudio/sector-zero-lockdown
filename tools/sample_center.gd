
extends SceneTree
func _init():
	var scn = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = scn.instantiate()
	var mesh_inst = inst.get_node("Grove_Clean") as MeshInstance3D
	var mesh = mesh_inst.mesh as ArrayMesh
	print("AABB: ", mesh.get_aabb())
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	var count = mdt.get_vertex_count()
	print("Surface 0 vertex count: ", count)
	var near_center = []
	for i in range(mesh.get_surface_count()):
		var mdt_surf = MeshDataTool.new()
		mdt_surf.create_from_surface(mesh, i)
		for v in range(mdt_surf.get_vertex_count()):
			var p = mdt_surf.get_vertex(v)
			# Apply Grove_Clean local transform: Transform3D(1, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0)
			var wp = mesh_inst.transform * p
			if abs(wp.x) < 5.0 and abs(wp.z) < 5.0:
				near_center.append(wp)
	print("Found near center count: ", near_center.size())
	if near_center.size() > 0:
		var sum_y = 0.0
		var min_y = 999.0
		var max_y = -999.0
		for p in near_center:
			sum_y += p.y
			if p.y < min_y: min_y = p.y
			if p.y > max_y: max_y = p.y
		print("Near center Y: min=", min_y, " max=", max_y, " avg=", sum_y / near_center.size())
		print("Sample points near center: ", near_center.slice(0, 8))
	quit(0)
