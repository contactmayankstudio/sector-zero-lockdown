extends SceneTree

func _init():
	print("--- TUNING ALL WEAPON VIEWMODELS ---")
	var weapon_files = {
		"p90": "res://scenes/weapons/models/p90.scn",
		"negev_ng7": "res://scenes/weapons/models/negev_ng7.scn",
		"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.scn",
		"akx_scifi": "res://scenes/weapons/models/akx_scifi.scn",
		"n7_rifle": "res://scenes/weapons/models/n7_rifle.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn",
		"grenade_mk2": "res://scenes/weapons/models/grenade_mk2.scn"
	}
	
	for id in weapon_files:
		var scn = load(weapon_files[id])
		var inst = scn.instantiate()
		
		var aabb = AABB()
		var first = true
		for m in inst.find_children("*", "MeshInstance3D", true, false):
			if not m.mesh: continue
			var xf = m.transform
			var cur = m.get_parent()
			while cur and cur != inst:
				if cur is Node3D: xf = cur.transform * xf
				cur = cur.get_parent()
			var m_box = xf * m.get_aabb()
			if first:
				aabb = m_box
				first = false
			else:
				aabb = aabb.merge(m_box)
				
		print("WEAPON: ", id)
		print("  Total Box Min: ", aabb.position)
		print("  Total Box Max: ", aabb.end)
		print("  Total Box Size: ", aabb.size)
		print("  Total Box Center: ", aabb.get_center())
		inst.free()
	quit(0)
