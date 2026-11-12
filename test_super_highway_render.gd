extends SceneTree

func _init():
	print("[GTA5 ROAD TEST] Starting live test for ZombieNightHighway...")
	var scene = load("res://scenes/environments/ZombieNightHighway.tscn")
	if not scene:
		print("[GTA5 ROAD TEST] FAILED: Could not load scene!")
		quit(1)
		return
	var inst = scene.instantiate()
	root.add_child(inst)
	
	# Give 75 frames for physics, spawns, and camera to settle
	var count = 0
	while count < 75:
		await process_frame
		count += 1
		
	var vp = root.get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/gta5_highway_render_verified.png"
				img.save_png(path)
				print("[GTA5 ROAD TEST] SUCCESS! Saved live GTA 5 render to: ", path)
	quit(0)
