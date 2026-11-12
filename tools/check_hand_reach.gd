extends SceneTree

func _init():
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root.add_child(bike)
	bike._init_rider_soldier()

	var dummy = Node3D.new()
	root.add_child(dummy)
	bike.enter_vehicle(dummy)

	var soldier = bike.rider_soldier
	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	soldier.position = Vector3(0.0, 0.44, -0.16)

	var l_hand = skel.find_bone("mixamorig_LeftHand")
	var r_hand = skel.find_bone("mixamorig_RightHand")

	# Target handles on Hayabusa:
	# Front fork/handlebars: Y ≈ 0.75, Z ≈ -0.70, X ≈ ±0.22
	var l_target = Vector3(-0.22, 0.75, -0.70)
	var r_target = Vector3(0.22, 0.75, -0.70)

	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	var r_arm = skel.find_bone("mixamorig_RightArm")
	var r_fore = skel.find_bone("mixamorig_RightForeArm")

	# Test current pose:
	skel.set_bone_pose_rotation(l_arm, Quaternion.from_euler(Vector3(deg_to_rad(-25.0), deg_to_rad(-40.0), deg_to_rad(45.0))))
	skel.set_bone_pose_rotation(l_fore, Quaternion.from_euler(Vector3(deg_to_rad(-60.0), deg_to_rad(12.0), 0)))
	skel.set_bone_pose_rotation(l_hand, Quaternion.from_euler(Vector3(deg_to_rad(-15.0), 0, deg_to_rad(15.0))))

	skel.set_bone_pose_rotation(r_arm, Quaternion.from_euler(Vector3(deg_to_rad(25.0), deg_to_rad(40.0), deg_to_rad(-45.0))))
	skel.set_bone_pose_rotation(r_fore, Quaternion.from_euler(Vector3(deg_to_rad(60.0), deg_to_rad(-12.0), 0)))
	skel.set_bone_pose_rotation(r_hand, Quaternion.from_euler(Vector3(deg_to_rad(15.0), 0, deg_to_rad(-15.0))))

	# Spine lean
	var spine = skel.find_bone("mixamorig_Spine")
	skel.set_bone_pose_rotation(spine, Quaternion(Vector3.RIGHT, deg_to_rad(32.0)))
	var spine1 = skel.find_bone("mixamorig_Spine1")
	skel.set_bone_pose_rotation(spine1, Quaternion(Vector3.RIGHT, deg_to_rad(18.0)))

	skel.force_update_bone_child_transform(0)
	for i in range(skel.get_bone_count()):
		skel.force_update_bone_child_transform(i)

	var l_hand_pos = bike.to_local(skel.to_global(skel.get_bone_global_pose(l_hand).origin))
	var r_hand_pos = bike.to_local(skel.to_global(skel.get_bone_global_pose(r_hand).origin))

	print("LeftHand pos: ", l_hand_pos, " dist to handle: ", l_hand_pos.distance_to(l_target))
	print("RightHand pos: ", r_hand_pos, " dist to handle: ", r_hand_pos.distance_to(r_target))

	quit(0)
