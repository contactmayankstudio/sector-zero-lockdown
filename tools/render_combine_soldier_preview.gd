extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)

	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.2, 0.22, 0.25)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.8, 0.8, 0.8)
	env.environment = env_res
	root.add_child(env)

	var sun = DirectionalLight3D.new()
	sun.light_energy = 1.5
	sun.rotation_degrees = Vector3(-35.0, 45.0, 0.0)
	root.add_child(sun)

	var fill_light = DirectionalLight3D.new()
	fill_light.light_energy = 0.8
	fill_light.rotation_degrees = Vector3(15.0, -135.0, 0.0)
	root.add_child(fill_light)

	var soldier_scene = load("res://scenes/characters/CombineSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	# The mesh center is around y=0, height ~ 1.93m (from -0.95 to +0.98)
	soldier.position = Vector3(0.0, 0.95, 0.0)
	root.add_child(soldier)

	var cam = Camera3D.new()
	cam.position = Vector3(0.0, 1.3, 2.5)
	cam.look_at(Vector3(0.0, 1.0, 0.0))
	cam.current = true
	root.add_child(cam)

	var vp = SubViewport.new()
	vp.size = Vector2i(800, 800)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(vp)
	# Reparent root to viewport for rendering
	root.reparent(vp)

	# Wait 2 frames for render
	for i in range(3):
		await get_root().process_frame

	var img = vp.get_texture().get_image()
	if img:
		img.save_png("/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/combine_soldier_preview.png")
		print("Combine soldier preview saved!")
	else:
		print("Failed to get viewport image")

	quit(0)
