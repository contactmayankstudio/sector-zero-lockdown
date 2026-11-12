extends SceneTree

func _init():
	print("=== COMPUTING AND TESTING WEAPON FORWARD ROTATIONS ===")
	var configs = [
		{"id": "negev_ng7", "model": "res://scenes/weapons/models/negev_ng7.scn"},
		{"id": "akx_scifi", "model": "res://scenes/weapons/models/akx_scifi.scn"},
		{"id": "car_smg", "model": "res://scenes/weapons/models/car_smg.scn"},
		{"id": "primordium_vandal", "model": "res://scenes/weapons/models/primordium_vandal.scn"},
		{"id": "prowler_smg", "model": "res://scenes/weapons/models/prowler_smg.scn"},
		{"id": "ray_gun_cod", "model": "res://scenes/weapons/models/ray_gun_cod.scn"},
		{"id": "rocket_launcher", "model": "res://scenes/weapons/models/rocket_launcher.scn"},
		{"id": "pestilence_handgun", "model": "res://scenes/weapons/models/pestilence_handgun.scn"},
		{"id": "arcade_gun", "model": "res://scenes/weapons/models/arcade_gun.scn"},
		{"id": "retro_ray_gun", "model": "res://scenes/weapons/models/retro_ray_gun.scn"},
		{"id": "prowl_blaster", "model": "res://scenes/weapons/models/prowl_blaster.scn"},
		{"id": "vaccinator_energy", "model": "res://scenes/weapons/models/vaccinator_energy.scn"},
		{"id": "axon_cannon", "model": "res://scenes/weapons/models/axon_cannon.scn"}
	]
	
	for c in configs:
		if not ResourceLoader.exists(c.model):
			continue
		var res = load(c.model)
		var inst = res.instantiate()
		
		# Test cardinal rotations: (rx, ry, rz) in increments of 90 degrees
		var best_rot = Vector3.ZERO
		var max_z_span = -1.0
		var best_size = Vector3.ZERO
		
		var angles = [0, 90, 180, 270, -90]
		for rx in angles:
			for ry in angles:
				for rz in angles:
					inst.rotation_degrees = Vector3(rx, ry, rz)
					var min_pt = Vector3(9999, 9999, 9999)
					var max_pt = Vector3(-9999, -9999, -9999)
					for m in inst.find_children("*", "MeshInstance3D", true, false):
						if m.mesh:
							var xf = inst.transform * m.transform
							var a = xf * m.mesh.get_aabb()
							min_pt.x = min(min_pt.x, a.position.x)
							min_pt.y = min(min_pt.y, a.position.y)
							min_pt.z = min(min_pt.z, a.position.z)
							max_pt.x = max(max_pt.x, a.end.x)
							max_pt.y = max(max_pt.y, a.end.y)
							max_pt.z = max(max_pt.z, a.end.z)
					var sz = max_pt - min_pt
					# We want longest dimension along Z, and Y (height) > X (thickness)
					if sz.z > max_z_span:
						# Also check that height > width for standard gun profile
						if sz.y >= sz.x * 0.7:
							max_z_span = sz.z
							best_rot = Vector3(rx, ry, rz)
							best_size = sz
							
		print("Wep: %-18s -> Best rot: %-20s | Size: (X:%.2f, Y:%.2f, Z:%.2f)" % [
			c.id, str(best_rot), best_size.x, best_size.y, best_size.z
		])
		inst.free()
	quit(0)
