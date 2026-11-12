extends SceneTree

func _init():
	print("--- CALIBRATING ALL WEAPON ORIENTATIONS ---")
	var weapons = {
		"negev_ng7": "res://scenes/weapons/models/negev_ng7.scn",
		"p90": "res://scenes/weapons/models/p90.scn",
		"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.scn",
		"akx_scifi": "res://scenes/weapons/models/akx_scifi.scn",
		"n7_rifle": "res://scenes/weapons/models/n7_rifle.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn"
	}
	
	for id in weapons:
		print("\n====================================")
		print("ANALYZING WEAPON: ", id)
		var scn = load(weapons[id])
		var inst = scn.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		
		# Collect all vertex points transformed into inst local space
		var min_pt = Vector3(9999, 9999, 9999)
		var max_pt = Vector3(-9999, -9999, -9999)
		var muzzle_hints = []
		var sight_hints = []
		var grip_hints = []
		
		for m in meshes:
			if not m.mesh: continue
			var xf = m.transform
			var mname = m.name.to_lower()
			for s in range(m.mesh.get_surface_count()):
				var arr = m.mesh.surface_get_arrays(s)
				if arr.is_empty(): continue
				var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				for v in verts:
					var lv = xf * v
					min_pt.x = min(min_pt.x, lv.x)
					min_pt.y = min(min_pt.y, lv.y)
					min_pt.z = min(min_pt.z, lv.z)
					max_pt.x = max(max_pt.x, lv.x)
					max_pt.y = max(max_pt.y, lv.y)
					max_pt.z = max(max_pt.z, lv.z)
			if "barrel" in mname or "compensator" in mname or "flash" in mname or "muzzle" in mname or "front_sight" in mname:
				muzzle_hints.append({"name": mname, "center": (xf * m.get_aabb()).get_center()})
			if "sight" in mname or "scope" in mname or "optic" in mname:
				sight_hints.append({"name": mname, "center": (xf * m.get_aabb()).get_center()})
			if "grip" in mname or "stock" in mname or "trigger" in mname or "mag" in mname:
				grip_hints.append({"name": mname, "center": (xf * m.get_aabb()).get_center()})
				
		print("Bounds Min: ", min_pt)
		print("Bounds Max: ", max_pt)
		print("Bounds Size: ", max_pt - min_pt)
		print("Bounds Center: ", (min_pt + max_pt) * 0.5)
		
		if not muzzle_hints.is_empty():
			print("Muzzle hints: ")
			for h in muzzle_hints:
				print("  - ", h.name, ": ", h.center)
		if not sight_hints.is_empty():
			print("Sight hints: ")
			for h in sight_hints:
				print("  - ", h.name, ": ", h.center)
		if not grip_hints.is_empty():
			print("Grip/Stock hints (first 3): ")
			for i in range(min(3, grip_hints.size())):
				print("  - ", grip_hints[i].name, ": ", grip_hints[i].center)
				
		inst.free()
	quit(0)
