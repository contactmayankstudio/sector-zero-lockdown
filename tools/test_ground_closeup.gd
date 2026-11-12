extends SceneTree

func _init():
	var s = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = s.instantiate()
	get_root().add_child(arena)

	for i in range(10):
		await RenderingServer.frame_post_draw

	var cam = Camera3D.new()
	arena.add_child(cam)
	# Look directly down at the valley floor ground next to the highway
	cam.global_position = Vector3(-35.0, 6.0, -80.0)
	cam.look_at(Vector3(-35.0, 0.0, -80.0), Vector3.FORWARD)
	cam.current = true

	for i in range(15):
		await RenderingServer.frame_post_draw

	var vp = get_root().get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				img.save_png("/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/test_ground_closeup.png")
				print("Saved test_ground_closeup.png")
	arena.queue_free()
	quit()
