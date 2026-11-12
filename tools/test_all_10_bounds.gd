extends SceneTree

func _init():
	var test_weapons = ["usp45", "m4a1", "ak47", "remington870", "desert_eagle", "mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"]
	
	const WEAPON_TARGET_SIZES: Dictionary = {
		"usp45": 0.42,
		"pistol": 0.42,
		"desert_eagle": 0.46,
		"combat_knife": 0.38,
		"mp5": 0.60,
		"m4a1": 0.72,
		"rifle": 0.72,
		"remington870": 0.74,
		"shotgun": 0.74,
		"ak47": 0.74,
		"awp": 0.80,
		"crossbow": 0.68,
		"grenade_launcher": 0.70
	}
	
	for wid in test_weapons:
		var scene_path = "res://scenes/weapons/models/%s.tscn" % wid
		var inst = load(scene_path).instantiate()
		var base_rot = Vector3(90, -90, 0)
		inst.rotation_degrees = base_rot
		
		var aabb = AABB()
		var first = true
		var meshes_found = inst.find_children("*", "MeshInstance3D", true, false)
		if inst is MeshInstance3D: meshes_found.append(inst)
		for mi in meshes_found:
			if mi.mesh:
				var m_aabb = mi.transform * mi.mesh.get_aabb()
				if first:
					aabb = m_aabb
					first = false
				else:
					aabb = aabb.merge(m_aabb)
					
		var center = aabb.get_center()
		var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
		var target_size = WEAPON_TARGET_SIZES.get(wid, 0.72)
		var s = target_size / max_dim
		inst.scale = Vector3(s, s, s)
		var rot_center = inst.transform.basis * center
		inst.position = -rot_center + Vector3(0, 0.04, 0)
		
		# Compute transformed min and max
		var min_w = Vector3.INF
		var max_w = -Vector3.INF
		for mi in meshes_found:
			if mi.mesh:
				for s_idx in range(mi.mesh.get_surface_count()):
					var arrs = mi.mesh.surface_get_arrays(s_idx)
					if arrs.size() > Mesh.ARRAY_VERTEX and arrs[Mesh.ARRAY_VERTEX]:
						var verts = arrs[Mesh.ARRAY_VERTEX]
						for v in verts:
							var local_v = mi.transform * v
							var world_v = inst.transform * local_v
							min_w = min_w.min(world_v)
							max_w = max_w.max(world_v)
		var w_size = max_w - min_w
		var w_center = (min_w + max_w) * 0.5
		print("Weapon: %16s | size: (%5.2f, %5.2f, %5.2f) | center: (%5.2f, %5.2f, %5.2f) | Y min: %5.2f" % [
			wid, w_size.x, w_size.y, w_size.z, w_center.x, w_center.y, w_center.z, min_w.y
		])
		inst.free()
	quit()
