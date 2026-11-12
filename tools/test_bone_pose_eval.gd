extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	
	print("Initial LeftArm pose: ", skel.get_bone_pose(l_arm))
	skel.set_bone_pose_rotation(l_arm, Quaternion(Vector3.RIGHT, deg_to_rad(45.0)))
	print("After set rotation, LeftArm pose rot: ", skel.get_bone_pose_rotation(l_arm))
	print("LeftArm pose transform: ", skel.get_bone_pose(l_arm))
	
	skel.force_update_all_bone_transforms()
	print("Global pose LeftArm: ", skel.get_bone_global_pose(l_arm))
	
	quit(0)
