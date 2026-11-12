extends SceneTree

func _init():
	print("[GTA OPEN WORLD TEST] Loading GTAOpenWorld.tscn...")
	var scene = load("res://scenes/world/GTAOpenWorld.tscn")
	if not scene:
		print("[GTA OPEN WORLD TEST] FAILED: Could not load scene!")
		quit(1)
		return
		
	var inst = scene.instantiate()
	root.add_child(inst)
	print("[GTA OPEN WORLD TEST] Instantiated scene successfully. Simulating world streaming & physics...")
	
	# Run 80 frames so chunks, procedural meshes, colliders, and player settle
	var count = 0
	while count < 80:
		await process_frame
		count += 1
		if count <= 10 or count % 20 == 0:
			var pl = inst.get_node_or_null("Player")
			if pl:
				print("[GTA OPEN WORLD TEST] Frame %d | pos: %s | vel: %s | on_floor: %s" % [count, str(pl.global_position), str(pl.velocity), str(pl.is_on_floor())])
			
	var vp = root.get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var path1 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/gta5_open_world_verified.png"
				var path2 = "/home/am/gta5_open_world_verified.png"
				img.save_png(path1)
				img.save_png(path2)
				print("[GTA OPEN WORLD TEST] SUCCESS! Saved live render to: ", path1, " and ", path2)
	quit(0)
