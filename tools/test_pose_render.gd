extends Node3D

func _ready():
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	add_child(bike)

	var dummy = Node3D.new()
	add_child(dummy)
	bike.enter_vehicle(dummy)

	# Camera - in-game 3rd-person chase camera view from behind and slightly elevated
	var cam = Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0.0, 1.35, 1.85)
	cam.look_at(Vector3(0.0, 0.72, -0.5), Vector3.UP)
	cam.current = true
	if bike.chase_camera:
		bike.chase_camera.current = false

	var light = DirectionalLight3D.new()
	add_child(light)
	light.rotation_degrees = Vector3(-40, 50, 0)
	light.light_energy = 1.3

	var ground = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(10, 10)
	ground.mesh = plane
	var gmat = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.25, 0.25, 0.28)
	ground.material_override = gmat
	add_child(ground)

	var soldier = bike.rider_soldier
	if soldier:
		var anim: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
		if anim:
			anim.stop()
			anim.active = false

		soldier.position = Vector3(0.0, 0.44, -0.16)

		var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
		if skel:
			for i in range(skel.get_bone_count()):
				skel.set_bone_pose_rotation(i, Quaternion.IDENTITY)

			# 1. Hips & Pelvis tilt forward
			var hips_idx = skel.find_bone("mixamorig_Hips")
			if hips_idx != -1:
				skel.set_bone_pose_rotation(hips_idx, Quaternion(Vector3.RIGHT, deg_to_rad(15.0)))

			# 2. Spine & Head - deep lean over fuel tank, head looking forward
			var spine_idx = skel.find_bone("mixamorig_Spine")
			if spine_idx != -1:
				skel.set_bone_pose_rotation(spine_idx, Quaternion(Vector3.RIGHT, deg_to_rad(32.0)))
			var spine1_idx = skel.find_bone("mixamorig_Spine1")
			if spine1_idx != -1:
				skel.set_bone_pose_rotation(spine1_idx, Quaternion(Vector3.RIGHT, deg_to_rad(18.0)))
			var spine2_idx = skel.find_bone("mixamorig_Spine2")
			if spine2_idx != -1:
				skel.set_bone_pose_rotation(spine2_idx, Quaternion(Vector3.RIGHT, deg_to_rad(10.0)))
			var neck_idx = skel.find_bone("mixamorig_Neck")
			if neck_idx != -1:
				skel.set_bone_pose_rotation(neck_idx, Quaternion(Vector3.RIGHT, deg_to_rad(-15.0)))
			var head_idx = skel.find_bone("mixamorig_Head")
			if head_idx != -1:
				skel.set_bone_pose_rotation(head_idx, Quaternion(Vector3.RIGHT, deg_to_rad(-25.0)))

			# 3. Legs onto rearset footpegs
			var l_up_leg = skel.find_bone("mixamorig_LeftUpLeg")
			if l_up_leg != -1:
				skel.set_bone_pose_rotation(l_up_leg, Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(-16.0), deg_to_rad(16.0))))
			var l_leg = skel.find_bone("mixamorig_LeftLeg")
			if l_leg != -1:
				skel.set_bone_pose_rotation(l_leg, Quaternion.from_euler(Vector3(deg_to_rad(118.0), 0, 0)))
			var l_foot = skel.find_bone("mixamorig_LeftFoot")
			if l_foot != -1:
				skel.set_bone_pose_rotation(l_foot, Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0, 0)))

			var r_up_leg = skel.find_bone("mixamorig_RightUpLeg")
			if r_up_leg != -1:
				skel.set_bone_pose_rotation(r_up_leg, Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(16.0), deg_to_rad(-16.0))))
			var r_leg = skel.find_bone("mixamorig_RightLeg")
			if r_leg != -1:
				skel.set_bone_pose_rotation(r_leg, Quaternion.from_euler(Vector3(deg_to_rad(118.0), 0, 0)))
			var r_foot = skel.find_bone("mixamorig_RightFoot")
			if r_foot != -1:
				skel.set_bone_pose_rotation(r_foot, Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0, 0)))

			# 4. Arms reaching forward and down to clip-on handlebars
			# Left Arm & ForeArm
			var l_arm = skel.find_bone("mixamorig_LeftArm")
			if l_arm != -1:
				skel.set_bone_pose_rotation(l_arm, Quaternion.from_euler(Vector3(deg_to_rad(-25.0), deg_to_rad(-40.0), deg_to_rad(45.0))))
			var l_forearm = skel.find_bone("mixamorig_LeftForeArm")
			if l_forearm != -1:
				skel.set_bone_pose_rotation(l_forearm, Quaternion.from_euler(Vector3(deg_to_rad(-60.0), deg_to_rad(12.0), 0)))
			var l_hand = skel.find_bone("mixamorig_LeftHand")
			if l_hand != -1:
				skel.set_bone_pose_rotation(l_hand, Quaternion.from_euler(Vector3(deg_to_rad(-15.0), 0, deg_to_rad(15.0))))

			# Right Arm & ForeArm
			var r_arm = skel.find_bone("mixamorig_RightArm")
			if r_arm != -1:
				skel.set_bone_pose_rotation(r_arm, Quaternion.from_euler(Vector3(deg_to_rad(25.0), deg_to_rad(40.0), deg_to_rad(-45.0))))
			var r_forearm = skel.find_bone("mixamorig_RightForeArm")
			if r_forearm != -1:
				skel.set_bone_pose_rotation(r_forearm, Quaternion.from_euler(Vector3(deg_to_rad(60.0), deg_to_rad(-12.0), 0)))
			var r_hand = skel.find_bone("mixamorig_RightHand")
			if r_hand != -1:
				skel.set_bone_pose_rotation(r_hand, Quaternion.from_euler(Vector3(deg_to_rad(15.0), 0, deg_to_rad(-15.0))))

	for i in range(10):
		await get_tree().process_frame

	var vp = get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		var out_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_chase_cam_rider.png"
		img.save_png(out_path)
		print("Successfully saved screenshot to ", out_path)
	get_tree().quit(0)
