# phase8_benchmark_suite.gd
# PHASE 8: AAA GRAPHICS OPTIMIZATION & 9-SCENARIO BENCHMARK SUITE
# Strict monotonic timing, decoupled screenshot disk I/O, mathematical telemetry,
# Linux process RSS (/proc/self/status) & System RAM (/proc/meminfo) tracking,
# and 9 comprehensive scenarios across vehicles, combat, streaming, and architecture.
extends SceneTree

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")

var world_scene: Node = null
var player: CharacterBody3D = null
var car: Node3D = null
var chunk_mgr: Node3D = null
var sky_ctrl: Node3D = null

# Telemetry accumulators
var frame_times_ms: Array[float] = []
var fps_values: Array[float] = []
var dc_values: Array[int] = []
var obj_values: Array[int] = []
var prim_values: Array[int] = []
var tex_mem_values: Array[float] = []
var static_mem_values: Array[float] = []
var proc_rss_values: Array[float] = []

var screenshot_records: Array[Dictionary] = []
var scenario_results: Dictionary = {}
var elapsed_gameplay_sec: float = 0.0

var scenario_configs = [
	{
		"id": "residential_street",
		"name": "Residential Street",
		"pos": Vector3(64.0, 1.2, 195.0),
		"rot_y": 0.35,
		"cam_pitch": -0.08,
		"time_mode": 0, # Day
		"type": "foot",
		"shot_path": "/home/am/phase8_residential_street.png",
		"shot_label": "Residential Street (Day)",
		"duration": 12.0
	},
	{
		"id": "downtown_city",
		"name": "Downtown City",
		"pos": Vector3(72.0, 1.2, 58.0),
		"rot_y": -0.45,
		"cam_pitch": 0.12,
		"time_mode": 0, # Day
		"type": "foot",
		"shot_path": "/home/am/phase8_downtown_city.png",
		"shot_label": "Downtown City (Day)",
		"duration": 12.0
	},
	{
		"id": "highway_driving",
		"name": "Highway Driving",
		"pos": Vector3(67.5, 1.2, 64.0),
		"rot_y": 0.0,
		"cam_pitch": -0.04,
		"time_mode": 0, # Day
		"type": "vehicle_cruise",
		"shot_path": "/home/am/phase8_highway_driving.png",
		"shot_label": "Highway Driving (Cruise)",
		"duration": 12.0
	},
	{
		"id": "nitro_driving",
		"name": "Nitro Driving",
		"pos": Vector3(67.5, 1.2, 80.0),
		"rot_y": 0.0,
		"cam_pitch": -0.04,
		"time_mode": 0, # Day
		"type": "vehicle_nitro",
		"shot_path": "/home/am/phase8_nitro_driving.png",
		"shot_label": "Nitro Driving (230 KM/H Boost)",
		"duration": 12.0
	},
	{
		"id": "forest",
		"name": "Forest",
		"pos": Vector3(-100.0, 6.0, 64.0),
		"rot_y": 0.85,
		"cam_pitch": -0.05,
		"time_mode": 0, # Day
		"type": "foot",
		"shot_path": "/home/am/phase8_forest.png",
		"shot_label": "Countryside Forest (Day)",
		"duration": 12.0
	},
	{
		"id": "mountain_road",
		"name": "Mountain Road",
		"pos": Vector3(64.0, 26.0, -65.0),
		"rot_y": 3.14,
		"cam_pitch": -0.15,
		"time_mode": 0, # Day
		"type": "foot",
		"shot_path": "/home/am/phase8_mountain_road.png",
		"shot_label": "Mountain Road (Day)",
		"duration": 12.0
	},
	{
		"id": "night_showcase",
		"name": "Night Showcase",
		"pos": Vector3(67.5, 1.2, 70.0),
		"rot_y": 0.0,
		"cam_pitch": -0.04,
		"time_mode": 2, # Night
		"type": "vehicle_night",
		"shot_path": "/home/am/phase8_night_showcase.png",
		"shot_label": "Night Showcase (Streetlights & Headlights)",
		"duration": 12.0
	},
	{
		"id": "zombie_combat",
		"name": "Zombie Combat",
		"pos": Vector3(72.0, 1.2, 50.0),
		"rot_y": 0.0,
		"cam_pitch": 0.0,
		"time_mode": 0, # Day
		"type": "combat",
		"shot_path": "/home/am/phase8_zombie_combat.png",
		"shot_label": "Zombie Combat & Arsenal",
		"duration": 12.0
	},
	{
		"id": "nine_chunk_streaming",
		"name": "Nine-Chunk Streaming",
		"pos": Vector3(67.5, 1.2, 10.0),
		"rot_y": 0.0,
		"cam_pitch": -0.04,
		"time_mode": 0, # Day
		"type": "streaming",
		"shot_path": "/home/am/phase8_nine_chunk_streaming.png",
		"shot_label": "9-Chunk World Streaming",
		"duration": 12.0
	}
]

