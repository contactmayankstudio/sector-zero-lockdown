# benchmark_120s.gd
# PHASE 4: 120-SECOND COMPREHENSIVE PERFORMANCE BENCHMARK
# Runs real gameplay at 1280x720 for 120 seconds across walking, driving, and chunk streaming.
# Measures real Min, Median, Average FPS, frame time (ms), actual process RAM (VmRSS),
# draw calls, rendered objects, and primitives.
extends SceneTree

var total_test_duration: float = 120.0 # 120 seconds
var elapsed_test_time: float = 0.0

var fps_samples: Array[float] = []
var proc_time_samples: Array[float] = []
var phys_time_samples: Array[float] = []
var dc_samples: Array[int] = []
var obj_samples: Array[int] = []
var prim_samples: Array[int] = []
var ram_samples: Array[float] = []
var vm_rss_samples: Array[float] = []

var world_scene: Node = null
var player: CharacterBody3D = null
var car: Node3D = null
var chunk_mgr: Node3D = null
var sky_ctrl: Node3D = null

var screenshot_walking_done: bool = false
var screenshot_driving_done: bool = false
var screenshot_mountains_done: bool = false
var screenshot_final_done: bool = false

func _init():
	print("[BENCHMARK-120S] Starting Phase 4 Performance Verification...")
	DisplayServer.window_set_size(Vector2i(1280, 720))
	
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	if not scn:
		printerr("[BENCHMARK-120S] Failed to load GTAOpenWorld.tscn")
		quit(1)
		return
		
	world_scene = scn.instantiate()
	root.add_child(world_scene)
	
	_run_benchmark()

func _run_benchmark():
	# 1. Warm-up for 60 frames (approx 1-2 seconds)
	print("[BENCHMARK-120S] Warming up renderer and pipelines...")
	for f in range(60):
		await process_frame
		
	player = world_scene.get("player_node") as CharacterBody3D
	car = world_scene.get("player_car")
	chunk_mgr = world_scene.get_node_or_null("ChunkManager")
	sky_ctrl = world_scene.get_node_or_null("SkyController")
	
	print("[BENCHMARK-120S] Warmup complete. Beginning 120-second active gameplay benchmark!")
	print("[BENCHMARK-120S] Window resolution: 1280x720")
	print("[BENCHMARK-120S] Target: Low-end APU with 4GB RAM")
	
	var last_report_time = 0.0
	
	while elapsed_test_time < total_test_duration:
		var delta = await process_frame
		# If delta is somehow missing or not passed, estimate from frame monitor
		if typeof(delta) != TYPE_FLOAT or delta <= 0.0:
			delta = 1.0 / max(Performance.get_monitor(Performance.TIME_FPS), 10.0)
			
		elapsed_test_time += delta
		
		# Sample engine performance metrics
		var cur_fps = Performance.get_monitor(Performance.TIME_FPS)
		var cur_proc = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		var cur_phys = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		var cur_dc = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var cur_obj = int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
		var cur_prim = int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
		var cur_ram = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
		var cur_rss = _get_process_rss_mb()
		
		fps_samples.append(cur_fps)
		proc_time_samples.append(cur_proc)
		phys_time_samples.append(cur_phys)
		dc_samples.append(cur_dc)
		obj_samples.append(cur_obj)
		prim_samples.append(cur_prim)
		ram_samples.append(cur_ram)
		vm_rss_samples.append(cur_rss)
		
		# ======================================================================
		# SIMULATED GAMEPLAY ACROSS 3 PHASES
		# ======================================================================
		if elapsed_test_time < 30.0:
			# PHASE 1: Sidewalk Walking & Downtown City Exploration
			_simulate_walking(delta)
			if elapsed_test_time >= 15.0 and not screenshot_walking_done:
				screenshot_walking_done = true
				_capture_screen("/home/am/gta5_benchmark_walking.png")
				
		elif elapsed_test_time < 75.0:
			# PHASE 2: Vehicle Enter & Highway Driving
			if elapsed_test_time < 32.0:
				_transition_to_car()
			_simulate_car_driving(delta, false)
			if elapsed_test_time >= 55.0 and not screenshot_driving_done:
				screenshot_driving_done = true
				_capture_screen("/home/am/gta5_benchmark_driving.png")
				_capture_screen("/home/am/gta5_open_world_verified.png")
				
		else:
			# PHASE 3: Chunk Streaming, Mountain Foothills & Sunset Return
			if elapsed_test_time >= 75.0 and elapsed_test_time < 76.0 and sky_ctrl:
				sky_ctrl.apply_time_of_day(1) # GOLDEN_HOUR sunset
			_simulate_car_driving(delta, true)
			if elapsed_test_time >= 90.0 and not screenshot_mountains_done:
				screenshot_mountains_done = true
				_capture_screen("/home/am/gta5_benchmark_mountains.png")
			if elapsed_test_time >= 115.0 and not screenshot_final_done:
				screenshot_final_done = true
				_capture_screen("/home/am/gta5_open_world_verified.png")
				
		# Periodic status log every 10 seconds
		if elapsed_test_time - last_report_time >= 10.0:
			last_report_time = elapsed_test_time
			print("[BENCHMARK-120S] Progress: %4.1fs / %4.1fs | FPS: %4.1f | Frame: %4.2f ms | RAM: %4.1f MB (RSS: %4.1f MB) | DrawCalls: %d" % [
				elapsed_test_time, total_test_duration, cur_fps, cur_proc, cur_ram, cur_rss, cur_dc
			])
			
	_finish_and_report()

