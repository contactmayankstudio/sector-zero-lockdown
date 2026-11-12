extends SceneTree

func _init():
	var viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	
	# Light
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, 45, 0)
	light.light_energy = 1.5
	viewport.add_child(light)
	
	var env = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.2, 0.3, 0.4)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 1.0
	env.environment = e
	viewport.add_child(env)
	
	# Camera
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.65, 0)
	cam.current = true
	viewport.add_child(cam)
	
	# Reference zombie target 4 meters in front
	var target = MeshInstance3D.new()
	var cap = CapsuleMesh.new()
	cap.radius = 0.3
	cap.height = 1.8
	target.mesh = cap
	target.position = Vector3(0, 1.65, -4.0)
	viewport.add_child(target)
	
	var wm = Node3D.new()
	wm.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wm)
	
	var tests = [
		{"name": "negev_rot_pos90", "id": "negev_ng7", "rot": Vector3(0, 90, 0), "offset": Vector3(-0.02, -0.06, -0.05), "scale": Vector3(0.048, 0.048, 0.048)},
		{"name": "negev_rot_neg90", "id": "negev_ng7", "rot": Vector3(0, -90, 0), "offset": Vector3(-0.02, -0.06, -0.05), "scale": Vector3(0.048, 0.048, 0.048)},
		{"name": "akx_rot_pos90", "id": "akx_scifi", "rot": Vector3(90, 0, 0), "offset": Vector3(-0.02, -0.15, 0.18), "scale": Vector3(0.80, 0.80, 0.80)},
		{"name": "akx_rot_neg90", "id": "akx_scifi", "rot": Vector3(-90, 0, 0), "offset": Vector3(-0.02, -0.15, 0.18), "scale": Vector3(0.80, 0.80, 0.80)}
	]
	
	var model_res = {
		"negev_ng7": load("res://scenes/weapons/models/negev_ng7.scn"),
		"akx_scifi": load("res://scenes/weapons/models/akx_scifi.scn")
	}
	
	for t in tests:
		for c in wm.get_children():
			c.queue_free()
			
		var res = model_res[t.id]
		var inst = res.instantiate()
		inst.rotation_degrees = t.rot
		inst.scale = t.scale
		inst.position = t.offset
		wm.add_child(inst)
		
		# Wait 2 frames to render
		for f in range(3):
			await RenderingServer.frame_post_draw
			
		var img = viewport.get_texture().get_image()
		var out_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/" + t.name + ".png"
		img.save_png(out_path)
		print("Saved: ", out_path)
		
	quit(0)
