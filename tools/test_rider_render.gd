extends Node

func _ready():
	var vp = SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)

	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.18, 0.22, 0.28)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.7, 0.7, 0.7)
	env.environment = env_res
	vp.add_child(env)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 45, 0)
	sun.light_energy = 1.3
	vp.add_child(sun)

	# Camera - nice 3/4 perspective shot of bike and rider
	var cam = Camera3D.new()
	cam.position = Vector3(1.7, 1.3, 1.8)
	cam.look_at(Vector3(0, 0.65, 0), Vector3.UP)
	vp.add_child(cam)

	# Ground plane for shadows and contrast
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(20, 20)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.35, 0.38)
	ground.mesh = plane_mesh
	ground.material_override = mat
	vp.add_child(ground)

	# Instantiate Bike
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	vp.add_child(bike)

	# Instantiate RealSoldier
	var soldier_scene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	soldier.name = "RiderSoldier"
	
	soldier.scale = Vector3(0.0095, 0.0095, 0.0095)
	# Position onto Hayabusa seat:
	soldier.position = Vector3(0.0, 0.38, -0.15)
	
	var visual_wrapper = bike.get_node_or_null("VisualWrapper")
	if visual_wrapper:
		visual_wrapper.add_child(soldier)
	else:
		bike.add_child(soldier)

	var skel: Skeleton3D = soldier.find_child("Skeleton3D", true, false)
	var anim_player: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	if anim_player:
		anim_player.stop()

	if skel:
		# Reset all bones
		for i in range(skel.get_bone_count()):
			skel.set_bone_pose_rotation(i, Quaternion.IDENTITY)
			skel.set_bone_pose_position(i, skel.get_bone_rest(i).origin)

		# 1. mixamorig_Hips (0) - tilt forward
		var hips_idx = skel.find_bone("mixamorig_Hips")
		if hips_idx != -1:
			skel.set_bone_pose_rotation(hips_idx, Quaternion(Vector3.RIGHT, deg_to_rad(12.0)))

		# 2. Spine - lean forward over tank
		var spine_idx = skel.find_bone("mixamorig_Spine")
		if spine_idx != -1:
			skel.set_bone_pose_rotation(spine_idx, Quaternion(Vector3.RIGHT, deg_to_rad(28.0)))

		var spine1_idx = skel.find_bone("mixamorig_Spine1")
		if spine1_idx != -1:
			skel.set_bone_pose_rotation(spine1_idx, Quaternion(Vector3.RIGHT, deg_to_rad(15.0)))

		# Head tilts back slightly to look straight forward
		var head_idx = skel.find_bone("mixamorig_Head")
		if head_idx != -1:
			skel.set_bone_pose_rotation(head_idx, Quaternion(Vector3.RIGHT, deg_to_rad(-22.0)))

		# 3. Legs onto footpegs
		var l_up_leg = skel.find_bone("mixamorig_LeftUpLeg")
		if l_up_leg != -1:
			skel.set_bone_pose_rotation(l_up_leg, Quaternion.from_euler(Vector3(deg_to_rad(-65.0), deg_to_rad(-18.0), deg_to_rad(18.0))))
		var l_leg = skel.find_bone("mixamorig_LeftLeg")
		if l_leg != -1:
			skel.set_bone_pose_rotation(l_leg, Quaternion.from_euler(Vector3(deg_to_rad(115.0), 0, 0)))
		var l_foot = skel.find_bone("mixamorig_LeftFoot")
		if l_foot != -1:
			skel.set_bone_pose_rotation(l_foot, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0, 0)))

		var r_up_leg = skel.find_bone("mixamorig_RightUpLeg")
		if r_up_leg != -1:
			skel.set_bone_pose_rotation(r_up_leg, Quaternion.from_euler(Vector3(deg_to_rad(-65.0), deg_to_rad(18.0), deg_to_rad(-18.0))))
		var r_leg = skel.find_bone("mixamorig_RightLeg")
		if r_leg != -1:
			skel.set_bone_pose_rotation(r_leg, Quaternion.from_euler(Vector3(deg_to_rad(115.0), 0, 0)))
		var r_foot = skel.find_bone("mixamorig_RightFoot")
		if r_foot != -1:
			skel.set_bone_pose_rotation(r_foot, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0, 0)))

		# 4. Arms reaching forward/down to handlebars
		var l_arm = skel.find_bone("mixamorig_LeftArm")
		if l_arm != -1:
			skel.set_bone_pose_rotation(l_arm, Quaternion.from_euler(Vector3(deg_to_rad(35.0), deg_to_rad(28.0), deg_to_rad(-55.0))))
		var l_forearm = skel.find_bone("mixamorig_LeftForeArm")
		if l_forearm != -1:
			skel.set_bone_pose_rotation(l_forearm, Quaternion.from_euler(Vector3(deg_to_rad(30.0), deg_to_rad(20.0), deg_to_rad(-15.0))))

		var r_arm = skel.find_bone("mixamorig_RightArm")
		if r_arm != -1:
			skel.set_bone_pose_rotation(r_arm, Quaternion.from_euler(Vector3(deg_to_rad(35.0), deg_to_rad(-28.0), deg_to_rad(55.0))))
		var r_forearm = skel.find_bone("mixamorig_RightForeArm")
		if r_forearm != -1:
			skel.set_bone_pose_rotation(r_forearm, Quaternion.from_euler(Vector3(deg_to_rad(30.0), deg_to_rad(-20.0), deg_to_rad(15.0))))

		# 5. Attach Sci-Fi Rifle slung on back
		var back_attach = BoneAttachment3D.new()
		back_attach.bone_name = "mixamorig_Spine2"
		var rifle_scene = load("res://scenes/weapons/models/akx_scifi.scn")
		if rifle_scene:
			var rifle = rifle_scene.instantiate()
			# RealSoldier scale is 0.0095, so attached child inside skeleton is in bone local space (cm units)
			rifle.scale = Vector3(55.0, 55.0, 55.0)
			rifle.position = Vector3(0.0, 8.0, -12.0)
			rifle.rotation_degrees = Vector3(25.0, 140.0, 45.0)
			back_attach.add_child(rifle)
		skel.add_child(back_attach)

	# Wait a few frames for rendering to stabilize
	for i in range(5):
		await RenderingServer.frame_post_draw

	var img = vp.get_texture().get_image()
	if img:
		var path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_soldier_rider_render.png"
		img.save_png(path)
		print("SUCCESS: Saved screenshot to ", path)
	else:
		print("ERROR: Viewport image is null")

	get_tree().quit(0)
