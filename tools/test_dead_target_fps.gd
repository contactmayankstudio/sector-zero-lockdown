extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)
	
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	root.add_child(level)
	
	# Warm up for 1 second
	var t = 0.0
	while t < 1.0:
		await process_frame
		t += 0.016
		
	# Measure FPS over 60 frames
	var start_time = Time.get_ticks_usec()
	for i in range(60):
		await process_frame
	var elapsed = (Time.get_ticks_usec() - start_time) / 1000000.0
	var fps = 60.0 / elapsed
	print(">>> CURRENT DEAD TARGET FPS (All 7 lights): ", fps)
	
	# Test disabling extra point/spot lights
	var lights = level.find_children("*", "Light3D", true, false)
	print("Found lights count: ", lights.size())
	for l in lights:
		if l is not DirectionalLight3D:
			l.visible = false
			
	for i in range(10):
		await process_frame
		
	start_time = Time.get_ticks_usec()
	for i in range(60):
		await process_frame
	elapsed = (Time.get_ticks_usec() - start_time) / 1000000.0
	fps = 60.0 / elapsed
	print(">>> DEAD TARGET FPS (Directional Light only): ", fps)
	
	quit(0)
