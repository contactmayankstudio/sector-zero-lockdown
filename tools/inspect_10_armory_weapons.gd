extends SceneTree

func _init():
	print("--- INSPECTING 10 WEAPONS FOR ARMORY SHOWROOM ---")
	var weapons = [
		"usp45", "m4a1", "remington870", "ak47", "desert_eagle",
		"mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"
	]
	
	for wid in weapons:
		var scene_path = "res://scenes/weapons/models/%s.tscn" % wid
		var glb_path = "res://assets/3d/weapons/%s.glb" % wid
		var scn = load(scene_path) if ResourceLoader.exists(scene_path) else null
		var glb = load(glb_path) if ResourceLoader.exists(glb_path) else null
		print("Weapon: %s | Scn: %s | GLB: %s" % [wid, scn != null, glb != null])
		if scn:
			var inst = scn.instantiate()
			var meshes = inst.find_children("*", "MeshInstance3D", true, false)
			if inst is MeshInstance3D: meshes.append(inst)
			for mi in meshes:
				if mi.mesh:
					var aabb = mi.mesh.get_aabb()
					print("  Mesh '%s' AABB size: %s, center: %s" % [mi.name, str(aabb.size), str(aabb.get_center())])
			inst.free()
	quit()
