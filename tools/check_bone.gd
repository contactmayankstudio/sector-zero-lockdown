extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var skel = s.find_child("Skeleton3D", true, false)
	var head_idx = skel.find_bone("mixamorig_Head")
	var t = skel.get_bone_global_pose(head_idx)
	print("Head origin:", t.origin)
	quit(0)
