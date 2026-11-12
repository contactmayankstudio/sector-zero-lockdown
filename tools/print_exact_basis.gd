@tool
extends SceneTree

func _init():
	var weapons = [
		{"id": "negev_ng7", "path": "res://scenes/weapons/models/negev_ng7.scn", "target_len": 0.65},
		{"id": "p90", "path": "res://scenes/weapons/models/p90.scn", "target_len": 0.50},
		{"id": "ak74_bayonet", "path": "res://scenes/weapons/models/ak74_bayonet.scn", "target_len": 0.75},
		{"id": "akx_scifi", "path": "res://scenes/weapons/models/akx_scifi.scn", "target_len": 0.65},
		{"id": "n7_rifle", "path": "res://scenes/weapons/models/n7_rifle.scn", "target_len": 0.70},
		{"id": "car_smg", "path": "res://scenes/weapons/models/car_smg.scn", "target_len": 0.55},
		{"id": "grenade_mk2", "path": "res://scenes/weapons/models/grenade_mk2.scn", "target_len": 0.18},
		{"id": "primordium_vandal", "path": "res://scenes/weapons/models/primordium_vandal.scn", "target_len": 0.70},
		{"id": "prowler_smg", "path": "res://scenes/weapons/models/prowler_smg.scn", "target_len": 0.55},
		{"id": "ray_gun_cod", "path": "res://scenes/weapons/models/ray_gun_cod.scn", "target_len": 0.48},
		{"id": "plasma_gun", "path": "res://scenes/weapons/models/plasma_gun.scn", "target_len": 0.60},
		{"id": "rocket_launcher", "path": "res://scenes/weapons/models/rocket_launcher.scn", "target_len": 0.75},
		{"id": "pestilence_handgun", "path": "res://scenes/weapons/models/pestilence_handgun.scn", "target_len": 0.38},
		{"id": "arcade_gun", "path": "res://scenes/weapons/models/arcade_gun.scn", "target_len": 0.42},
		{"id": "retro_ray_gun", "path": "res://scenes/weapons/models/retro_ray_gun.scn", "target_len": 0.45},
		{"id": "scifi_battle_rifle", "path": "res://scenes/weapons/models/scifi_battle_rifle.scn", "target_len": 0.68},
		{"id": "prowl_blaster", "path": "res://scenes/weapons/models/prowl_blaster.scn", "target_len": 0.45},
		{"id": "vaccinator_energy", "path": "res://scenes/weapons/models/vaccinator_energy.scn", "target_len": 0.62},
		{"id": "axon_cannon", "path": "res://scenes/weapons/models/axon_cannon.scn", "target_len": 0.65},
	]

	# All 24 rotational permutations (Right, Up, Forward)
	var perms = []
	var dirs = [
		Vector3.RIGHT, Vector3.LEFT,
		Vector3.UP, Vector3.DOWN,
		Vector3.FORWARD, Vector3.BACK
	]
	for r in dirs:
		for u in dirs:
			if abs(r.dot(u)) < 0.1:
				var f = r.cross(u)
				var b = Basis(r, u, f)
				if b.determinant() > 0.9:
					perms.append(b)

	print("\n================ EXACT BASIS CALIBRATION ================")
	for w in weapons:
		var scn = load(w.path)
		if not scn:
			continue
		var inst = scn.instantiate()
		
		# Sample max 100 points
		var pts: PackedVector3Array = []
		var stack = [inst]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				var m = curr.mesh
				var rel_t = inst.transform.affine_inverse() * curr.transform
				for s in range(m.get_surface_count()):
					var arr = m.surface_get_arrays(s)
					if arr.size() > Mesh.ARRAY_VERTEX:
						var v_arr = arr[Mesh.ARRAY_VERTEX]
						var step = max(1, int(v_arr.size() / 50))
						for i in range(0, v_arr.size(), step):
							pts.append(rel_t * v_arr[i])
			for c in curr.get_children():
				stack.append(c)
				
		var best_basis = Basis()
		var best_score = -1e9
		var best_span = Vector3.ZERO
		var best_min = Vector3.ZERO
		var best_max = Vector3.ZERO
		
		for b in perms:
			var min_v = Vector3(1e9, 1e9, 1e9)
			var max_v = Vector3(-1e9, -1e9, -1e9)
			for p in pts:
				var rp = b * p
				min_v.x = min(min_v.x, rp.x)
				min_v.y = min(min_v.y, rp.y)
				min_v.z = min(min_v.z, rp.z)
				max_v.x = max(max_v.x, rp.x)
				max_v.y = max(max_v.y, rp.y)
				max_v.z = max(max_v.z, rp.z)
			var span = max_v - min_v
			if span.z < span.x or span.z < span.y:
				continue
			var score = (span.z * 10.0) + (span.y * 3.0) - (span.x * 2.0)
			if score > best_score:
				best_score = score
				best_basis = b
				best_span = span
				best_min = min_v
				best_max = max_v
				
		var scale_factor = w.target_len / max(0.001, best_span.z)
		# Basis format: Basis(Vector3(x1, y1, z1), Vector3(x2, y2, z2), Vector3(x3, y3, z3))
		print("\"%s\": Basis(Vector3(%.1f, %.1f, %.1f), Vector3(%.1f, %.1f, %.1f), Vector3(%.1f, %.1f, %.1f)), Scale: %.4f" % [
			w.id,
			best_basis.x.x, best_basis.x.y, best_basis.x.z,
			best_basis.y.x, best_basis.y.y, best_basis.y.z,
			best_basis.z.x, best_basis.z.y, best_basis.z.z,
			scale_factor
		])
		inst.free()
	quit(0)
