extends SceneTree

func _init():
	print("--- PROFILING CITY CAR ZOMBIE ARENA ON HEADLESS ---")
	var t0 = Time.get_ticks_msec()
	var arena_scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var t_load = Time.get_ticks_msec() - t0
	if not arena_scn:
		print("FAILED to load arena scene")
		quit(1)
		return

	var inst = arena_scn.instantiate()
	root.add_child(inst)
	var t_inst = Time.get_ticks_msec() - t0 - t_load

	# Simulate 120 frames (approx 2 seconds of gameplay)
	for i in range(120):
		await process_frame

	var mem_static = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	var mem_max = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / (1024.0 * 1024.0)
	var nodes_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var res_count = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var primitives = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var os_mem = OS.get_static_memory_usage() / (1024.0 * 1024.0)

	print("========================================")
	print("ARENA PERFORMANCE & MEMORY METRICS:")
	print("Load Time: %d ms, Instantiation Time: %d ms" % [t_load, t_inst])
	print("Static Memory: %.2f MB (Max: %.2f MB)" % [mem_static, mem_max])
	print("OS Static Memory: %.2f MB" % [os_mem])
	print("Active Nodes in Tree: %d" % [nodes_count])
	print("Resources Loaded: %d" % [res_count])
	print("Draw Calls: %d" % [draw_calls])
	print("Primitives (triangles): %d" % [primitives])
	print("========================================")

	# Clean teardown
	inst.queue_free()
	for i in range(5):
		await process_frame

	var mem_after = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	print("Memory after cleanup: %.2f MB (Leak delta: %.2f MB)" % [mem_after, mem_after - mem_static])
	quit(0)
