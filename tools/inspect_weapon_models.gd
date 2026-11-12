extends SceneTree

func _init():
	var weapons = {
		"negev_ng7": "res://scenes/weapons/models/negev_ng7.scn",
		"p90": "res://scenes/weapons/models/p90.scn",
		"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.scn",
		"akx_scifi": "res://scenes/weapons/models/akx_scifi.scn",
		"n7_rifle": "res://scenes/weapons/models/n7_rifle.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn"
	}
	for id in weapons:
		print("=============================")
		print("WEAPON: ", id)
		var scn = load(weapons[id])
		var inst = scn.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		print("Mesh count: ", meshes.size())
		for m in meshes:
			var box = m.transform * m.get_aabb()
			print("  - ", m.name, " Center: ", box.get_center(), " Size: ", box.size)
		inst.free()
	quit(0)
