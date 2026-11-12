@tool
extends SceneTree

func _init():
	print("=== Upgrading Nature Kit Models with Realistic Materials ===")
	_upgrade_pine_tree("res://assets/nature_kit/scn/tree_pine_tall.scn")
	_upgrade_pine_tree("res://assets/nature_kit/scn/tree_pine_round.scn")
	_upgrade_bush("res://assets/nature_kit/scn/bush_detailed.scn")
	_upgrade_rock("res://assets/nature_kit/scn/rock_large.scn")
	_upgrade_rock("res://assets/nature_kit/scn/rock_tall.scn")
	print("=== Nature Kit Upgrade Complete ===")
	quit(0)

func _upgrade_pine_tree(scn_path: String):
	if not FileAccess.file_exists(scn_path):
		return
	var scn = load(scn_path)
	var inst = scn.instantiate()
	
	# PBR Bark material
	var bark_mat = StandardMaterial3D.new()
	bark_mat.resource_name = "mat_realistic_pine_bark"
	bark_mat.albedo_color = Color(0.24, 0.16, 0.10, 1.0) # Deep weathered pine bark brown
	bark_mat.roughness = 0.94
	bark_mat.metallic_specular = 0.05
	
	# PBR Evergreen Pine Needles material
	var leaf_mat = StandardMaterial3D.new()
	leaf_mat.resource_name = "mat_realistic_pine_needles"
	leaf_mat.albedo_color = Color(0.13, 0.34, 0.15, 1.0) # Authentic alpine evergreen green
	leaf_mat.roughness = 0.85
	leaf_mat.metallic_specular = 0.10
	leaf_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	for c in inst.get_children():
		if c is MeshInstance3D and c.mesh:
			var m = c.mesh
			for s in range(m.get_surface_count()):
				var orig = m.surface_get_material(s)
				if orig and ("wood" in orig.resource_name.to_lower() or "bark" in orig.resource_name.to_lower()):
					m.surface_set_material(s, bark_mat)
				elif orig and ("leaf" in orig.resource_name.to_lower() or "dark" in orig.resource_name.to_lower()):
					m.surface_set_material(s, leaf_mat)
				else:
					# Surface 0 is trunk, Surface 1 is leaves
					if s == 0:
						m.surface_set_material(s, bark_mat)
					else:
						m.surface_set_material(s, leaf_mat)
	
	var pack = PackedScene.new()
	pack.pack(inst)
	ResourceSaver.save(pack, scn_path, ResourceSaver.FLAG_COMPRESS)
	print("✓ Upgraded & Saved: ", scn_path)
	inst.free()

func _upgrade_bush(scn_path: String):
	if not FileAccess.file_exists(scn_path):
		return
	var scn = load(scn_path)
	var inst = scn.instantiate()
	
	var bush_mat = StandardMaterial3D.new()
	bush_mat.resource_name = "mat_realistic_bush_foliage"
	bush_mat.albedo_color = Color(0.18, 0.44, 0.18, 1.0) # Rich natural shrub foliage
	bush_mat.roughness = 0.88
	bush_mat.metallic_specular = 0.08
	bush_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	for c in inst.get_children():
		if c is MeshInstance3D and c.mesh:
			var m = c.mesh
			for s in range(m.get_surface_count()):
				m.surface_set_material(s, bush_mat)
				
	var pack = PackedScene.new()
	pack.pack(inst)
	ResourceSaver.save(pack, scn_path, ResourceSaver.FLAG_COMPRESS)
	print("✓ Upgraded & Saved: ", scn_path)
	inst.free()

func _upgrade_rock(scn_path: String):
	if not FileAccess.file_exists(scn_path):
		return
	var scn = load(scn_path)
	var inst = scn.instantiate()
	
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	for c in inst.get_children():
		if c is MeshInstance3D and c.mesh:
			var m = c.mesh
			for s in range(m.get_surface_count()):
				m.surface_set_material(s, cliff_mat)
				
	var pack = PackedScene.new()
	pack.pack(inst)
	ResourceSaver.save(pack, scn_path, ResourceSaver.FLAG_COMPRESS)
	print("✓ Upgraded & Saved: ", scn_path)
	inst.free()
