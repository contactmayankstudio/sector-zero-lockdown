extends SceneTree

func _init():
	var s = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = s.instantiate()
	var count = 0
	for mi in inst.find_children("*", "MeshInstance3D"):
		var mesh = mi.mesh
		if mesh:
			for s_idx in range(mesh.get_surface_count()):
				var mat = mi.get_active_material(s_idx)
				if mat is StandardMaterial3D and mat.albedo_texture:
					var img = mat.albedo_texture.get_image()
					if img and img.detect_alpha() != Image.ALPHA_NONE:
						count += 1
						print("Alpha surface found: ", mat.resource_name, " mesh: ", mi.name)
	print("Total alpha surfaces found: ", count)
	inst.free()
	quit(0)
