
extends SceneTree

func print_skel(name, path):
	var sc = load(path)
	var inst = sc.instantiate()
	var skels = inst.find_children("*", "Skeleton3D", true, false)
	print("=== ", name, " Skeleton count: ", skels.size(), " ===")
	if not skels.is_empty():
		var sk = skels[0]
		print("Bone count: ", sk.get_bone_count())
		for b in range(sk.get_bone_count()):
			var bname = sk.get_bone_name(b)
			if "arm" in bname.to_lower() or "head" in bname.to_lower() or "spine" in bname.to_lower() or "clav" in bname.to_lower() or "neck" in bname.to_lower() or "leg" in bname.to_lower() or "thigh" in bname.to_lower() or "hip" in bname.to_lower():
				print("  [", b, "] ", bname)
	inst.free()

func _init():
	print_skel("RealDoomZombie", "res://scenes/zombies/models/RealDoomZombie.scn")
	print_skel("RealSoldierZombie", "res://scenes/zombies/models/RealSoldierZombie.scn")
	quit(0)
