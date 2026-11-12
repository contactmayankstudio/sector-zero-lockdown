extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)
	
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	root.add_child(level)
	
	for i in range(30):
		await process_frame
		
	# Let's inspect Performance monitor metrics
	print("--- PERFORMANCE METRICS ---")
	print("FPS: ", Performance.get_monitor(Performance.TIME_FPS))
	print("Process time: ", Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, " ms")
	print("Physics time: ", Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0, " ms")
	print("Draw calls: ", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	print("Total objects: ", Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
	print("Total primitives: ", Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	print("Video mem (MB): ", Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0))
	quit(0)
