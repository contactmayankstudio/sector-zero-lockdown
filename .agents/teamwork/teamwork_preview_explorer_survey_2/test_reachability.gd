extends SceneTree

func _init():
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root_node.add_child(bike)
	
	create_timer(0.05).timeout.connect(func():
		_solve_full_pose(bike)
	)

func _solve_full_pose(bike: Node3D):
	var rider = bike.rider_soldier
	var skel: Skeleton3D = rider.find_child("Skeleton3D", true, false)
	var anim_player: AnimationPlayer = rider.find_child("AnimationPlayer", true, false)
	
	anim_player.stop()
	anim_player.active = false
	rider.position = Vector3(0.0, -0.42, -0.04)
	
	# Target points on bike:
	var l_grip_target = Vector3(0.22, 0.88, -0.38)
	var r_grip_target = Vector3(-0.22, 0.88, -0.38)
	var l_peg_target = Vector3(0.20, 0.38, 0.08)
	var r_peg_target = Vector3(-0.20, 0.38, 0.08)
	
	# Let's test bone rotations
	# In Character local:
	# Spine forward bend: rotation around local X
	var spine_bones = ["mixamorig_Spine", "mixamorig_Spine1", "mixamorig_Spine2"]
	for b_name in spine_bones:
		var idx = skel.find_bone(b_name)
		# 15 degrees per spine segment = 45 degrees total forward tuck
		skel.set_bone_pose_rotation(idx, Quaternion.from_euler(Vector3(deg_to_rad(15.0), 0.0, 0.0)))
	
	# Neck and head: look up to road ahead
	var neck_idx = skel.find_bone("mixamorig_Neck")
	var head_idx = skel.find_bone("mixamorig_Head")
	skel.set_bone_pose_rotation(neck_idx, Quaternion.from_euler(Vector3(deg_to_rad(-18.0), 0.0, 0.0)))
	skel.set_bone_pose_rotation(head_idx, Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0.0, 0.0)))
	
	# Print shoulder positions
	var l_sh = skel.find_bone("mixamorig_LeftArm")
	var r_sh = skel.find_bone("mixamorig_RightArm")
	var l_sh_pos = bike.to_local(skel.global_transform * skel.get_bone_global_pose(l_sh).origin)
	var r_sh_pos = bike.to_local(skel.global_transform * skel.get_bone_global_pose(r_sh).origin)
	print("Left Shoulder in bike space: ", l_sh_pos, " dist to grip: ", l_sh_pos.distance_to(l_grip_target))
	print("Right Shoulder in bike space: ", r_sh_pos, " dist to grip: ", r_sh_pos.distance_to(r_grip_target))
	
	# Total arm length is 0.472m.
	# Notice dist to grip: if shoulder is ~0.40m from grip, it is completely reachable!
	
	# Check hip to peg distance
	var l_hip = skel.find_bone("mixamorig_LeftUpLeg")
	var r_hip = skel.find_bone("mixamorig_RightUpLeg")
	var l_hip_pos = bike.to_local(skel.global_transform * skel.get_bone_global_pose(l_hip).origin)
	var r_hip_pos = bike.to_local(skel.global_transform * skel.get_bone_global_pose(r_hip).origin)
	print("Left Hip in bike space: ", l_hip_pos, " dist to peg: ", l_hip_pos.distance_to(l_peg_target))
	print("Right Hip in bike space: ", r_hip_pos, " dist to peg: ", r_hip_pos.distance_to(r_peg_target))
	# Total leg length is 0.876m.
	# Dist to peg is ~0.4-0.5m, perfectly reachable with knee bent at ~90-100 degrees!
	
	quit(0)
