extends SceneTree

func _init():
	var s = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = s.instantiate()
	var mats = {}
	for mi in inst.find_children("*", "MeshInstance3D"):
		var mesh = mi.mesh
		if mesh:
			for s_idx in range(mesh.get_surface_count()):
				var mat = mi.get_active_material(s_idx)
				if mat is StandardMaterial3D and mat.albedo_texture:
					var m_name = mat.resource_name
					var tex = mat.albedo_texture
					var has_alpha = tex.get_image().has_alpha() if tex.get_image() else false
					mats[m_name] = {"has_alpha": has_alpha, "tex": tex.resource_path if tex else ""}
	print("Materials found: ", mats.size())
	for k in mats:
		if mats[k]["has_alpha"]:
			print("ALPHA MATERIAL: ", k, " -> ", mats[k])
	inst.free()
	quit(0)
