extends SceneTree

func _init():
	var bike_scene: PackedScene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root.add_child(bike)
	bike._init_rider_soldier()

	# Enter bike
	var dummy = Node3D.new()
	root.add_child(dummy)
	bike.enter_vehicle(dummy)

	var soldier = bike.rider_soldier
	if not soldier:
		print("ERROR: soldier is null")
		quit(1)
		return

	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var anim_player: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	if anim_player:
		anim_player.stop()
		anim_player.active = false

	# Position soldier firmly into Hayabusa racing saddle
	soldier.position = Vector3(0.0, 0.42, -0.18)

	for i in range(skel.get_bone_count()):
		skel.set_bone_pose_rotation(i, Quaternion.IDENTITY)

	# Torso & Head
	var hips = skel.find_bone("mixamorig_Hips")
	if hips != -1: skel.set_bone_pose_rotation(hips, Quaternion(Vector3.RIGHT, deg_to_rad(15.0)))
	var spine = skel.find_bone("mixamorig_Spine")
	if spine != -1: skel.set_bone_pose_rotation(spine, Quaternion(Vector3.RIGHT, deg_to_rad(32.0)))
	var spine1 = skel.find_bone("mixamorig_Spine1")
	if spine1 != -1: skel.set_bone_pose_rotation(spine1, Quaternion(Vector3.RIGHT, deg_to_rad(18.0)))
	var spine2 = skel.find_bone("mixamorig_Spine2")
	if spine2 != -1: skel.set_bone_pose_rotation(spine2, Quaternion(Vector3.RIGHT, deg_to_rad(10.0)))
	var neck = skel.find_bone("mixamorig_Neck")
	if neck != -1: skel.set_bone_pose_rotation(neck, Quaternion(Vector3.RIGHT, deg_to_rad(-16.0)))
	var head = skel.find_bone("mixamorig_Head")
	if head != -1: skel.set_bone_pose_rotation(head, Quaternion(Vector3.RIGHT, deg_to_rad(-24.0)))

	# Legs on footpegs
	var l_up = skel.find_bone("mixamorig_LeftUpLeg")
	if l_up != -1: skel.set_bone_pose_rotation(l_up, Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(-16.0), deg_to_rad(16.0))))
	var l_leg = skel.find_bone("mixamorig_LeftLeg")
	if l_leg != -1: skel.set_bone_pose_rotation(l_leg, Quaternion.from_euler(Vector3(deg_to_rad(118.0), 0, 0)))
	var l_foot = skel.find_bone("mixamorig_LeftFoot")
	if l_foot != -1: skel.set_bone_pose_rotation(l_foot, Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0, 0)))

	var r_up = skel.find_bone("mixamorig_RightUpLeg")
	if r_up != -1: skel.set_bone_pose_rotation(r_up, Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(16.0), deg_to_rad(-16.0))))
	var r_leg = skel.find_bone("mixamorig_RightLeg")
	if r_leg != -1: skel.set_bone_pose_rotation(r_leg, Quaternion.from_euler(Vector3(deg_to_rad(118.0), 0, 0)))
	var r_foot = skel.find_bone("mixamorig_RightFoot")
	if r_foot != -1: skel.set_bone_pose_rotation(r_foot, Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0, 0)))

	# Arms reaching handlebars:
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	var l_hand = skel.find_bone("mixamorig_LeftHand")
	var r_arm = skel.find_bone("mixamorig_RightArm")
	var r_fore = skel.find_bone("mixamorig_RightForeArm")
	var r_hand = skel.find_bone("mixamorig_RightHand")

	# Candidate angles:
	# Left arm:
	if l_arm != -1:
		skel.set_bone_pose_rotation(l_arm, Quaternion.from_euler(Vector3(deg_to_rad(-25.0), deg_to_rad(-40.0), deg_to_rad(45.0))))
	if l_fore != -1:
		skel.set_bone_pose_rotation(l_fore, Quaternion.from_euler(Vector3(deg_to_rad(-60.0), deg_to_rad(12.0), 0.0)))
	if l_hand != -1:
		skel.set_bone_pose_rotation(l_hand, Quaternion.from_euler(Vector3(deg_to_rad(-15.0), 0.0, deg_to_rad(15.0))))

	# Right arm:
	if r_arm != -1:
		skel.set_bone_pose_rotation(r_arm, Quaternion.from_euler(Vector3(deg_to_rad(25.0), deg_to_rad(40.0), deg_to_rad(-45.0))))
	if r_fore != -1:
		skel.set_bone_pose_rotation(r_fore, Quaternion.from_euler(Vector3(deg_to_rad(60.0), deg_to_rad(-12.0), 0.0)))
	if r_hand != -1:
		skel.set_bone_pose_rotation(r_hand, Quaternion.from_euler(Vector3(deg_to_rad(15.0), 0.0, deg_to_rad(-15.0))))

	# Viewport to capture
	var vp = SubViewport.new()
	vp.size = Vector2i(1024, 768)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var env = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.2, 0.22, 0.25)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.8, 0.8, 0.8)
	env.environment = e
	vp.add_child(env)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 45, 0)
	vp.add_child(sun)

	# Camera looking from 3/4 front view:
	var cam = Camera3D.new()
	cam.position = Vector3(1.6, 1.3, -1.8)
	cam.look_at(Vector3(0, 0.75, -0.4), Vector3.UP)
	vp.add_child(cam)

	# Reparent bike to vp
	root.remove_child(bike)
	vp.add_child(bike)

	# Give 5 frames
	for i in range(5):
		await RenderingServer.frame_post_draw

	var img = vp.get_texture().get_image()
	if img:
		img.save_png("/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_visual_pose_front.png")
		print("SUCCESS: saved test_visual_pose_front.png")

	quit(0)
