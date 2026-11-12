extends SceneTree

func _init():
	var test_models = [
		"res://scenes/zombies/models/RealDoomZombie.scn",
		"res://scenes/zombies/models/RealSoldierZombie.scn"
	]
	for mpath in test_models:
		print("=================================")
		print("Checking bone tree for: ", mpath)
		var res = load(mpath)
		var inst = res.instantiate()
		var skels = inst.find_children("*", "Skeleton3D", true, false)
		if not skels.is_empty():
			var sk: Skeleton3D = skels[0]
			for b in range(sk.get_bone_count()):
				var bname = sk.get_bone_name(b)
				var parent_idx = sk.get_bone_parent(b)
				var parent_name = sk.get_bone_name(parent_idx) if parent_idx >= 0 else "ROOT"
				if "head" in bname.to_lower() or "neck" in bname.to_lower() or (parent_idx >= 0 and ("head" in parent_name.to_lower() or "neck" in parent_name.to_lower())):
					print("  Bone ", b, ": '", bname, "' (Parent: ", parent_idx, " '", parent_name, "')")
		inst.free()
	quit()
