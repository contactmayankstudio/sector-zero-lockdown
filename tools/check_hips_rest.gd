extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var skel = s.find_child("Skeleton3D", true, false) as Skeleton3D
	var hips = skel.find_bone("mixamorig_Hips")
	print("Hips rest pose:", skel.get_bone_rest(hips))
	print("Hips pose rot:", skel.get_bone_pose_rotation(hips))
	print("Hips euler:", skel.get_bone_pose_rotation(hips).get_euler() * 180.0 / PI)
	quit(0)
