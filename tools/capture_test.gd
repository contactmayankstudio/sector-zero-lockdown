extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	print("--- Testing Image Capture ---")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("Failed to load scene")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Setup SubViewport
	var sv = SubViewport.new()
	sv.size = Vector2i(1280, 720)
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)

	var cam = Camera3D.new()
	sv.add_child(cam)
	# Position camera to look at the highway, dirt, grass, and mountains
	cam.global_position = Vector3(0.0, 4.0, -80.0)
	cam.look_at(Vector3(-40.0, 10.0, -140.0), Vector3.UP)
	cam.current = true

	# Wait a couple of process frames
	for i in range(5):
		await process_frame

	RenderingServer.force_draw(true)

	var tex = sv.get_texture()
	if tex:
		var img = tex.get_image()
		if img and not img.is_empty():
			var p = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_render_subviewport.png"
			var err = img.save_png(p)
			print("Saved screenshot with SubViewport: err=", err, " size=", img.get_size(), " format=", img.get_format())
		else:
			print("img is empty or null")
	else:
		print("tex is null")

	arena.queue_free()
	sv.queue_free()
	quit(0)