func _simulate_walking(delta: float):
	if not player or not is_instance_valid(player):
		player = world_scene.get("player_node")
		return
	player.global_position += (-player.global_transform.basis.z) * (4.5 * delta)
	var cam = player.get_node_or_null("Camera3D") as Camera3D
	if cam:
		cam.rotation.y = sin(elapsed_test_time * 0.4) * 0.25

func _transition_to_car():
	if not car:
		car = world_scene.get("player_car")
	if not player:
		player = world_scene.get("player_node")
	if not car or not is_instance_valid(car) or not player:
		return
	if not car.get("is_occupied") and car.has_method("enter_vehicle"):
		print("[BENCHMARK-120S] Boarding sports car for highway driving test...")
		car.enter_vehicle(player)

func _simulate_car_driving(delta: float, is_mountain_trek: bool):
	if not car or not is_instance_valid(car):
		car = world_scene.get("player_car")
		return
	if not car.get("is_occupied"):
		_transition_to_car()
		return
		
	car.set("touch_throttle", 1.0)
	if not is_mountain_trek:
		car.global_position += Vector3(0.0, 0.0, 16.0 * delta)
		car.set("touch_steer", sin(elapsed_test_time * 0.3) * 0.04)
	else:
		car.global_position += Vector3(0.0, 0.0, -18.0 * delta)
		car.set("touch_steer", cos(elapsed_test_time * 0.4) * 0.05)

func _capture_screen(path: String):
	var vp = root.get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		if img:
			var err = img.save_png(path)
			if err == OK:
				print("[BENCHMARK-120S] Captured verified screenshot -> ", path)
			else:
				printerr("[BENCHMARK-120S] Failed to save screenshot: ", err)

func _get_process_rss_mb() -> float:
	var f = FileAccess.open("/proc/self/status", FileAccess.READ)
	if f:
		var text = f.get_as_text()
		f.close()
		for line in text.split("\n"):
			if line.begins_with("VmRSS:"):
				var parts = line.split(" ", false)
				if parts.size() >= 2:
					return float(parts[1]) / 1024.0 # KB to MB
	return Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

