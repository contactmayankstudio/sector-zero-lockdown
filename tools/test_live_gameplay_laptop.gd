extends SceneTree

func _init():
	var ps = load("res://scenes/environments/AirportServiceRoad.tscn")
	var inst = ps.instantiate()
	root.add_child(inst)
	call_deferred("_test_gameplay", inst)

func _test_gameplay(env_node: Node3D):
	# Wait for gameplay to initialize
	for f in range(10):
		await RenderingServer.frame_post_draw
		
	var player = env_node.find_child("Player", true, false)
	if player:
		print("Player found: ", player.name)
		# Trigger fire event
		if player.has_method("fire"):
			player.fire()
			print("Player fired weapon!")
			
	for f in range(6):
		await RenderingServer.frame_post_draw
		
	var img = root.get_texture().get_image()
	var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/laptop_live_gameplay_verified.png"
	img.save_png(fname)
	print("Saved live gameplay screenshot on laptop: ", fname)
	quit(0)
