extends SceneTree

func _init():
	var models = [
		"res://scenes/zombies/models/RealDoomZombie.scn",
		"res://scenes/zombies/models/RealSoldierZombie.scn",
		"res://scenes/zombies/models/RealAlienMutant.scn",
		"res://scenes/zombies/models/RealReptileMutant.scn",
		"res://scenes/zombies/models/RealButcherBoss.scn",
		"res://scenes/zombies/models/RealInfectedHound.scn",
		"res://scenes/zombies/models/infected_dog.tscn",
		"res://scenes/zombies/models/zombie_boss.tscn",
		"res://scenes/zombies/models/zombie_normal.tscn",
		"res://scenes/zombies/models/zombie_heavy.tscn",
		"res://scenes/zombies/models/zombie_fast.tscn",
		"res://assets/zombies/RealisticZombie.tscn"
	]
	
	for path in models:
		print("==========================================")
		print("MODEL: ", path)
		if not ResourceLoader.exists(path):
			print("  [NOT FOUND]")
			continue
		var res = load(path)
		if not (res is PackedScene):
			print("  [NOT PACKED SCENE: ", res, "]")
			continue
		var inst = res.instantiate()
		var skels = inst.find_children("*", "Skeleton3D", true, false)
		print("  Skeletons found: ", skels.size())
		for sk in skels:
			print("  Skeleton name: ", sk.name, " path: ", inst.get_path_to(sk))
			print("  Bone count: ", sk.get_bone_count())
			var head_candidates = []
			for b in range(sk.get_bone_count()):
				var bname = sk.get_bone_name(b)
				if bname.to_lower().contains("head") or bname.to_lower().contains("neck") or bname.to_lower().contains("skull"):
					head_candidates.append(str(b) + ": " + bname)
			print("  Head/Neck bones: ", head_candidates)
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		print("  MeshInstances: ", meshes.size())
		for mi in meshes:
			print("    Mesh: ", mi.name, " (skeleton: ", mi.skeleton, ")")
		inst.free()
	quit()
