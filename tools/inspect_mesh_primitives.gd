extends SceneTree

func _init():
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	get_root().add_child(level)
	
	var mesh_instances = level.find_children("*", "MeshInstance3D", true, false)
	print("Total MeshInstance3Ds: ", mesh_instances.size())
	
	var list = []
	for mi in mesh_instances:
		if mi.mesh:
			var tris = 0
			for s in range(mi.mesh.get_surface_count()):
				var arrs = mi.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_INDEX and arrs[Mesh.ARRAY_INDEX] != null:
					tris += arrs[Mesh.ARRAY_INDEX].size() / 3
				elif arrs.size() > Mesh.ARRAY_VERTEX and arrs[Mesh.ARRAY_VERTEX] != null:
					tris += arrs[Mesh.ARRAY_VERTEX].size() / 3
			list.append({"name": mi.name, "parent": mi.get_parent().name, "path": mi.get_path(), "tris": tris})
			
	list.sort_custom(func(a, b): return a["tris"] > b["tris"])
	print("--- TOP 10 HEAVIEST MESHES BY TRIANGLE COUNT ---")
	for i in range(mini(15, list.size())):
		print("#", i+1, " ", list[i]["name"], " (parent: ", list[i]["parent"], ") -> ", list[i]["tris"], " triangles [", list[i]["path"], "]")
		
	quit(0)
