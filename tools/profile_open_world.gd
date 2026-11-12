extends SceneTree

func _init():
	print("[PROFILER] Loading GTAOpenWorld.tscn...")
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	if not scn:
		print("[PROFILER] Failed to load scene")
		quit(1)
		return
		
	var inst = scn.instantiate()
	root.add_child(inst)
	
	# Warm up for 60 frames
	for f in range(60):
		await process_frame
		
	# Profile 30 frames
	var fps_sum = 0.0
	var dc_sum = 0.0
	var obj_sum = 0.0
	var prim_sum = 0.0
	var proc_sum = 0.0
	var phys_sum = 0.0
	var count = 30
	
	for f in range(count):
		await process_frame
		fps_sum += Performance.get_monitor(Performance.TIME_FPS)
		dc_sum += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		obj_sum += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		prim_sum += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		proc_sum += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		phys_sum += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		
	var mem_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	print("\n========== PROFILING RESULTS ==========")
	print("Average FPS:       %.1f FPS" % [fps_sum / count])
	print("Frame Process:     %.2f ms" % [proc_sum / count])
	print("Physics Process:   %.2f ms" % [phys_sum / count])
	print("Draw Calls/frame:  %d" % [int(dc_sum / count)])
	print("Objects/frame:     %d" % [int(obj_sum / count)])
	print("Primitives/frame:  %d" % [int(prim_sum / count)])
	print("Static RAM:        %.2f MB" % [mem_mb])
	print("=======================================\n")
	quit(0)