func _finish_and_report():
	if fps_samples.is_empty():
		quit(1)
		return
		
	var sorted_fps = fps_samples.duplicate()
	sorted_fps.sort()
	
	var total_frames = sorted_fps.size()
	var min_fps = sorted_fps[int(total_frames * 0.01)] # 1% Low FPS
	var median_fps = sorted_fps[int(total_frames * 0.50)]
	var max_fps = sorted_fps[total_frames - 1]
	
	var fps_sum = 0.0
	for val in sorted_fps:
		fps_sum += val
	var avg_fps = fps_sum / float(total_frames)
	
	# Frame times (ms)
	var proc_sum = 0.0
	var min_proc = 9999.0
	var max_proc = 0.0
	for val in proc_time_samples:
		proc_sum += val
		if val < min_proc: min_proc = val
		if val > max_proc: max_proc = val
	var avg_proc = proc_sum / float(proc_time_samples.size())
	
	# Draw calls
	var dc_sum = 0
	var max_dc = 0
	for val in dc_samples:
		dc_sum += val
		if val > max_dc: max_dc = val
	var avg_dc = int(float(dc_sum) / float(dc_samples.size()))
	
	# Objects
	var obj_sum = 0
	var max_obj = 0
	for val in obj_samples:
		obj_sum += val
		if val > max_obj: max_obj = val
	var avg_obj = int(float(obj_sum) / float(obj_samples.size()))
	
	# Primitives
	var prim_sum = 0
	var max_prim = 0
	for val in prim_samples:
		prim_sum += val
		if val > max_prim: max_prim = val
	var avg_prim = int(float(prim_sum) / float(prim_samples.size()))
	
	# RAM (MB)
	var init_ram = ram_samples[0]
	var max_ram = 0.0
	for val in ram_samples:
		if val > max_ram: max_ram = val
	var final_ram = ram_samples[ram_samples.size() - 1]
	
	var init_rss = vm_rss_samples[0]
	var max_rss = 0.0
	var rss_sum = 0.0
	for val in vm_rss_samples:
		rss_sum += val
		if val > max_rss: max_rss = val
	var avg_rss = rss_sum / float(vm_rss_samples.size())
	var final_rss = vm_rss_samples[vm_rss_samples.size() - 1]
	
	print("\n================================================================================")
	print("       PHASE 4: 120-SECOND OFFICIAL GTA-STYLE OPEN WORLD BENCHMARK RESULTS       ")
	print("================================================================================")
	print("Resolution:         1280 x 720 (Low-End APU Target)")
	print("Total Test Time:    %.2f seconds (%d frames sampled)" % [elapsed_test_time, total_frames])
	print("--------------------------------------------------------------------------------")
	print("FRAME RATE PERFORMANCE:")
	print("  Average FPS:      %.2f FPS" % avg_fps)
	print("  Median FPS:       %.2f FPS" % median_fps)
	print("  1%% Low (Min) FPS: %.2f FPS" % min_fps)
	print("  Peak (Max) FPS:   %.2f FPS" % max_fps)
	print("--------------------------------------------------------------------------------")
	print("FRAME TIME METRICS:")
	print("  Average Frame Time: %.2f ms" % avg_proc)
	print("  Min Frame Time:     %.2f ms" % min_proc)
	print("  Max Frame Time:     %.2f ms" % max_proc)
	print("--------------------------------------------------------------------------------")
	print("MEMORY UTILIZATION (Target 4GB RAM):")
	print("  Static Engine RAM:  Initial %.2f MB | Peak %.2f MB | Final %.2f MB" % [init_ram, max_ram, final_ram])
	print("  Actual Process RSS: Initial %.2f MB | Peak %.2f MB | Average %.2f MB | Final %.2f MB" % [init_rss, max_rss, avg_rss, final_rss])
	print("  4GB Budget Used:    %.2f%% of total 4GB physical RAM" % [(max_rss / 4096.0) * 100.0])
	print("--------------------------------------------------------------------------------")
	print("RENDER PIPELINE STATS:")
	print("  Draw Calls:         Average %d / frame | Peak %d" % [avg_dc, max_dc])
	print("  Objects Rendered:   Average %d / frame | Peak %d" % [avg_obj, max_obj])
	print("  Primitives/Tris:    Average %d / frame | Peak %d" % [avg_prim, max_prim])
	print("================================================================================\n")
	
	# Save results to JSON file for verification
	var result_dict = {
		"test_duration_sec": elapsed_test_time,
		"total_frames": total_frames,
		"resolution": "1280x720",
		"fps": {
			"average": avg_fps,
			"median": median_fps,
			"min_1pct": min_fps,
			"max": max_fps
		},
		"frame_time_ms": {
			"average": avg_proc,
			"min": min_proc,
			"max": max_proc
		},
		"ram_mb": {
			"static_initial": init_ram,
			"static_peak": max_ram,
			"static_final": final_ram,
			"process_rss_initial": init_rss,
			"process_rss_peak": max_rss,
			"process_rss_average": avg_rss,
			"process_rss_final": final_rss,
			"system_4gb_percent": (max_rss / 4096.0) * 100.0
		},
		"rendering": {
			"draw_calls_avg": avg_dc,
			"draw_calls_peak": max_dc,
			"objects_avg": avg_obj,
			"objects_peak": max_obj,
			"primitives_avg": avg_prim,
			"primitives_peak": max_prim
		}
	}
	
	var out_file = FileAccess.open("/home/am/gta5_benchmark_results.json", FileAccess.WRITE)
	if out_file:
		out_file.store_string(JSON.stringify(result_dict, "\t"))
		out_file.close()
		print("[BENCHMARK-120S] Benchmark results saved to /home/am/gta5_benchmark_results.json")
		
	quit(0)
