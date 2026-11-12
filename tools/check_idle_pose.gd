extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var ap = s.find_child("AnimationPlayer", true, false) as AnimationPlayer
	ap.play("Idle")
	ap.advance(0.1)

	var skel = s.find_child("Skeleton3D", true, false) as Skeleton3D
	var head = skel.find_bone("mixamorig_Head")
	var hips = skel.find_bone("mixamorig_Hips")
	var l_foot = skel.find_bone("mixamorig_LeftFoot")

	print("With Idle animation:")
	print("  Hips global pose:", skel.get_bone_global_pose(hips).origin)
	print("  Head global pose:", skel.get_bone_global_pose(head).origin)
	print("  LeftFoot global pose:", skel.get_bone_global_pose(l_foot).origin)
	quit(0)
