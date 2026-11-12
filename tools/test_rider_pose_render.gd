extends SceneTree

func _init():
	print("--- Testing Rider Pose Rendering ---")
	var root = Node3D.new()
	get_root().add_child(root)

	# Sun
	var light = DirectionalLight3D.new()
	light.position = Vector3(5, 10, 5)
	light.look_at(Vector3.ZERO, Vector3.UP)
	light.light_energy = 1.5
	root.add_child(light)

	# World environment
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.2, 0.25, 0.3)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.6, 0.6, 0.6)
	env.environment = env_res
	root.add_child(env)

	# Load Hayabusa
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root.add_child(bike)
	bike.position = Vector3.ZERO

	# Camera looking at bike and rider from 3/4 view
	var cam = Camera3D.new()
	cam.position = Vector3(1.5, 1.2, 1.8)
	cam.look_at(Vector3(0.0, 0.7, 0.1), Vector3.UP)
	cam.current = true
	root.add_child(cam)

	# Find soldier
	var soldier = bike.find_child("RiderSoldier", true, false)
	if soldier:
		soldier.visible = true
	print("Soldier found: ", soldier)

	# Let frames render
	for i in range(10):
		await RenderingServer.frame_post_draw

	var vp = get_root().get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		var out_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_current_rider_pose.png"
		img.save_png(out_path)
		print("Saved current rider pose to: ", out_path)

	quit(0)