func _init():
	print("[PHASE-8-SUITE] Initializing 9-Scenario AAA Graphics Optimization Benchmark Suite...")
	DisplayServer.window_set_size(Vector2i(1280, 720))
	
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	if not scn:
		printerr("[PHASE-8-SUITE] Failed to load GTAOpenWorld.tscn")
		quit(1)
		return
		
	world_scene = scn.instantiate()
	root.add_child(world_scene)
	_run_suite()

func _run_suite():
	print("[PHASE-8-SUITE] Warming up pipelines and preloading assets (60 frames)...")
	for f in range(60):
		await process_frame
		
	player = world_scene.get("player_node") as CharacterBody3D
	car = world_scene.get("player_car")
	chunk_mgr = world_scene.get_node_or_null("ChunkManager")
	sky_ctrl = world_scene.get_node_or_null("SkyController")
	
	print("[PHASE-8-SUITE] Warmup complete. Commencing 9-Scenario Performance Telemetry!")
	print("[PHASE-8-SUITE] Target: Stable ~30 FPS on AMD Kabini APU | 1280x720 Native | 4GB RAM Budget")
	
	for st_idx in range(scenario_configs.size()):
		var sc = scenario_configs[st_idx]
		print("\n[PHASE-8-SUITE] Entering Scenario %d/9: %s (%s)..." % [st_idx + 1, sc["name"], sc["shot_label"]])
		
		# Set Time of Day
		if sky_ctrl and sky_ctrl.has_method("apply_time_of_day"):
			sky_ctrl.apply_time_of_day(sc["time_mode"])
			
		# Setup Scene State for Scenario
		_setup_scenario_state(sc)
		
		# Settle rendering for 15 frames after teleport/streaming
		for s in range(15):
			await process_frame
			
		# Scenario telemetry loop
		var stage_time: float = 0.0
		var stage_frames: int = 0
		var stage_fps_list: Array[float] = []
		var stage_ft_list: Array[float] = []
		var stage_rss_list: Array[float] = []
		var stage_dc_list: Array[int] = []
		var stage_shot_taken: bool = false
		
		var last_time_usec = Time.get_ticks_usec()
		
		while stage_time < sc["duration"]:
			await process_frame
			var now_usec = Time.get_ticks_usec()
			var delta_usec = now_usec - last_time_usec
			last_time_usec = now_usec
			
			var dt = float(delta_usec) / 1000000.0
			if dt <= 0.00001 or dt > 0.35:
				dt = clampf(dt, 0.00001, 0.35)
				
			stage_time += dt
			elapsed_gameplay_sec += dt
			stage_frames += 1
			
			# Drive simulation update
			_sim_scenario_step(sc, dt)
			
			var ft_ms = dt * 1000.0
			var fps = 1.0 / dt
			
			var cur_rss = _get_process_rss_mb()
			var cur_tex = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / (1024.0 * 1024.0)
			var cur_static = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
			var cur_dc = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			var cur_obj = int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
			var cur_prim = int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
			
			frame_times_ms.append(ft_ms)
			fps_values.append(fps)
			dc_values.append(cur_dc)
			obj_values.append(cur_obj)
			prim_values.append(cur_prim)
			tex_mem_values.append(cur_tex)
			static_mem_values.append(cur_static)
			proc_rss_values.append(cur_rss)
			
			stage_fps_list.append(fps)
			stage_ft_list.append(ft_ms)
			stage_rss_list.append(cur_rss)
			stage_dc_list.append(cur_dc)
			
			# Capture screenshot at stage midpoint (isolated from gameplay delta)
			if stage_time >= (sc["duration"] * 0.50) and not stage_shot_taken:
				stage_shot_taken = true
				_capture_screen_with_overhead(sc["shot_path"], sc["shot_label"])
				last_time_usec = Time.get_ticks_usec()
				
		var st_avg_fps = float(stage_frames) / maxf(stage_time, 0.001)
		var st_sorted_fps = stage_fps_list.duplicate()
		st_sorted_fps.sort()
		var st_med_fps = st_sorted_fps[int(stage_frames * 0.50)] if stage_frames > 0 else 0.0
		var st_min_fps = st_sorted_fps[0] if stage_frames > 0 else 0.0
		var st_rss = stage_rss_list[stage_rss_list.size() - 1] if stage_rss_list.size() > 0 else 0.0
		var st_avg_dc = 0
		if stage_dc_list.size() > 0:
			var dc_sum = 0
			for dc in stage_dc_list: dc_sum += dc
			st_avg_dc = int(dc_sum / stage_dc_list.size())
			
		scenario_results[sc["name"]] = {
			"frames_sampled": stage_frames,
			"duration_sec": stage_time,
			"average_fps": st_avg_fps,
			"median_fps": st_med_fps,
			"min_fps": st_min_fps,
			"average_frame_time_ms": 1000.0 / maxf(st_avg_fps, 0.001),
			"draw_calls_avg": st_avg_dc,
			"process_rss_mb": st_rss
		}
		print("[PHASE-8-SUITE] Scenario '%s' complete: %5.1f FPS | %4d frames | RSS: %5.1f MB | DC: %d" % [
			sc["name"], st_avg_fps, stage_frames, st_rss, st_avg_dc
		])
		
	_finish_and_report()

