# phase7_showcase_suite.gd
# PHASE 7: AAA ART TRANSFORMATION SHOWCASE & MULTI-TIME BENCHMARK SUITE
# Tests 5 locations (Residential street, Downtown city, Highway, Mountain road, Forest)
# Across 3 lighting conditions (Day, Sunset/Golden Hour, Night)
# Strict monotonic telemetry, isolated screenshot overhead, 1280x720 native capture.
extends SceneTree

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")

var world_scene: Node = null
var player: CharacterBody3D = null
var car: Node3D = null
var chunk_mgr: Node3D = null
var sky_ctrl: Node3D = null

# Telemetry
var frame_times_ms: Array[float] = []
var fps_values: Array[float] = []
var dc_values: Array[int] = []
var obj_values: Array[int] = []
var prim_values: Array[int] = []
var tex_mem_values: Array[float] = []
var static_mem_values: Array[float] = []
var proc_rss_values: Array[float] = []

var screenshot_records: Array[Dictionary] = []
var showcase_results: Dictionary = {}
var elapsed_gameplay_sec: float = 0.0

func _init():
	print("[PHASE-7-SUITE] Initializing AAA Art Transformation Showcase Suite...")
	DisplayServer.window_set_size(Vector2i(1280, 720))
	
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	if not scn:
		printerr("[PHASE-7-SUITE] Failed to load GTAOpenWorld.tscn")
		quit(1)
		return
		
	world_scene = scn.instantiate()
	root.add_child(world_scene)
	_run_suite()

