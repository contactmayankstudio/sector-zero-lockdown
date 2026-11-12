extends SceneTree

func _init():
	print("[GTA5 MISSION TEST] Starting live test for Mission 1-1 / AirportTerminal...")
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	if not scene:
		print("[GTA5 MISSION TEST] FAILED: Could not load AirportTerminal.tscn!")
		quit(1)
		return
	var inst = scene.instantiate()
	root.add_child(inst)
	
	# Give 60 frames for lighting and environment to settle
	var count = 0
	while count < 60:
		await process_frame
		count += 1
		
	var vp = root.get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/gta5_mission_render_verified.png"
				img.save_png(path)
				print("[GTA5 MISSION TEST] SUCCESS! Saved live GTA 5 mission render to: ", path)
	quit(0)
