extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)
	
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	root.add_child(level)
	
	var player = level.get_node_or_null("Player")
	var p_cam = player.get_node_or_null("Camera3D") as Camera3D
	if p_cam:
		p_cam.current = true
	
	# Wait for lights, weapons, HUD, and zombies to initialize
	var t = 0.0
	while t < 2.2:
		await process_frame
		t += 0.016
		
	var img1 = get_root().get_texture().get_image()
	var path1 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/dead_target_pro_first_person.png"
	img1.save_png(path1)
	print("SAVED: " + path1)
	
	# Second view: elevated wide angle looking over the barricades down the quarantine corridor
	if p_cam:
		p_cam.position = Vector3(0.0, 3.2, 3.8)
		p_cam.rotation_degrees = Vector3(-18.0, 0.0, 0.0)
	
	t = 0.0
	while t < 0.6:
		await process_frame
		t += 0.016
		
	var img2 = get_root().get_texture().get_image()
	var path2 = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/dead_target_pbr_arena_wide.png"
	img2.save_png(path2)
	print("SAVED: " + path2)
	
	quit(0)
