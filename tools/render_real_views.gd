extends SceneTree

func _init():
	call_deferred("_run")

func _run():
	print("=== Rendering Real In-Game Views ===")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("ERROR: Scene failed to load")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Wait 10 frames for everything to settle
	for i in range(10):
		await process_frame

	var vp = get_root().get_viewport()
	if not vp:
		print("ERROR: No viewport")
		quit(1)
		return

	# Setup a dedicated high-res photo camera
	var cam = Camera3D.new()
	cam.name = "PhotoInspectorCam"
	arena.add_child(cam)
	cam.current = true

	var shots = [
		{
			"name": "view1_highway_and_foothills",
			"pos": Vector3(0.0, 2.5, -90.0),
			"look": Vector3(-45.0, 8.0, -150.0)
		},
		{
			"name": "view2_dirt_and_grass_transition",
			"pos": Vector3(-15.0, 3.0, -110.0),
			"look": Vector3(-35.0, 1.0, -140.0)
		},
		{
			"name": "view3_mountain_cliffs_and_trees",
			"pos": Vector3(-30.0, 5.0, -130.0),
			"look": Vector3(-90.0, 22.0, -180.0)
		},
		{
			"name": "view4_car_and_bike_showroom",
			"pos": Vector3(3.5, 2.2, -100.0),
			"look": Vector3(-2.0, 1.2, -115.0)
		}
	]

	for s in shots:
		cam.global_position = s["pos"]
		cam.look_at(s["look"], Vector3.UP)
		
		# Render 8 frames so auto-exposure and lighting are clean
		for f in range(8):
			await process_frame

		RenderingServer.force_draw(true)
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img and not img.is_empty():
				var p = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/" + s["name"] + ".png"
				var err = img.save_png(p)
				print("Saved ", s["name"], ": err=", err, " size=", img.get_size())
			else:
				print("Empty img for ", s["name"])
		else:
			print("No texture for ", s["name"])

	print("=== All Views Rendered Successfully ===")
	arena.queue_free()
	quit(0)
