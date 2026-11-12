extends SceneTree

func _init():
	print("--- FINDING BARREL / MUZZLE DIRECTIONS ---")
	var weapons = {
		"negev_ng7": "res://scenes/weapons/models/negev_ng7.scn",
		"p90": "res://scenes/weapons/models/p90.scn",
		"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.scn",
		"akx_scifi": "res://scenes/weapons/models/akx_scifi.scn",
		"n7_rifle": "res://scenes/weapons/models/n7_rifle.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn"
	}
	
	for id in weapons:
		var scn = load(weapons[id])
		var inst = scn.instantiate()
		# Find mesh with "barrel" or check vertices at extremes
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		print("=== ", id, " ===")
		for m in meshes:
			var n = m.name.to_lower()
			if "barrel" in n or "muzzle" in n or "brake" in n or "flash" in n or "tip" in n:
				print("  Key component: ", m.name, " pos: ", (m.transform * m.get_aabb()).get_center())
		inst.free()
	quit(0)
