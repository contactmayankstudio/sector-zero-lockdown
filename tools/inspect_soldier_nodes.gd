extends SceneTree
func _init():
	var scn = load("res://scenes/characters/CombineSoldier.tscn")
	var inst = scn.instantiate()
	print("CombineSoldier children:")
	for c in inst.find_children("*"):
		print("  - ", c.name, " (", c.get_class(), ")")
	
	var r_scn = load("res://scenes/characters/RealSoldier.tscn")
	if r_scn:
		var r_inst = r_scn.instantiate()
		print("RealSoldier children:")
		for c in r_inst.find_children("*"):
			if c is Skeleton3D:
				print("  Skeleton3D bones: ", c.get_bone_count())
				for b in range(min(15, c.get_bone_count())):
					print("    Bone ", b, ": ", c.get_bone_name(b))
	quit(0)
