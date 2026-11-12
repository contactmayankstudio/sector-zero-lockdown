extends SceneTree

func _init():
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root.add_child(bike)
	bike._ready()

	var dummy = Node3D.new()
	root.add_child(dummy)
	bike.enter_vehicle(dummy)

	var soldier = bike.rider_soldier
	if not soldier:
		print("ERROR: rider_soldier is null!")
		quit(1)
		return

	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	if anim:
		anim.stop()
		anim.active = false

	# Position soldier on Hayabusa seat:
	soldier.position = Vector3(0.0, 0.44, -0.16)

	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	var l_hand = skel.find_bone("mixamorig_LeftHand")

	# Lean spine forward over tank
	var spine = skel.find_bone("mixamorig_Spine")
	skel.set_bone_pose_rotation(spine, Quaternion(Vector3.RIGHT, deg_to_rad(30.0)))
	var spine1 = skel.find_bone("mixamorig_Spine1")
	skel.set_bone_pose_rotation(spine1, Quaternion(Vector3.RIGHT, deg_to_rad(18.0)))

	# Target position on bike for LeftHand:
	# Left handle clip-on: (-0.22, 0.74, -0.68)
	var target = Vector3(-0.22, 0.74, -0.68)

	var best_d = 999.0
	var best_euler = Vector3.ZERO
	var best_fore_euler = Vector3.ZERO
	var best_pos = Vector3.ZERO

	# Test angles: ax in [-180, 180], ay in [-180, 180], az in [-180, 180]
	for ax in range(-160, 161, 20):
		for ay in range(-160, 161, 20):
			for az in range(-160, 161, 20):
				var q_arm = Quaternion.from_euler(Vector3(deg_to_rad(ax), deg_to_rad(ay), deg_to_rad(az)))
				skel.set_bone_pose_rotation(l_arm, q_arm)
				for fx in [0, 40, 80, -40, -80]:
					for fz in [0, 30, 60, -30, -60]:
						var q_fore = Quaternion.from_euler(Vector3(deg_to_rad(fx), 0, deg_to_rad(fz)))
						skel.set_bone_pose_rotation(l_fore, q_fore)
						skel.force_update_bone_child_transform(l_arm)
						skel.force_update_bone_child_transform(l_fore)
						skel.force_update_bone_child_transform(l_hand)

						var p = bike.to_local(skel.to_global(skel.get_bone_global_pose(l_hand).origin))
						var d = p.distance_to(target)
						if d < best_d:
							best_d = d
							best_euler = Vector3(ax, ay, az)
							best_fore_euler = Vector3(fx, 0, fz)
							best_pos = p

	print("LeftHand best_dist: ", best_d, " hand_pos: ", best_pos)
	print("Best LeftArm Euler: ", best_euler)
	print("Best LeftForeArm Euler: ", best_fore_euler)

	quit(0)
