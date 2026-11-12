extends SceneTree

func _init():
	print("--- CALIBRATING WEAPON BARREL ORIENTATIONS ---")
	var weapons_to_fix = [
		"negev_ng7",
		"akx_scifi",
		"rocket_launcher",
		"pestilence_handgun",
		"arcade_gun",
		"prowl_blaster",
		"vaccinator_energy",
		"axon_cannon"
	]
	
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	
	for cfg in cfgs:
		if not cfg.id in weapons_to_fix:
			continue
			
		var res = load(cfg.model)
		if not (res is PackedScene):
			continue
			
		print("\nCALIBRATING: ", cfg.id)
		# Test rotations of (rx, ry, rz) in multiples of 90 degrees
		var best_rot = Vector3.ZERO
		var best_z_ratio = -999.0
		
		for rx in [-90, 0, 90, 180]:
			for ry in [-90, 0, 90, 180]:
				for rz in [-90, 0, 90, 180]:
					var inst = res.instantiate()
					inst.rotation_degrees = Vector3(rx, ry, rz)
					var meshes = inst.find_children("*", "MeshInstance3D", true, false)
					var min_pt = Vector3(999, 999, 999)
					var max_pt = Vector3(-999, -999, -999)
					for m in meshes:
						if m.mesh:
							var m_aabb = (inst.transform * m.transform) * m.mesh.get_aabb()
							min_pt.x = min(min_pt.x, m_aabb.position.x)
							min_pt.y = min(min_pt.y, m_aabb.position.y)
							min_pt.z = min(min_pt.z, m_aabb.position.z)
							max_pt.x = max(max_pt.x, m_aabb.end.x)
							max_pt.y = max(max_pt.y, m_aabb.end.y)
							max_pt.z = max(max_pt.z, m_aabb.end.z)
					var sz = max_pt - min_pt
					# We want Z to be largest (length of gun), Y to be 2nd largest (height), X to be smallest (thickness)
					if sz.z > sz.x and sz.z > sz.y and sz.y >= sz.x:
						var score = sz.z / (sz.x + 0.001) + sz.y / (sz.x + 0.001)
						if score > best_z_ratio:
							best_z_ratio = score
							best_rot = Vector3(rx, ry, rz)
					inst.free()
					
		print("  => Best Rot: ", best_rot, " (score: ", best_z_ratio, ")")
	p.free()
	quit(0)
