extends SceneTree

func _init():
	print("--- DETAILED WEAPON GEOMETRY ANALYSIS ---")
	var weapons = {
		"negev_ng7": "res://scenes/weapons/models/negev_ng7.scn",
		"p90": "res://scenes/weapons/models/p90.scn",
		"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.scn",
		"akx_scifi": "res://scenes/weapons/models/akx_scifi.scn",
		"n7_rifle": "res://scenes/weapons/models/n7_rifle.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn",
		"grenade_mk2": "res://scenes/weapons/models/grenade_mk2.scn"
	}
	
	for id in weapons:
		var scn = load(weapons[id])
		var inst = scn.instantiate()
		var total_aabb: AABB = AABB()
		var first = true
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		for mi in meshes:
			if mi.mesh:
				var m_aabb = mi.get_aabb()
				# transform aabb to inst local space
				var local_aabb = mi.transform * m_aabb
				if first:
					total_aabb = local_aabb
					first = false
				else:
					total_aabb = total_aabb.merge(local_aabb)
		print("ID: ", id)
		print("  Total AABB Pos: ", total_aabb.position)
		print("  Total AABB Size: ", total_aabb.size)
		print("  Total AABB Center: ", total_aabb.get_center())
		var sx = total_aabb.size.x
		var sy = total_aabb.size.y
		var sz = total_aabb.size.z
		print("  Longest axis: ", "X" if (sx > sy and sx > sz) else ("Y" if sy > sz else "Z"))
		inst.free()
	quit(0)
