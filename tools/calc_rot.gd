extends SceneTree

func _init():
	print("--- DETERMINING EXACT MUZZLE / STOCK / UP VECTORS ---")
	var weapons = {
		"p90": "res://scenes/weapons/models/p90.scn",
		"negev_ng7": "res://scenes/weapons/models/negev_ng7.scn",
		"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.scn",
		"akx_scifi": "res://scenes/weapons/models/akx_scifi.scn",
		"n7_rifle": "res://scenes/weapons/models/n7_rifle.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn"
	}
	
	for id in weapons:
		var scn = load(weapons[id])
		var inst = scn.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		
		# For P90 and Negev: check X min vs X max vertices
		# Find the narrowest end (barrel is narrow circle of radius ~0.02, stock is wider rectangle of width ~0.08)
		var left_verts = [] # min along primary axis
		var right_verts = [] # max along primary axis
		
		for m in meshes:
			if not m.mesh: continue
			var xf = m.transform
			for s in range(m.mesh.get_surface_count()):
				var arr = m.mesh.surface_get_arrays(s)
				if arr.is_empty(): continue
				var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				for v in verts:
					var lv = xf * v
					if id in ["p90", "negev_ng7"]:
						if lv.x < -0.3: left_verts.append(lv)
						if lv.x > 0.3: right_verts.append(lv)
					elif id in ["akx_scifi", "ak74_bayonet"]:
						if lv.y < -0.3: left_verts.append(lv)
						if lv.y > 0.1: right_verts.append(lv)
					elif id in ["n7_rifle", "car_smg"]:
						if lv.z < -10.0: left_verts.append(lv)
						if lv.z > 2.0: right_verts.append(lv)
		
		# Compare thickness (Y & Z standard deviation or spread) of left vs right
		var left_y_span = 0.0
		var left_z_span = 0.0
		var right_y_span = 0.0
		var right_z_span = 0.0
		
		if not left_verts.is_empty() and not right_verts.is_empty():
			var l_min = left_verts[0]
			var l_max = left_verts[0]
			for v in left_verts:
				l_min.x = min(l_min.x, v.x); l_min.y = min(l_min.y, v.y); l_min.z = min(l_min.z, v.z)
				l_max.x = max(l_max.x, v.x); l_max.y = max(l_max.y, v.y); l_max.z = max(l_max.z, v.z)
			var r_min = right_verts[0]
			var r_max = right_verts[0]
			for v in right_verts:
				r_min.x = min(r_min.x, v.x); r_min.y = min(r_min.y, v.y); r_min.z = min(r_min.z, v.z)
				r_max.x = max(r_max.x, v.x); r_max.y = max(r_max.y, v.y); r_max.z = max(r_max.z, v.z)
			
			print("=== ", id, " ===")
			print("  Negative end span: size=", l_max - l_min, " center=", (l_min + l_max)*0.5)
			print("  Positive end span: size=", r_max - r_min, " center=", (r_min + r_max)*0.5)
		inst.free()
	quit(0)
