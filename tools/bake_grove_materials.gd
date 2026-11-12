extends SceneTree

func _init():
	var s = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	var inst = s.instantiate()
	var alpha_mats = ["mat_002", "mat_012", "mat_054", "mat_068", "mat_069", "mat_070", "mat_071", "mat_072", "mat_075", "mat_083", "mat_089"]
	for mi in inst.find_children("*", "MeshInstance3D"):
		var mesh = mi.mesh
		if mesh:
			for s_idx in range(mesh.get_surface_count()):
				var mat = mi.get_active_material(s_idx)
				if mat is StandardMaterial3D:
					mat.roughness = 0.82
					mat.metallic = 0.05
					if mat.resource_name in alpha_mats:
						mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
						mat.alpha_scissor_threshold = 0.5
						mat.cull_mode = BaseMaterial3D.CULL_DISABLED
						print("Configured alpha scissor for: ", mat.resource_name)
					else:
						mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	var packed = PackedScene.new()
	packed.pack(inst)
	ResourceSaver.save(packed, "res://scenes/environments/GTAGroveStreetDirect.tscn")
	print("Baked and saved GTAGroveStreetDirect.tscn successfully!")
	inst.free()
	quit(0)
