extends SceneTree

func _init():
	var s_res = load("res://scenes/characters/RealSoldier.scn")
	var s = s_res.instantiate()
	var skel: Skeleton3D = s.find_child("Skeleton3D", true, false)
	for b_name in ["mixamorig_LeftArm", "mixamorig_RightArm", "mixamorig_LeftForeArm", "mixamorig_RightForeArm", "mixamorig_LeftHand", "mixamorig_RightHand"]:
		var idx = skel.find_bone(b_name)
		print(b_name, " rest basis: \n", skel.get_bone_rest(idx).basis)
	quit(0)
