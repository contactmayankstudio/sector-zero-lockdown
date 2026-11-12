extends Node3D

func _ready():
	print("--- Starting Rider Studio Render ---")
	
	# Light
	var sun = DirectionalLight3D.new()
	add_child(sun)
	sun.look_at_from_position(Vector3(5, 8, 5), Vector3.ZERO, Vector3.UP)
	sun.light_energy = 1.8
	sun.shadow_enabled = true
	
	# Env
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.4, 0.45, 0.5)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.7, 0.7, 0.7)
	env.environment = env_res
	add_child(env)

	# Ground StaticBody
	var sb = StaticBody3D.new()
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(50, 1, 50)
	col.shape = box
	col.position = Vector3(0, -0.5, 0)
	sb.add_child(col)
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(50, 50)
	ground.mesh = plane_mesh
	var g_mat = StandardMaterial3D.new()
	g_mat.albedo_color = Color(0.2, 0.22, 0.25)
	ground.set_surface_override_material(0, g_mat)
	sb.add_child(ground)
	add_child(sb)

	# Bike
	var bike_scn = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scn.instantiate()
	bike.name = "DrivableBike"
	add_child(bike)
	bike.position = Vector3(0, 0.05, 0)
	bike.set_physics_process(false) # Prevent falling before camera captures

	# Wait a frame for bike _ready()
	await get_tree().process_frame
	await get_tree().process_frame

	var rider = bike.find_child("RiderSoldier", true, false)
	print("Found rider: ", rider, " at pos: ", (rider.global_position if rider else Vector3.ZERO))
	if rider:
		rider.visible = true

	# Camera 1: Side Profile / 3/4 beauty view showing hands on handlebars
	var cam = Camera3D.new()
	cam.name = "StudioCam"
	add_child(cam)
	cam.look_at_from_position(Vector3(1.6, 1.2, 1.2), Vector3(0.0, 0.75, 0.0), Vector3.UP)
	cam.current = true

	# Wait frames to render
	for i in range(10):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw

	var vp = get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		var out_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/studio_rider_pose.png"
		img.save_png(out_path)
		print("Saved studio rider pose to: ", out_path)

	get_tree().quit(0)
