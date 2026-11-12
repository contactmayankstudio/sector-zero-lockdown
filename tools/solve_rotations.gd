@tool
extends SceneTree

# Solve exact rotation, scale, and offset for all 19 weapons
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
			if abs(r.dot(u)) < 0.1: # perpendicular
				var f = r.cross(u) # right-handed: right x up = back (in Godot camera, -Z is forward, +Z is back)
				# In Godot Basis(col0=X, col1=Y, col2=Z):
				# Here: col0 is Right, col1 is Up, col2 is Back (+Z)
				var b = Basis(r, u, f)
				if b.determinant() > 0.9: # valid rotation
					perms.append(b)

	print("\n================ SOLVING EXACT WEAPON TRANSFORMS ================")
	var results = []
	for w in weapons:
		var scn = load(w.path)
		if not scn:
			continue
		var inst = scn.instantiate()
		
		# Collect all vertices in model-local space (downsampled for speed: max 5000 points)
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
						var step = max(1, int(v_arr.size() / 300))
						for i in range(0, v_arr.size(), step):
							pts.append(rel_t * v_arr[i])
			for c in curr.get_children():
				stack.append(c)
				
		if pts.is_empty():
			print("No points for ", w.id)
			inst.free()
			continue
			
		# Test all 24 orientations
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
			
			# Score criteria:
			# 1. Longest span should be Z (barrel forward/back)
			# 2. Second longest span should be Y (height)
			# 3. Shortest span should be X (width)
			if span.z < span.x or span.z < span.y:
				continue
				
			# Check muzzle vs stock:
			# Slice into front half (min Z to mid Z) and back half (mid Z to max Z)
			# Front half should be narrower/lighter (barrel) than back half (receiver/stock/handle)
			var mid_z = (min_v.z + max_v.z) * 0.5
			var front_pts = 0
			var back_pts = 0
			var front_width = 0.0
			var back_width = 0.0
			for p in pts:
				var rp = b * p
				if rp.z < mid_z:
					front_pts += 1
					front_width = max(front_width, abs(rp.x))
				else:
					back_pts += 1
					back_width = max(back_width, abs(rp.x))
					
			var score = (span.z * 10.0) + (span.y * 3.0) - (span.x * 2.0)
			# Front narrower than back bonus
			if back_width >= front_width:
				score += 5.0
			# Back has more points (grip/stock/mag) bonus
			if back_pts >= front_pts:
				score += 5.0
				
			if score > best_score:
				best_score = score
				best_basis = b
				best_span = span
				best_min = min_v
				best_max = max_v
				
		var euler_deg = best_basis.get_euler() * (180.0 / PI)
		# Compute uniform scale so length along Z matches target_len
		var scale_factor = w.target_len / max(0.001, best_span.z)
		
		# Compute offset so in camera space (WeaponManager at 0.18, -0.18, -0.42):
		# The back of the gun is near the camera, front is pointing forward (-Z)
		# Target camera space bounds:
		# X center ~ 0.18, Y center ~ -0.16, Z back ~ -0.20, Z front ~ -0.20 - target_len
		var scaled_center = ((best_min + best_max) * 0.5) * scale_factor
		var offset = -scaled_center
		
		print("\nWeapon: %s" % w.id)
		print("  Rot: Vector3(%.1f, %.1f, %.1f)" % [euler_deg.x, euler_deg.y, euler_deg.z])
		print("  Scale: Vector3(%.4f, %.4f, %.4f)" % [scale_factor, scale_factor, scale_factor])
		print("  Span: (X:%.3fm, Y:%.3fm, Z:%.3fm)" % [best_span.x * scale_factor, best_span.y * scale_factor, best_span.z * scale_factor])
		print("  Offset: Vector3(%.3f, %.3f, %.3f)" % [offset.x, offset.y, offset.z])
		
		results.append({
			"id": w.id,
			"rot": Vector3(round(euler_deg.x), round(euler_deg.y), round(euler_deg.z)),
			"scale": Vector3(scale_factor, scale_factor, scale_factor),
			"offset": offset,
			"span": best_span * scale_factor
		})
		inst.free()
		
	print("\n\n================ FINAL WEAPON_CONFIGS TABLE ================")
	for r in results:
		print("\t{")
		print("\t\t\"id\": \"%s\"," % r.id)
		print("\t\t\"rot\": Vector3(%.1f, %.1f, %.1f)," % [r.rot.x, r.rot.y, r.rot.z])
		print("\t\t\"scale\": Vector3(%.4f, %.4f, %.4f)," % [r.scale.x, r.scale.y, r.scale.z])
		print("\t\t\"offset\": Vector3(%.3f, %.3f, %.3f)" % [r.offset.x, r.offset.y, r.offset.z])
		print("\t},")
		
	quit(0)
