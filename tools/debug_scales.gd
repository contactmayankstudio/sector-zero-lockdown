extends SceneTree

func _init():
	var weapons = ["m4a1", "usp45", "ak47", "awp", "desert_eagle", "mp5", "combat_knife", "crossbow", "grenade_launcher"]
	
	const WEAPON_ORIENTATIONS: Dictionary = {
		"usp45": Vector3(90, 0, -90),
		"pistol": Vector3(90, 0, -90),
		"m4a1": Vector3(90, 0, -90),
		"rifle": Vector3(90, 0, -90),
		"remington870": Vector3(90, 0, -90),
		"shotgun": Vector3(90, 0, -90),
		"ak47": Vector3(90, 0, -90),
		"desert_eagle": Vector3(90, 0, -90),
		"mp5": Vector3(0, -90, 0),
		"awp": Vector3(90, 0, -90),
		"combat_knife": Vector3(90, 0, -90),
		"crossbow": Vector3(90, 0, -90),
		"grenade_launcher": Vector3(0, -90, 0)
	}
	
	for wid in weapons:
		var scene_path = "res://scenes/weapons/models/%s.tscn" % wid
		var inst = load(scene_path).instantiate()
		var base_rot = WEAPON_ORIENTATIONS.get(wid, Vector3.ZERO)
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
		var target_size = 0.72
		var s = target_size / max_dim
		var rot_center = inst.transform.basis * center
		var pos = -rot_center * s + Vector3(0, 0.04, 0)
		
		print("Weapon: %15s | max_dim: %.3f | scale: %.3f | rot_center: %s | pos: %s" % [
			wid, max_dim, s, str(rot_center), str(pos)
		])
		inst.free()
	quit()