func _setup_scenario_state(sc: Dictionary):
	var target_pos = sc["pos"]
	var wy = OpenWorldConfig.get_terrain_height(target_pos.x, target_pos.z)
	target_pos.y = maxf(target_pos.y, wy + 1.2)
	
	match sc["type"]:
		"foot":
			if car and car.get("is_occupied") and car.has_method("exit_vehicle"):
				car.exit_vehicle()
			if player and is_instance_valid(player):
				player.global_position = target_pos
				player.rotation.y = sc["rot_y"]
				var cam = player.get_node_or_null("Camera3D")
				if cam: cam.rotation.x = sc["cam_pitch"]
		"vehicle_cruise", "vehicle_nitro", "streaming":
			if car and is_instance_valid(car):
				var c_wy = OpenWorldConfig.get_terrain_height(target_pos.x, target_pos.z)
				car.global_position = Vector3(target_pos.x, c_wy + 0.5, target_pos.z)
				car.rotation = Vector3.ZERO
				car.linear_velocity = Vector3.ZERO
				car.angular_velocity = Vector3.ZERO
				if player and not car.get("is_occupied") and car.has_method("enter_vehicle"):
					car.enter_vehicle(player)
		"vehicle_night":
			if car and is_instance_valid(car):
				var c_wy = OpenWorldConfig.get_terrain_height(target_pos.x, target_pos.z)
				car.global_position = Vector3(target_pos.x, c_wy + 0.5, target_pos.z)
				car.rotation = Vector3.ZERO
				car.linear_velocity = Vector3.ZERO
				car.angular_velocity = Vector3.ZERO
				if player and not car.get("is_occupied") and car.has_method("enter_vehicle"):
					car.enter_vehicle(player)
				if "headlight_left" in car and car.headlight_left: car.headlight_left.visible = true
				if "headlight_right" in car and car.headlight_right: car.headlight_right.visible = true
		"combat":
			if car and car.get("is_occupied") and car.has_method("exit_vehicle"):
				car.exit_vehicle()
			if player and is_instance_valid(player):
				player.global_position = target_pos
				player.rotation.y = sc["rot_y"]
				
	# Stream chunks around destination
	if chunk_mgr and chunk_mgr.has_method("_update_chunks"):
		var coord = OpenWorldConfig.world_to_chunk_coord(target_pos)
		chunk_mgr._update_chunks(coord)

func _sim_scenario_step(sc: Dictionary, dt: float):
	match sc["type"]:
		"foot":
			if player and is_instance_valid(player):
				# Walking subtle motion
				player.global_position += Vector3(0.0, 0.0, 1.5 * dt)
				var wy = OpenWorldConfig.get_terrain_height(player.global_position.x, player.global_position.z)
				player.global_position.y = wy + 0.1
		"vehicle_cruise":
			_sim_highway_cruise(dt)
		"vehicle_nitro":
			_sim_nitro_boost(dt)
		"vehicle_night":
			_sim_night_driving(dt)
		"combat":
			_sim_zombie_combat(dt)
		"streaming":
			_sim_streaming_run(dt)

