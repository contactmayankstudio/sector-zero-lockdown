extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	
	print("--- Solving Arm Angles ---")
	# In rest pose:
	skel.reset_bone_poses()
	skel.force_update_all_bone_transforms()
	var arm_origin = skel.get_bone_global_pose(l_arm).origin
	var fore_origin = skel.get_bone_global_pose(l_fore).origin
	var dir = (fore_origin - arm_origin).normalized()
	print("At rest, LeftArm points along: ", dir)
	
	# We want LeftArm to point DOWN (-Z in Godot character space? No, let's check coordinate system!)
	# What are character forward, up, right?
	var hips = skel.find_bone("mixamorig_Hips")
	var head = skel.find_bone("mixamorig_Head")
	var hips_pos = skel.get_bone_global_pose(hips).origin
	var head_pos = skel.get_bone_global_pose(head).origin
	var spine_dir = (head_pos - hips_pos).normalized()
	print("Character UP is: ", spine_dir)
	
	# In Mixamo: UP is +Z!
	# Because character UP is (0, 0, 1) or (0, 1, 0)?
	print("Hips pos: ", hips_pos, " Head pos: ", head_pos)

	# Test +45 deg on X, Y, Z of LeftArm:
	for axis in ["X", "Y", "Z"]:
		for deg in [45.0, -45.0]:
			skel.reset_bone_poses()
			var vec = Vector3.RIGHT if axis == "X" else (Vector3.UP if axis == "Y" else Vector3.BACK)
			skel.set_bone_pose_rotation(l_arm, Quaternion(vec, deg_to_rad(deg)))
			skel.force_update_all_bone_transforms()
			var new_fore = skel.get_bone_global_pose(l_fore).origin
			var new_dir = (new_fore - arm_origin).normalized()
			print("Rot LeftArm by %d on %s -> new arm dir: %s" % [int(deg), axis, new_dir])

	quit(0)
