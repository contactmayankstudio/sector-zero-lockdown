extends Node3D

var soldier_skel: Skeleton3D = null
var soldier_node: Node3D = null

func _ready():
	print("--- Starting Tuned Rider Studio Test 5 (ARMS DOWN TO HANDLEBARS) ---")
	
	# Sun
	var sun = DirectionalLight3D.new()
	add_child(sun)
	sun.look_at_from_position(Vector3(3, 6, 3), Vector3.ZERO, Vector3.UP)
	sun.light_energy = 1.7
	sun.shadow_enabled = true

	# Env
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.35, 0.40, 0.45)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.65, 0.65, 0.65)
	env.environment = env_res
	add_child(env)

	# Bike
	var bike_scn = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scn.instantiate()
	bike.name = "DrivableBike"
	add_child(bike)
	bike.position = Vector3(0, 0, 0)
	bike.set_physics_process(false)

	# Wait a frame for bike _ready()
	await get_tree().process_frame

	soldier_node = bike.find_child("RiderSoldier", true, false)
	if not soldier_node:
		var s_scn = load("res://scenes/characters/RealSoldier.scn")
		soldier_node = s_scn.instantiate()
		soldier_node.name = "RiderSoldier"
		var vw = bike.find_child("VisualWrapper", true, false)
		if vw:
			vw.add_child(soldier_node)
		else:
			bike.add_child(soldier_node)

	soldier_node.visible = true

	# Link skeleton to all meshes
	for child in soldier_node.find_children("*", "MeshInstance3D"):
		child.skeleton = NodePath("..")

	var anim: AnimationPlayer = soldier_node.find_child("AnimationPlayer", true, false)
	if anim:
		anim.stop()
		anim.active = false

	soldier_skel = soldier_node.find_child("Skeleton3D", true, false)
	soldier_node.position = Vector3(0.0, -0.42, -0.16)

	# Camera: 3/4 beauty view showing hands on handlebars
	var cam = Camera3D.new()
	add_child(cam)
	cam.look_at_from_position(Vector3(1.4, 1.15, 1.3), Vector3(0.0, 0.65, 0.1), Vector3.UP)
	cam.current = true

	# Wait frames to render
	for i in range(12):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw

	var vp = get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		var out_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/tuned_rider_pose_test5.png"
		img.save_png(out_path)
		print("SUCCESS: Saved tuned rider pose test 5 to: ", out_path)

	get_tree().quit(0)

func _process(_delta):
	if not soldier_skel:
		return
	var skel = soldier_skel

	# 1. Hips
	var hips = skel.find_bone("mixamorig_Hips")
	if hips != -1:
		skel.set_bone_pose_rotation(hips, Quaternion(Vector3.RIGHT, deg_to_rad(22.0)))

	# 2. Spine - lean forward over fuel tank
	var spine = skel.find_bone("mixamorig_Spine")
	if spine != -1:
		skel.set_bone_pose_rotation(spine, Quaternion(Vector3.RIGHT, deg_to_rad(30.0)))
	var spine1 = skel.find_bone("mixamorig_Spine1")
	if spine1 != -1:
		skel.set_bone_pose_rotation(spine1, Quaternion(Vector3.RIGHT, deg_to_rad(20.0)))
	var spine2 = skel.find_bone("mixamorig_Spine2")
	if spine2 != -1:
		skel.set_bone_pose_rotation(spine2, Quaternion(Vector3.RIGHT, deg_to_rad(14.0)))

	# 3. Head - look up/forward
	var neck = skel.find_bone("mixamorig_Neck")
	if neck != -1:
		skel.set_bone_pose_rotation(neck, Quaternion(Vector3.RIGHT, deg_to_rad(-22.0)))
	var head = skel.find_bone("mixamorig_Head")
	if head != -1:
		skel.set_bone_pose_rotation(head, Quaternion(Vector3.RIGHT, deg_to_rad(-32.0)))

	# 4. Legs - straddle bike and bend back to footpegs
	var l_up = skel.find_bone("mixamorig_LeftUpLeg")
	if l_up != -1:
		skel.set_bone_pose_rotation(l_up, Quaternion.from_euler(Vector3(deg_to_rad(-70.0), deg_to_rad(-16.0), deg_to_rad(22.0))))
	var l_leg = skel.find_bone("mixamorig_LeftLeg")
	if l_leg != -1:
		skel.set_bone_pose_rotation(l_leg, Quaternion.from_euler(Vector3(deg_to_rad(120.0), 0.0, 0.0)))
	var l_foot = skel.find_bone("mixamorig_LeftFoot")
	if l_foot != -1:
		skel.set_bone_pose_rotation(l_foot, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0.0, deg_to_rad(-10.0))))

	var r_up = skel.find_bone("mixamorig_RightUpLeg")
	if r_up != -1:
		skel.set_bone_pose_rotation(r_up, Quaternion.from_euler(Vector3(deg_to_rad(-70.0), deg_to_rad(16.0), deg_to_rad(-22.0))))
	var r_leg = skel.find_bone("mixamorig_RightLeg")
	if r_leg != -1:
		skel.set_bone_pose_rotation(r_leg, Quaternion.from_euler(Vector3(deg_to_rad(120.0), 0.0, 0.0)))
	var r_foot = skel.find_bone("mixamorig_RightFoot")
	if r_foot != -1:
		skel.set_bone_pose_rotation(r_foot, Quaternion.from_euler(Vector3(deg_to_rad(-20.0), 0.0, deg_to_rad(10.0))))

	# 5. Arms - ROTATE DOWN AND FORWARD TO HANDLEBARS!
	# Left Arm:
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	if l_arm != -1:
		skel.set_bone_pose_rotation(l_arm, Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(-15.0), deg_to_rad(-35.0))))
	var l_fore = skel.find_bone("mixamorig_LeftForeArm")
	if l_fore != -1:
		skel.set_bone_pose_rotation(l_fore, Quaternion.from_euler(Vector3(deg_to_rad(-50.0), deg_to_rad(10.0), deg_to_rad(-15.0))))
	var l_hand = skel.find_bone("mixamorig_LeftHand")
	if l_hand != -1:
		skel.set_bone_pose_rotation(l_hand, Quaternion.from_euler(Vector3(deg_to_rad(-15.0), deg_to_rad(0.0), deg_to_rad(20.0))))

	# Right Arm:
	var r_arm = skel.find_bone("mixamorig_RightArm")
	if r_arm != -1:
		skel.set_bone_pose_rotation(r_arm, Quaternion.from_euler(Vector3(deg_to_rad(68.0), deg_to_rad(15.0), deg_to_rad(-35.0))))
	var r_fore = skel.find_bone("mixamorig_RightForeArm")
	if r_fore != -1:
		skel.set_bone_pose_rotation(r_fore, Quaternion.from_euler(Vector3(deg_to_rad(50.0), deg_to_rad(-10.0), deg_to_rad(15.0))))
	var r_hand = skel.find_bone("mixamorig_RightHand")
	if r_hand != -1:
		skel.set_bone_pose_rotation(r_hand, Quaternion.from_euler(Vector3(deg_to_rad(15.0), deg_to_rad(0.0), deg_to_rad(-20.0))))
