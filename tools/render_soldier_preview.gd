extends SceneTree
func _init():
	var root = get_root()
	var vp = SubViewport.new()
	vp.size = Vector2i(640, 480)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var cam = Camera3D.new()
	cam.position = Vector3(0.0, 1.3, 2.5)
	cam.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)
	vp.add_child(cam)

	var light = DirectionalLight3D.new()
	light.position = Vector3(2, 4, 3)
	light.look_at(Vector3.ZERO, Vector3.UP)
	vp.add_child(light)

	var env = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.2, 0.3, 0.4)
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 0.8
	env.environment = e
	vp.add_child(env)

	var soldier_res = load("res://scenes/characters/RealSoldier.scn")
	var soldier = soldier_res.instantiate()
	soldier.position = Vector3.ZERO
	vp.add_child(soldier)

	var ap = soldier.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap and ap.has_animation("RifleAimIdle"):
		ap.play("RifleAimIdle")
		ap.advance(0.1)

	await process_frame
	await process_frame

	var img = vp.get_texture().get_image()
	img.save_png("/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_soldier_preview.png")
	print("Saved preview to test_soldier_preview.png")
	quit(0)