func _run_suite():
	print("[PHASE-7-SUITE] Warming up pipelines and preloading assets (60 frames)...")
	for f in range(60):
		await process_frame
		
	player = world_scene.get("player_node") as CharacterBody3D
	car = world_scene.get("player_car")
	chunk_mgr = world_scene.get_node_or_null("ChunkManager")
	sky_ctrl = world_scene.get_node_or_null("SkyController")
	
	print("[PHASE-7-SUITE] Warmup complete. Commencing 5-Location & 3-Time Lighting Showcase!")
	
	# Showcase stages configuration:
	# 1. Residential Street (Day) - New House variants, gabled roofs, garage, porches, palm trees
	# 2. Downtown City (Day) - Financial skyscrapers, storefronts, canopies, streetlights
	# 3. Highway Corridor (Day) - Dark asphalt, dual yellow lines, white dividers, curbs, barriers
	# 4. Mountain Road (Day) - North Mountain winding climb, deep perimeter skirts
	# 5. Countryside Forest (Day) - Rolling hills, vegetation, trees, rock clusters
	# 6. Sunset Showcase (Golden Hour) - Warm orange sunlight, specular glints on glass/metal
	# 7. Night Showcase (Moonlight + Streetlights + Headlights) - Dark asphalt, glowing lamps
	
	var stages = [
		{
			"id": "residential_street",
			"name": "Residential Street",
			"pos": Vector3(64.0, 1.2, 195.0),
			"rot_y": 0.35, # Angled view capturing street and houses
			"cam_pitch": -0.08,
			"time_mode": 0, # Day
			"shot_path": "/home/am/phase7_showcase_residential_street.png",
			"shot_label": "Residential Street (Day)",
			"duration": 15.0
		},
		{
			"id": "downtown_city",
			"name": "Downtown City",
			"pos": Vector3(72.0, 1.2, 58.0),
			"rot_y": -0.45,
			"cam_pitch": 0.12, # Looking slightly up at towers
			"time_mode": 0, # Day
			"shot_path": "/home/am/phase7_showcase_downtown_city.png",
			"shot_label": "Downtown City (Day)",
			"duration": 15.0
		},
		{
			"id": "highway",
			"name": "Highway",
			"pos": Vector3(140.0, 1.2, 64.0),
			"rot_y": -1.57, # Looking along East-West Highway
			"cam_pitch": -0.05,
			"time_mode": 0, # Day
			"shot_path": "/home/am/phase7_showcase_highway.png",
			"shot_label": "Highway (Day)",
			"duration": 15.0
		},
		{
			"id": "mountain_road",
			"name": "Mountain Road",
			"pos": Vector3(64.0, 26.0, -65.0),
			"rot_y": 3.14, # Looking South overlooking the vast valley and city
			"cam_pitch": -0.15,
			"time_mode": 0, # Day
			"shot_path": "/home/am/phase7_showcase_mountain_road.png",
			"shot_label": "Mountain Road (Day)",
			"duration": 15.0
		},
		{
			"id": "forest",
			"name": "Forest",
			"pos": Vector3(-100.0, 6.0, 64.0),
			"rot_y": 0.85,
			"cam_pitch": -0.05,
			"time_mode": 0, # Day
			"shot_path": "/home/am/phase7_showcase_forest.png",
			"shot_label": "Forest (Day)",
			"duration": 15.0
		},
		{
			"id": "sunset",
			"name": "Sunset Showcase",
			"pos": Vector3(64.0, 1.2, 90.0),
			"rot_y": -0.65,
			"cam_pitch": 0.05,
			"time_mode": 1, # Golden Hour
			"shot_path": "/home/am/phase7_showcase_sunset.png",
			"shot_label": "Sunset / Golden Hour Showcase",
			"duration": 15.0
		},
		{
			"id": "night",
			"name": "Night Showcase",
			"pos": Vector3(67.5, 1.2, 70.0),
			"rot_y": 0.0, # Along avenue showing streetlights and headlights
			"cam_pitch": -0.04,
			"time_mode": 2, # Night
			"shot_path": "/home/am/phase7_showcase_night.png",
			"shot_label": "Night Showcase (Streetlights & Headlights)",
			"duration": 15.0
		}
	]
	
	for st_idx in range(stages.size()):
		var stage = stages[st_idx]
		print("\n[PHASE-7-SUITE] Entering Stage %d/%d: %s..." % [st_idx + 1, stages.size(), stage["name"]])
		
		# Set Time of Day
		if sky_ctrl and sky_ctrl.has_method("apply_time_of_day"):
			sky_ctrl.apply_time_of_day(stage["time_mode"])
			
		# In Night Showcase, turn on car headlights illuminating dark asphalt
		if stage["id"] == "night" and car and is_instance_valid(car):
			var c_wy = OpenWorldConfig.get_terrain_height(67.5, 75.0)
			car.global_position = Vector3(67.5, c_wy + 0.45, 75.0)
			car.rotation = Vector3.ZERO
			if car.has_method("enter_vehicle") and player:
				car.enter_vehicle(player)
			if "headlight_left" in car and car.headlight_left: car.headlight_left.visible = true
			if "headlight_right" in car and car.headlight_right: car.headlight_right.visible = true
		else:
			if car and car.get("is_occupied") and car.has_method("exit_vehicle"):
				car.exit_vehicle()
			
		# Teleport player and update ground snap
		var target_pos = stage["pos"]
		var wy = OpenWorldConfig.get_terrain_height(target_pos.x, target_pos.z)
		target_pos.y = maxf(target_pos.y, wy + 1.2)
		
		if player and is_instance_valid(player):
			player.global_position = target_pos
			player.rotation.y = stage["rot_y"]
			var cam = player.get_node_or_null("Camera3D")
			if cam:
				cam.rotation.x = stage["cam_pitch"]
				
		# Update chunk streaming
		if chunk_mgr and chunk_mgr.has_method("_update_chunks"):
			var coord = OpenWorldConfig.world_to_chunk_coord(target_pos)
			chunk_mgr._update_chunks(coord)
			
		# Settle scene rendering for 15 frames
		for s in range(15):
			await process_frame
			
		# Execute stage telemetry loop
		var stage_time: float = 0.0
		var stage_frames: int = 0
		var stage_fps_list: Array[float] = []
		var stage_ft_list: Array[float] = []
		var stage_rss_list: Array[float] = []
		var stage_shot_taken: bool = false
		
		var last_time_usec = Time.get_ticks_usec()
		
		while stage_time < stage["duration"]:
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
			
			# Capture screenshot at stage midpoint (isolated from gameplay delta)
			if stage_time >= (stage["duration"] * 0.50) and not stage_shot_taken:
				stage_shot_taken = true
				_capture_screen_with_overhead(stage["shot_path"], stage["shot_label"])
				last_time_usec = Time.get_ticks_usec()
				
		var st_avg_fps = float(stage_frames) / maxf(stage_time, 0.001)
		var st_sorted_fps = stage_fps_list.duplicate()
		st_sorted_fps.sort()
		var st_med_fps = st_sorted_fps[int(stage_frames * 0.50)] if stage_frames > 0 else 0.0
		var st_min_fps = st_sorted_fps[0] if stage_frames > 0 else 0.0
		var st_rss = stage_rss_list[stage_rss_list.size() - 1] if stage_rss_list.size() > 0 else 0.0
		
		showcase_results[stage["name"]] = {
			"frames_sampled": stage_frames,
			"duration_sec": stage_time,
			"average_fps": st_avg_fps,
			"median_fps": st_med_fps,
			"min_fps": st_min_fps,
			"average_frame_time_ms": 1000.0 / maxf(st_avg_fps, 0.001),
			"process_rss_mb": st_rss
		}
		print("[PHASE-7-SUITE] Stage '%s' complete: %5.1f FPS | %4d frames | RSS: %5.1f MB" % [
			stage["name"], st_avg_fps, stage_frames, st_rss
		])
		
	_finish_and_report()

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
				print("[PHASE-7-SUITE] Verified screenshot saved: %s (Disk overhead: %.2f ms)" % [path, save_duration_ms])
				screenshot_records.append({
					"scenario": scenario_label,
					"path": path,
					"disk_overhead_ms": save_duration_ms
				})
			else:
				printerr("[PHASE-7-SUITE] Failed to save screenshot: ", err)

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
	
	var ft_sum = 0.0; var min_ft = 9999.0; var max_ft = 0.0
	for ft in frame_times_ms:
		ft_sum += ft
		if ft < min_ft: min_ft = ft
		if ft > max_ft: max_ft = ft
	var avg_ft = ft_sum / float(total_frames)
	
	var dc_sum = 0; var max_dc = 0
	for dc in dc_values: dc_sum += dc; if dc > max_dc: max_dc = dc
	var avg_dc = int(float(dc_sum) / float(total_frames))
	
	var obj_sum = 0; var max_obj = 0
	for obj in obj_values: obj_sum += obj; if obj > max_obj: max_obj = obj
	var avg_obj = int(float(obj_sum) / float(total_frames))
	
	var prim_sum = 0; var max_prim = 0
	for prim in prim_values: prim_sum += prim; if prim > max_prim: max_prim = prim
	var avg_prim = int(float(prim_sum) / float(total_frames))
	
	var init_rss = proc_rss_values[0]
	var final_rss = proc_rss_values[total_frames - 1]
	var peak_rss = _get_process_peak_rss_mb()
	var rss_sum = 0.0
	for rss in proc_rss_values: rss_sum += rss
	var avg_rss = rss_sum / float(total_frames)
	
	var peak_tex_mem = 0.0
	for tm in tex_mem_values: if tm > peak_tex_mem: peak_tex_mem = tm
	var peak_static_mem = 0.0
	for sm in static_mem_values: if sm > peak_static_mem: peak_static_mem = sm
	var sys_ram = _get_system_ram_info()
	
	print("\n================================================================================")
	print("    PHASE 7: AAA ART TRANSFORMATION SHOWCASE OFFICIAL BENCHMARK REPORT         ")
	print("================================================================================")
	print("Resolution:            1280 x 720 Native")
	print("Total Test Time:       %.2f seconds monotonic gameplay" % elapsed_gameplay_sec)
	print("Total Frames Rendered: %d frames" % total_frames)
	print("--------------------------------------------------------------------------------")
	print("FRAME RATE PERFORMANCE:")
	print("  Average FPS:         %.2f FPS" % avg_fps)
	print("  Median FPS:          %.2f FPS" % median_fps)
	print("  1%% Low FPS:          %.2f FPS (Formula: Mean of lowest 1%% [%d] frames)" % [one_pct_low_fps, one_pct_count])
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
	print("  Draw Calls:          %d avg / frame (Peak: %d)" % [avg_dc, max_dc])
	print("  Objects Rendered:    %d avg / frame (Peak: %d)" % [avg_obj, max_obj])
	print("  Primitives/Triangles:%d avg / frame (Peak: %d)" % [avg_prim, max_prim])
	print("--------------------------------------------------------------------------------")
	print("SHOWCASE LOCATIONS & LIGHTING BREAKDOWN:")
	for s_name in showcase_results.keys():
		var sc = showcase_results[s_name]
		print("  %-30s : %5.1f FPS | %5.2f ms | %4d frames | RSS: %5.1f MB" % [
			s_name, sc["average_fps"], sc["average_frame_time_ms"], sc["frames_sampled"], sc["process_rss_mb"]
		])
	print("--------------------------------------------------------------------------------")
	print("SCREENSHOT OVERHEAD (Isolated from gameplay frames):")
	for rec in screenshot_records:
		print("  %-35s : %6.2f ms disk save -> %s" % [rec["scenario"], rec["disk_overhead_ms"], rec["path"]])
	print("================================================================================\n")
	
	var result_dict = {
		"benchmark_version": "Phase 7 AAA Art Transformation Showcase",
		"timestamp_iso": Time.get_datetime_string_from_system(true),
		"resolution": "1280x720",
		"hardware_target": "Low-End PC 4GB RAM",
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
			"average": avg_ft,
			"minimum": min_ft,
			"maximum": max_ft,
			"one_percent_worst_average": mean_worst_1pct_ft,
			"spike_analysis": "Screenshot PNG disk write measured separately and excluded from gameplay frame deltas."
		},
		"memory": {
			"process_rss_initial_mb": init_rss,
			"process_rss_average_mb": avg_rss,
			"process_rss_final_mb": final_rss,
			"process_peak_rss_hwm_mb": peak_rss,
			"static_engine_ram_peak_mb": peak_static_mem,
			"texture_gpu_vram_peak_mb": peak_tex_mem,
			"system_total_ram_mb": sys_ram["total_mb"],
			"system_available_ram_mb": sys_ram["available_mb"],
			"ram_budget_4gb_percent": (peak_rss / 4096.0) * 100.0
		},
		"render_pipeline": {
			"draw_calls_average": avg_dc,
			"draw_calls_peak": max_dc,
			"objects_average": avg_obj,
			"objects_peak": max_obj,
			"primitives_average": avg_prim,
			"primitives_peak": max_prim
		},
		"scenarios": showcase_results,
		"screenshot_overhead": screenshot_records
	}
	
	var out_file = FileAccess.open("/home/am/gta5_benchmark_results.json", FileAccess.WRITE)
	if out_file:
		out_file.store_string(JSON.stringify(result_dict, "\t"))
		out_file.close()
		print("[PHASE-7-SUITE] Complete verified results saved to /home/am/gta5_benchmark_results.json")
		
	quit(0)
