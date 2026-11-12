extends SceneTree

func _init():
	var env_scenes = [
		"res://scenes/environments/AirportTerminal.tscn",
		"res://scenes/environments/AirportServiceRoad.tscn",
		"res://scenes/environments/UrbanStreet.tscn",
		"res://scenes/environments/RailwayStation.tscn",
		"res://scenes/environments/AbandonedTrain.tscn",
		"res://scenes/environments/DarkIndustrial.tscn",
		"res://scenes/environments/FinalLockdown.tscn"
	]
	
	call_deferred("_render_envs", root, env_scenes)

func _render_envs(win: Window, scenes: Array):
	for scn_path in scenes:
		for c in win.get_children():
			c.queue_free()
			
		var res = load(scn_path)
		var inst = res.instantiate()
		win.add_child(inst)
		
		# Find the player or active camera in the scene
		var cam: Camera3D = null
		var cams = inst.find_children("*", "Camera3D", true, false)
		if not cams.is_empty():
			cam = cams[0]
			cam.current = true
		else:
			cam = Camera3D.new()
			cam.position = Vector3(0, 1.7, 0)
			cam.current = true
			win.add_child(cam)
			
		for f in range(6):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var base_name = scn_path.get_file().get_basename()
		var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/env_%s.png" % base_name
		img.save_png(fname)
		print("Rendered environment: ", base_name, " -> ", fname)
		
	quit(0)
