extends SceneTree

func _init():
	print("Capturing AirportServiceRoad...")
	var scene = load("res://scenes/environments/AirportServiceRoad.tscn")
	if not scene:
		print("ERROR: Failed to load AirportServiceRoad.tscn")
		quit(1)
		return
		
	var inst = scene.instantiate()
	root.add_child(inst)
	
	# Allow frames to render
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("/home/am/targetkill/test_real_m2_capture.png")
	print("Saved updated screenshot to /home/am/targetkill/test_real_m2_capture.png")
	quit(0)
