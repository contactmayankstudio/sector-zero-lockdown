@tool
extends SceneTree

# Find exact muzzle and top directions for weapons
func _init():
	var weapons = [
		{"id": "negev_ng7", "path": "res://scenes/weapons/models/negev_ng7.scn"},
		{"id": "p90", "path": "res://scenes/weapons/models/p90.scn"},
		{"id": "ak74_bayonet", "path": "res://scenes/weapons/models/ak74_bayonet.scn"},
		{"id": "akx_scifi", "path": "res://scenes/weapons/models/akx_scifi.scn"},
		{"id": "n7_rifle", "path": "res://scenes/weapons/models/n7_rifle.scn"},
		{"id": "car_smg", "path": "res://scenes/weapons/models/car_smg.scn"},
		{"id": "grenade_mk2", "path": "res://scenes/weapons/models/grenade_mk2.scn"},
		{"id": "primordium_vandal", "path": "res://scenes/weapons/models/primordium_vandal.scn"},
		{"id": "prowler_smg", "path": "res://scenes/weapons/models/prowler_smg.scn"},
		{"id": "ray_gun_cod", "path": "res://scenes/weapons/models/ray_gun_cod.scn"},
		{"id": "plasma_gun", "path": "res://scenes/weapons/models/plasma_gun.scn"},
		{"id": "rocket_launcher", "path": "res://scenes/weapons/models/rocket_launcher.scn"},
		{"id": "pestilence_handgun", "path": "res://scenes/weapons/models/pestilence_handgun.scn"},
		{"id": "arcade_gun", "path": "res://scenes/weapons/models/arcade_gun.scn"},
		{"id": "retro_ray_gun", "path": "res://scenes/weapons/models/retro_ray_gun.scn"},
		{"id": "scifi_battle_rifle", "path": "res://scenes/weapons/models/scifi_battle_rifle.scn"},
		{"id": "prowl_blaster", "path": "res://scenes/weapons/models/prowl_blaster.scn"},
		{"id": "vaccinator_energy", "path": "res://scenes/weapons/models/vaccinator_energy.scn"},
		{"id": "axon_cannon", "path": "res://scenes/weapons/models/axon_cannon.scn"},
	]

	print("\n================ MUZZLE & TOP DIRECTION CALIBRATION ================")
	for w in weapons:
		var scn = load(w.path)
		if not scn:
			continue
		var inst = scn.instantiate()
		
		# Find bounds
		var min_b = Vector3(1e9, 1e9, 1e9)
		var max_b = Vector3(-1e9, -1e9, -1e9)
		var stack = [inst]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				var aabb = curr.mesh.get_aabb()
				var rel_t = inst.transform.affine_inverse() * curr.transform
				for cx in [0, 1]:
					for cy in [0, 1]:
						for cz in [0, 1]:
							var corner = aabb.position + aabb.size * Vector3(cx, cy, cz)
							var tc = rel_t * corner
							min_b.x = min(min_b.x, tc.x)
							min_b.y = min(min_b.y, tc.y)
							min_b.z = min(min_b.z, tc.z)
							max_b.x = max(max_b.x, tc.x)
							max_b.y = max(max_b.y, tc.y)
							max_b.z = max(max_b.z, tc.z)
			for c in curr.get_children():
				stack.append(c)
				
		var size = max_b - min_b
		# Determine which axis is longest (length), second longest (height), shortest (width)
		var dims = [
			{"axis": "X", "val": size.x, "min": min_b.x, "max": max_b.x},
			{"axis": "Y", "val": size.y, "min": min_b.y, "max": max_b.y},
			{"axis": "Z", "val": size.z, "min": min_b.z, "max": max_b.z},
		]
		dims.sort_custom(func(a, b): return a.val > b.val)
		var long_axis = dims[0].axis
		var height_axis = dims[1].axis
		var width_axis = dims[2].axis
		
		print("%-20s: Length=%s(%.2fm), Height=%s(%.2fm), Width=%s(%.2fm)" % [
			w.id, long_axis, dims[0].val, height_axis, dims[1].val, width_axis, dims[2].val
		])
		inst.free()
	quit(0)
