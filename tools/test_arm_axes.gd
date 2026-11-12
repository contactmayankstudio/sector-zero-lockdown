extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_hand = skel.find_bone("mixamorig_LeftHand")
	
	print("--- LeftArm Axis Testing on Hand ---")
	skel.set_bone_pose_rotation(l_arm, Quaternion.IDENTITY)
	skel.force_update_all_bone_transforms()
	var rest_hand_pos = skel.get_bone_global_pose(l_hand).origin
	print("At identity, LeftHand global pos: ", rest_hand_pos)
	
	for axis_name in ["X", "Y", "Z"]:
		for sign_val in [1.0, -1.0]:
			var vec = Vector3.RIGHT if axis_name == "X" else (Vector3.UP if axis_name == "Y" else Vector3.BACK)
			skel.set_bone_pose_rotation(l_arm, Quaternion(vec, sign_val * deg_to_rad(45.0)))
			skel.force_update_all_bone_transforms()
			var pos = skel.get_bone_global_pose(l_hand).origin
			var delta_pos = pos - rest_hand_pos
			print("LeftArm rot 45 on %s%s -> delta hand pos: %s" % [("+" if sign_val > 0 else "-"), axis_name, delta_pos])
	quit(0)