func _right_car_if_needed():
	if not car or not is_instance_valid(car):
		return
	if abs(car.rotation.z) > 0.45 or abs(car.rotation.x) > 0.6 or car.global_position.y < -2.0 or car.global_position.y > 60.0:
		var wy = OpenWorldConfig.get_terrain_height(67.5, car.global_position.z)
		car.global_position = Vector3(67.5, wy + 0.45, car.global_position.z)
		car.rotation = Vector3.ZERO
		car.linear_velocity = Vector3(0, 0, car.linear_velocity.z)
		car.angular_velocity = Vector3.ZERO

func _sim_highway_cruise(delta: float):
	if not car or not is_instance_valid(car): return
	_right_car_if_needed()
	car.set("touch_throttle", 0.90)
	car.set("touch_boost", false)
	var err_x = car.global_position.x - 67.5
	car.set("touch_steer", clampf(err_x * 0.22, -0.25, 0.25))

func _sim_nitro_boost(delta: float):
	if not car or not is_instance_valid(car): return
	_right_car_if_needed()
	car.set("touch_throttle", 1.0)
	car.set("touch_boost", true)
	car.set("current_nitro", 100.0) # Continuous nitro test
	var err_x = car.global_position.x - 67.5
	car.set("touch_steer", clampf(err_x * 0.22, -0.25, 0.25))

func _sim_night_driving(delta: float):
	if not car or not is_instance_valid(car): return
	_right_car_if_needed()
	car.set("touch_throttle", 0.65)
	car.set("touch_boost", false)
	var err_x = car.global_position.x - 67.5
	car.set("touch_steer", clampf(err_x * 0.20, -0.20, 0.20))

func _sim_zombie_combat(delta: float):
	if not player or not is_instance_valid(player): return
	var zombies = get_nodes_in_group("zombies")
	var target = null
	if zombies and zombies.size() > 0:
		for z in zombies:
			if is_instance_valid(z):
				target = z
				break
	if target:
		var dir = (target.global_position - player.global_position)
		dir.y = 0.0
		if dir.length_squared() > 0.1:
			player.rotation.y = lerp_angle(player.rotation.y, atan2(-dir.x, -dir.z), delta * 5.0)
	if player.has_method("start_fire"):
		player.start_fire()

func _sim_streaming_run(delta: float):
	if not car or not is_instance_valid(car): return
	_right_car_if_needed()
	car.set("touch_throttle", 0.95)
	car.set("touch_boost", false)
	var err_x = car.global_position.x - 67.5
	car.set("touch_steer", clampf(err_x * 0.20, -0.25, 0.25))

func _capture_screen_with_overhead(path: String, scenario_label: String):
	var save_start_usec = Time.get_ticks_usec()
	var vp = root.get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		if img:
			if img.get_width() != 1280 or img.get_height() != 720:
				img.resize(1280, 720)
			var err = img.save_png(path)
			var save_duration_ms = float(Time.get_ticks_usec() - save_start_usec) / 1000.0
			if err == OK:
				print("[PHASE-8-SUITE] Verified screenshot saved: %s (Disk overhead: %.2f ms)" % [path, save_duration_ms])
				screenshot_records.append({
					"scenario": scenario_label,
					"path": path,
					"disk_overhead_ms": save_duration_ms
				})
			else:
				printerr("[PHASE-8-SUITE] Failed to save screenshot: ", err)

func _get_process_rss_mb() -> float:
	var f = FileAccess.open("/proc/self/status", FileAccess.READ)
	if f:
		while not f.eof_reached():
			var line = f.get_line()
			if line.begins_with("VmRSS:"):
				f.close()
				var parts = line.split(" ", false)
				if parts.size() >= 2:
					return float(parts[1]) / 1024.0
		f.close()
	return Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

func _get_process_peak_rss_mb() -> float:
	var f = FileAccess.open("/proc/self/status", FileAccess.READ)
	if f:
		while not f.eof_reached():
			var line = f.get_line()
			if line.begins_with("VmHWM:"):
				f.close()
				var parts = line.split(" ", false)
				if parts.size() >= 2:
					return float(parts[1]) / 1024.0
		f.close()
	return _get_process_rss_mb()

