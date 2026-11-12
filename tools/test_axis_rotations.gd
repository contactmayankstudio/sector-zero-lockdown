extends SceneTree

func _init():
	var soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	root.add_child(soldier)

	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	var l_hand = skel.find_bone("mixamorig_LeftHand")

	# Base rest
	for i in range(skel.get_bone_count()):
		skel.set_bone_pose_rotation(i, Quaternion.IDENTITY)
	skel.force_update_bone_child_transform(l_arm)
	var base_fore = skel.get_bone_global_pose(l_fore).origin
	var base_arm = skel.get_bone_global_pose(l_arm).origin
	print("Arm pos: ", base_arm)
	print("Base Forearm vector from arm: ", base_fore - base_arm)

	# Test X rotation +60
	skel.set_bone_pose_rotation(l_arm, Quaternion(Vector3.RIGHT, deg_to_rad(60.0)))
	skel.force_update_bone_child_transform(l_arm)
	print("+60 X Forearm vector: ", skel.get_bone_global_pose(l_fore).origin - base_arm)

	# Test Y rotation +60
	skel.set_bone_pose_rotation(l_arm, Quaternion(Vector3.UP, deg_to_rad(60.0)))
	skel.force_update_bone_child_transform(l_arm)
	print("+60 Y Forearm vector: ", skel.get_bone_global_pose(l_fore).origin - base_arm)

	# Test Z rotation +60
	skel.set_bone_pose_rotation(l_arm, Quaternion(Vector3.FORWARD, deg_to_rad(60.0)))
	skel.force_update_bone_child_transform(l_arm)
	print("+60 Z Forearm vector: ", skel.get_bone_global_pose(l_fore).origin - base_arm)

	quit(0)
