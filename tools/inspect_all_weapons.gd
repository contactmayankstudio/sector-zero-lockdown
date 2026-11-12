extends SceneTree

func _init():
	var configs = [
		{"id": "negev_ng7", "model": "res://scenes/weapons/models/negev_ng7.scn"},
		{"id": "akx_scifi", "model": "res://scenes/weapons/models/akx_scifi.scn"},
		{"id": "car_smg", "model": "res://scenes/weapons/models/car_smg.scn"},
		{"id": "grenade_mk2", "model": "res://scenes/weapons/models/grenade_mk2.scn"},
		{"id": "primordium_vandal", "model": "res://scenes/weapons/models/primordium_vandal.scn"},
		{"id": "prowler_smg", "model": "res://scenes/weapons/models/prowler_smg.scn"},
		{"id": "ray_gun_cod", "model": "res://scenes/weapons/models/ray_gun_cod.scn"},
		{"id": "rocket_launcher", "model": "res://scenes/weapons/models/rocket_launcher.scn"},
		{"id": "pestilence_handgun", "model": "res://scenes/weapons/models/pestilence_handgun.scn"},
		{"id": "arcade_gun", "model": "res://scenes/weapons/models/arcade_gun.scn"},
		{"id": "retro_ray_gun", "model": "res://scenes/weapons/models/retro_ray_gun.scn"}
	]
	
	for c in configs:
		if not ResourceLoader.exists(c.model):
			print("MISSING: ", c.id)
			continue
		var res = load(c.model)
		var inst = res.instantiate()
		var total_aabb = AABB()
		var first = true
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			if m.mesh:
				var a = m.mesh.get_aabb()
				if first:
					total_aabb = a
					first = false
				else:
					total_aabb = total_aabb.merge(a)
		print(c.id, " TOTAL AABB size=", total_aabb.size, " pos=", total_aabb.position)
		inst.free()
	quit(0)