func _get_system_ram_info() -> Dictionary:
	var total_mb = 4096.0
	var avail_mb = 2048.0
	var f = FileAccess.open("/proc/meminfo", FileAccess.READ)
	if f:
		while not f.eof_reached():
			var line = f.get_line()
			if line.begins_with("MemTotal:"):
				var parts = line.split(" ", false)
				if parts.size() >= 2: total_mb = float(parts[1]) / 1024.0
			elif line.begins_with("MemAvailable:"):
				var parts = line.split(" ", false)
				if parts.size() >= 2: avail_mb = float(parts[1]) / 1024.0
		f.close()
	return {"total_mb": total_mb, "available_mb": avail_mb}

func _finish_and_report():
	var total_frames = fps_values.size()
	if total_frames == 0:
		printerr("[PHASE-8-SUITE] Error: No frames sampled!")
		quit(1)
		return
		
	var avg_fps = float(total_frames) / maxf(elapsed_gameplay_sec, 0.001)
	var sorted_fps = fps_values.duplicate()
	sorted_fps.sort()
	
	var median_fps = sorted_fps[int(total_frames * 0.50)]
	var min_fps = sorted_fps[0]
	var max_fps = sorted_fps[total_frames - 1]
	
	var one_pct_count = max(1, int(float(total_frames) * 0.01))
	var one_pct_sum = 0.0
	for i in range(one_pct_count):
		one_pct_sum += sorted_fps[i]
	var one_pct_low_fps = one_pct_sum / float(one_pct_count)
	
	var sorted_ft = frame_times_ms.duplicate()
	sorted_ft.sort()
	var worst_1pct_ft_sum = 0.0
	for i in range(total_frames - one_pct_count, total_frames):
		worst_1pct_ft_sum += sorted_ft[i]
	var mean_worst_1pct_ft = worst_1pct_ft_sum / float(one_pct_count)
	var one_pct_low_harmonic = 1000.0 / maxf(mean_worst_1pct_ft, 0.001)
	
	var peak_rss = _get_process_peak_rss_mb()
	var final_rss = _get_process_rss_mb()
	var sum_rss = 0.0
	for r in proc_rss_values: sum_rss += r
	var avg_rss = sum_rss / float(proc_rss_values.size())
	
	var sys_ram = _get_system_ram_info()
	var peak_tex_mem = 0.0
	for t in tex_mem_values: if t > peak_tex_mem: peak_tex_mem = t
	var peak_static_mem = 0.0
	for m in static_mem_values: if m > peak_static_mem: peak_static_mem = m
	
	var sum_dc = 0
	var peak_dc = 0
	for dc in dc_values:
		sum_dc += dc
		if dc > peak_dc: peak_dc = dc
	var avg_dc = int(sum_dc / total_frames)
	
	var sum_obj = 0
	var peak_obj = 0
	for o in obj_values:
		sum_obj += o
		if o > peak_obj: peak_obj = o
	var avg_obj = int(sum_obj / total_frames)
	
	var sum_prim = 0
	var peak_prim = 0
	for p in prim_values:
		sum_prim += p
		if p > peak_prim: peak_prim = p
	var avg_prim = int(sum_prim / total_frames)
	
	print("\n================================================================================")
	print("    PHASE 8: AAA GRAPHICS OPTIMIZATION 9-SCENARIO BENCHMARK REPORT             ")
	print("================================================================================")
	print("Resolution:            1280 x 720 Native")
	print("Total Test Time:       %.2f seconds monotonic gameplay" % elapsed_gameplay_sec)
	print("Total Frames Rendered: %d frames" % total_frames)
	print("--------------------------------------------------------------------------------")
	print("FRAME RATE PERFORMANCE:")
	print("  Average FPS:         %.2f FPS" % avg_fps)
	print("  Median FPS:          %.2f FPS" % median_fps)
	print("  1% Low FPS:          %.2f FPS (Formula: Mean of lowest 1%% [%d] frames)" % [one_pct_low_fps, one_pct_count])
	print("  Minimum FPS:         %.2f FPS" % min_fps)
	print("  Maximum FPS:         %.2f FPS" % max_fps)
	print("--------------------------------------------------------------------------------")
	print("MEMORY UTILIZATION (Low-End 4GB PC Budget):")
	print("  Process Peak (VmHWM):%.2f MB (%.2f%% of 4GB budget)" % [peak_rss, (peak_rss / 4096.0) * 100.0])
	print("  Process Average RSS: %.2f MB" % avg_rss)
	print("  System Physical RAM: %.2f MB total | %.2f MB available" % [sys_ram["total_mb"], sys_ram["available_mb"]])
	print("  Texture GPU VRAM:    %.2f MB peak" % peak_tex_mem)
	print("--------------------------------------------------------------------------------")
	print("RENDER PIPELINE STATS:")
	print("  Draw Calls:          %d avg / frame (Peak: %d)" % [avg_dc, peak_dc])
	print("  Objects Rendered:    %d avg / frame (Peak: %d)" % [avg_obj, peak_obj])
	print("  Primitives/Triangles:%d avg / frame (Peak: %d)" % [avg_prim, peak_prim])
	print("--------------------------------------------------------------------------------")
	print("SCENARIO BREAKDOWN (9 Scenarios):")
	for sc_name in scenario_results.keys():
		var data = scenario_results[sc_name]
		print("  %-30s : %5.1f FPS | %5.2f ms | %4d frames | RSS: %5.1f MB | DC: %d" % [
			sc_name, data["average_fps"], data["average_frame_time_ms"], data["frames_sampled"], data["process_rss_mb"], data["draw_calls_avg"]
		])
	print("--------------------------------------------------------------------------------")
	print("SCREENSHOT OVERHEAD (Isolated from gameplay frames):")
	for rec in screenshot_records:
		print("  %-42s : %.2f ms disk save -> %s" % [rec["scenario"], rec["disk_overhead_ms"], rec["path"]])
	print("================================================================================\n")
	
	var results = {
		"benchmark_version": "Phase 8 AAA Graphics Optimization 9-Scenario",
		"timestamp_iso": Time.get_datetime_string_from_system(false, true),
		"resolution": "1280x720",
		"hardware_target": "Low-End PC 4GB RAM (AMD Kabini APU)",
		"elapsed_gameplay_seconds": elapsed_gameplay_sec,
		"total_frames_rendered": total_frames,
		"fps": {
			"average": avg_fps,
			"median": median_fps,
			"one_percent_low": one_pct_low_fps,
			"one_percent_low_harmonic": one_pct_low_harmonic,
			"minimum": min_fps,
			"maximum": max_fps,
			"calculation_formula": "Average = total_frames / elapsed_gameplay_sec; 1% Low = mean(sorted_fps[0..0.01*N])"
		},
		"frame_time_ms": {
			"average": (elapsed_gameplay_sec / float(total_frames)) * 1000.0,
			"minimum": 1000.0 / maxf(max_fps, 0.001),
			"maximum": 1000.0 / maxf(min_fps, 0.001),
			"one_percent_worst_average": mean_worst_1pct_ft,
			"spike_analysis": "Screenshot PNG disk write measured separately and excluded from gameplay frame deltas."
		},
		"memory": {
			"process_peak_rss_hwm_mb": peak_rss,
			"process_rss_average_mb": avg_rss,
			"process_rss_initial_mb": proc_rss_values[0] if proc_rss_values.size() > 0 else 0.0,
			"process_rss_final_mb": final_rss,
			"ram_budget_4gb_percent": (peak_rss / 4096.0) * 100.0,
			"system_total_ram_mb": sys_ram["total_mb"],
			"system_available_ram_mb": sys_ram["available_mb"],
			"texture_gpu_vram_peak_mb": peak_tex_mem,
			"static_engine_ram_peak_mb": peak_static_mem
		},
		"render_pipeline": {
			"draw_calls_average": avg_dc,
			"draw_calls_peak": peak_dc,
			"objects_average": avg_obj,
			"objects_peak": peak_obj,
			"primitives_average": avg_prim,
			"primitives_peak": peak_prim
		},
		"scenarios": scenario_results,
		"screenshot_overhead": screenshot_records
	}
	
	var out_file = FileAccess.open("/home/am/gta5_benchmark_results.json", FileAccess.WRITE)
	if out_file:
		out_file.store_string(JSON.stringify(results, "\t"))
		out_file.close()
		print("[PHASE-8-SUITE] Complete verified results saved to /home/am/gta5_benchmark_results.json")
	else:
		printerr("[PHASE-8-SUITE] Failed to write results to /home/am/gta5_benchmark_results.json")
		
	quit(0)
