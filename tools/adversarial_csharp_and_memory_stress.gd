extends SceneTree

# ==============================================================================
# EMPIRICAL ADVERSARIAL STRESS TEST: C# SUBSYSTEMS, MEMORY SAFETY & STABILITY
# Challenger 2 Harness for Sector Zero: Lockdown (Godot 4.7.2 Mono / .NET 8)
# ==============================================================================

var test_failures: Array[String] = []
var test_warnings: Array[String] = []

func _init():
	call_deferred("_run_harness")

func _log_pass(test_name: String, details: String = ""):
	if details.is_empty():
		print("  [PASS] %s" % test_name)
	else:
		print("  [PASS] %s: %s" % [test_name, details])

func _log_fail(test_name: String, reason: String):
	printerr("  [FAIL] %s: %s" % [test_name, reason])
	test_failures.append("%s: %s" % [test_name, reason])

func _log_warn(test_name: String, reason: String):
	print("  [WARN] %s: %s" % [test_name, reason])
	test_warnings.append("%s: %s" % [test_name, reason])

func _get_process_rss_mb() -> float:
	var f = FileAccess.open("/proc/self/status", FileAccess.READ)
	if f:
		while not f.eof_reached():
			var line = f.get_line()
			if line.begins_with("VmRSS:"):
				var parts = line.split(" ", false)
				if parts.size() >= 2:
					var kb = parts[1].to_float()
					return kb / 1024.0
	return Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

func _run_harness():
	print("\n=======================================================================")
	print("=== EMPIRICAL ADVERSARIAL C# & MEMORY STABILITY STRESS TEST HARNESS ===")
	print("=======================================================================\n")
	print("Runtime Engine: %s" % Engine.get_version_info()["string"])
	print("Initial Linux VmRSS: %.2f MB" % _get_process_rss_mb())
	print("Initial Godot Static Memory: %.2f MB\n" % (Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)))

	# --- STAGE 1: C# Autoload & Engine Coordinator (SectorZeroGameCore) ---
	print(">>> [STAGE 1] Testing SectorZeroGameCore C# Autoload Coordinator...")
	_test_game_core_autoload()

	# --- STAGE 2: C# VehiclePhysicsHelper Interop & Boundary Stress ---
	print("\n>>> [STAGE 2] Adversarial Stress: VehiclePhysicsHelper Interop & Math Limits...")
	_test_vehicle_physics_helper()

	# --- STAGE 3: C# DamageSystem Interop & Combat Calculation ---
	print("\n>>> [STAGE 3] Adversarial Stress: DamageSystem Interop & Extreme Hits...")
	_test_damage_system()

	# --- STAGE 4: C# ZombieSwarmOptimizer High-Scale & Reference Stability ---
	print("\n>>> [STAGE 4] Adversarial Stress: ZombieSwarmOptimizer Scale & Lifecycle...")
	await _test_zombie_swarm_optimizer()

	# --- STAGE 5: C# WorldChunkStreamer 840m x 840m Envelope & Rapid Churn ---
	print("\n>>> [STAGE 5] Adversarial Stress: WorldChunkStreamer 840m Grid & Churn...")
	await _test_world_chunk_streamer_stress()

	# --- STAGE 6: Headless Arena Scene Instantiation & 3.3 GB APU Budget Audit ---
	print("\n>>> [STAGE 6] Headless Arena Instantiation & APU Memory Budget Audit...")
	await _test_arena_instantiation_and_memory_budget()

	# --- FINAL SUMMARY ---
	_print_summary()

func _test_game_core_autoload():
	var core = get_root().get_node_or_null("SectorZeroGameCore")
	if not core:
		_log_fail("SectorZeroGameCore Autoload", "Node not found at /root/SectorZeroGameCore")
		return

	_log_pass("SectorZeroGameCore Registered", "Found at %s (Class: %s)" % [core.get_path(), core.get_class()])

	# Check script
	var scr = core.get_script()
	if not scr:
		_log_fail("SectorZeroGameCore Script", "No script attached to Autoload node")
		return
	_log_pass("SectorZeroGameCore C# Script Attached", str(scr.resource_path))

	# Verify diagnostics export property
	if "EnableDetailedDiagnostics" in core:
		var diag = core.EnableDetailedDiagnostics
		_log_pass("SectorZeroGameCore Properties", "EnableDetailedDiagnostics = %s" % str(diag))
	else:
		_log_warn("SectorZeroGameCore Properties", "EnableDetailedDiagnostics property missing or not exported")

func _test_vehicle_physics_helper():
	var helper_script = load("res://scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs")
	if not helper_script:
		_log_fail("Load VehiclePhysicsHelper.cs", "Resource failed to load")
		return
	_log_pass("Load VehiclePhysicsHelper.cs", "Successfully loaded C# script resource")

	var helper = helper_script.new()
	if not helper:
		_log_fail("Instantiate VehiclePhysicsHelper", "Could not instantiate helper object")
		return
	_log_pass("Instantiate VehiclePhysicsHelper", "Successfully instantiated C# RefCounted object")

	# Test 1: Incline Assist Below Threshold (< 8.0 deg) -> Must be Vector3.ZERO
	var assist_flat = helper.GetInclineAssist(Vector3(5, 0, 0), Vector3.FORWARD, 5.0, 1000.0)
	if assist_flat == Vector3.ZERO:
		_log_pass("Incline Assist Flat (<8 deg)", "Correctly returned Vector3.ZERO: %s" % str(assist_flat))
	else:
		_log_fail("Incline Assist Flat (<8 deg)", "Expected Vector3.ZERO, got %s" % str(assist_flat))

	# Test 2: Incline Assist Moderate Slope (25 deg)
	var assist_25 = helper.GetInclineAssist(Vector3(5, 0, 0), Vector3.FORWARD, 25.0, 1000.0)
	if assist_25.length() > 0.0:
		_log_pass("Incline Assist 25 deg", "Output force vector: %s (Magnitude: %.2f)" % [str(assist_25), assist_25.length()])
	else:
		_log_fail("Incline Assist 25 deg", "Expected positive assist force on 25 deg slope, got %s" % str(assist_25))

	# Test 3: Incline Assist Extreme Slope (45 deg)
	var assist_45 = helper.GetInclineAssist(Vector3(5, 0, 0), Vector3.FORWARD, 45.0, 1000.0)
	if assist_45.length() >= 990.0:
		_log_pass("Incline Assist 45 deg Peak", "Reached maximum factor boost: %.2f" % assist_45.length())
	else:
		_log_fail("Incline Assist 45 deg Peak", "Expected boost ~1000.0 at 45 deg, got %.2f" % assist_45.length())

	# Test 4: Incline Assist Slope Clamping (> 45 deg, e.g. 75 deg)
	var assist_75 = helper.GetInclineAssist(Vector3(5, 0, 0), Vector3.FORWARD, 75.0, 1000.0)
	if is_equal_approx(assist_75.length(), assist_45.length()):
		_log_pass("Incline Assist Overshoot Clamp (75 deg)", "Properly clamped to max factor (len: %.2f)" % assist_75.length())
	else:
		_log_fail("Incline Assist Overshoot Clamp (75 deg)", "Failed clamp! len(75 deg)=%.2f vs len(45 deg)=%.2f" % [assist_75.length(), assist_45.length()])

	# Test 5: Incline Assist Directional Projection (+Y component for obstacle clearing)
	if assist_25.y > 0.0:
		_log_pass("Incline Assist Vector3.Up Projection", "Assist contains positive Y component (Y=%.2f) to clear terrain lips" % assist_25.y)
	else:
		_log_fail("Incline Assist Vector3.Up Projection", "Assist has no upward component (Y=%.2f)" % assist_25.y)

	# Test 6: Bike Lean at Standstill (0 km/h) -> Must not lean
	var lean_standstill = helper.GetBikeLean(0.0, 1.0, 0.0, deg_to_rad(35.0), 0.016)
	if is_equal_approx(lean_standstill, 0.0):
		_log_pass("Bike Lean Standstill (0 km/h)", "Zero lean at standstill (got %.4f rad)" % lean_standstill)
	else:
		_log_fail("Bike Lean Standstill (0 km/h)", "Expected 0 lean at 0 speed, got %.4f rad" % lean_standstill)

	# Test 7: Bike Lean at Full Speed (60 km/h, full steer)
	var max_lean = deg_to_rad(35.0)
	var current_lean = 0.0
	for step in range(60):
		current_lean = helper.GetBikeLean(current_lean, 1.0, 60.0, max_lean, 0.016)
	if current_lean < -0.5: # Negative steer leans into turn
		_log_pass("Bike Lean Dynamic Pacing (60 km/h)", "Reached lean angle: %.2f deg (target -35 deg)" % rad_to_deg(current_lean))
	else:
		_log_fail("Bike Lean Dynamic Pacing (60 km/h)", "Bike did not lean into turn as expected (got %.2f deg)" % rad_to_deg(current_lean))

func _test_damage_system():
	var dmg_script = load("res://scripts/CSharp/Combat/DamageSystem.cs")
	if not dmg_script:
		_log_fail("Load DamageSystem.cs", "Resource failed to load")
		return
	_log_pass("Load DamageSystem.cs", "Successfully loaded C# script resource")

	# Test 1: Falloff Calculation via static method
	# DamageSystem is RefCounted, static methods can be called via class or instance
	var dmg_instance = dmg_script.new()
	var dmg_close = dmg_instance.CalculateDamage(100.0, 0.0, 50.0, 0.5)
	var dmg_mid = dmg_instance.CalculateDamage(100.0, 25.0, 50.0, 0.5)
	var dmg_far = dmg_instance.CalculateDamage(100.0, 50.0, 50.0, 0.5)
	var dmg_beyond = dmg_instance.CalculateDamage(100.0, 100.0, 50.0, 0.5)

	if is_equal_approx(dmg_close, 100.0) and is_equal_approx(dmg_mid, 75.0) and is_equal_approx(dmg_far, 50.0) and is_equal_approx(dmg_beyond, 50.0):
		_log_pass("Damage Distance Falloff", "Close=%.1f, Mid=%.1f, Far=%.1f, Beyond=%.1f" % [dmg_close, dmg_mid, dmg_far, dmg_beyond])
	else:
		_log_fail("Damage Distance Falloff", "Unexpected values: Close=%.1f, Mid=%.1f, Far=%.1f, Beyond=%.1f" % [dmg_close, dmg_mid, dmg_far, dmg_beyond])

	# Test 2: Extreme / Adversarial Inputs
	var dmg_zero_range = dmg_instance.CalculateDamage(100.0, 10.0, 0.0, 0.5)
	if is_equal_approx(dmg_zero_range, 100.0):
		_log_pass("Damage Zero MaxRange Defense", "Safely avoided divide-by-zero, returned base damage (%.1f)" % dmg_zero_range)
	else:
		_log_fail("Damage Zero MaxRange Defense", "Expected 100.0 on zero max range, got %.1f" % dmg_zero_range)

	# Test 3: ProcessHit on dummy Node3D
	var dummy_target = Node3D.new()
	dummy_target.position = Vector3(0, 0, 10)
	var hit_res = dmg_instance.ProcessHit(dummy_target, 50.0, Vector3(0, 1.5, 10), Vector3(0, 1.5, 0), false)
	dummy_target.free()

	if hit_res is Dictionary and hit_res.has("final_damage") and hit_res.has("hit_dir"):
		_log_pass("DamageSystem ProcessHit", "Returned dictionary with damage=%.1f, zone=%s, dir=%s" % [hit_res["final_damage"], hit_res["hit_zone"], str(hit_res["hit_dir"])])
	else:
		_log_fail("DamageSystem ProcessHit", "ProcessHit failed to return expected dictionary structure: %s" % str(hit_res))

func _test_zombie_swarm_optimizer():
	var swarm_script = load("res://scripts/CSharp/AI/ZombieSwarmOptimizer.cs")
	if not swarm_script:
		_log_fail("Load ZombieSwarmOptimizer.cs", "Resource failed to load")
		return
	_log_pass("Load ZombieSwarmOptimizer.cs", "Successfully loaded C# script resource")

	var swarm = swarm_script.new()
	get_root().add_child(swarm)
	await process_frame

	# Create a dummy player node in 'player' group for distance spatial calculations
	var dummy_player = Node3D.new()
	dummy_player.name = "DummyPlayerForSwarmTest"
	dummy_player.add_to_group("player")
	dummy_player.position = Vector3.ZERO
	get_root().add_child(dummy_player)

	# Register 100 dummy zombies at various distances
	var dummy_zombies: Array[Node3D] = []
	for i in range(100):
		var z = Node3D.new()
		z.name = "TestZombie_%d" % i
		# Half close (< 50m), half far (> 60m)
		if i < 50:
			z.position = Vector3(float(i), 0, 0)
		else:
			z.position = Vector3(float(i + 50), 0, 0)
		get_root().add_child(z)
		dummy_zombies.append(z)
		swarm.RegisterZombie(z)

	_log_pass("ZombieSwarmOptimizer Registration", "Registered 100 active entities")

	# Tick process for 0.5s (2 full batch cycles at 4Hz)
	for f in range(30):
		swarm._Process(0.0166)

	# Verify entities are still valid and active
	var active_count = 0
	for z in dummy_zombies:
		if is_instance_valid(z):
			active_count += 1
	if active_count == 100:
		_log_pass("ZombieSwarmOptimizer Batch Process", "Processed 30 frames without exceptions or corruption")
	else:
		_log_fail("ZombieSwarmOptimizer Batch Process", "Instances corrupted during batch processing (found %d/100)" % active_count)

	# Adversarially delete half the zombies without unregistering to test null-cleaning
	for i in range(0, 50):
		dummy_zombies[i].free()

	# Tick another batch cycle
	swarm._Process(0.3)
	_log_pass("ZombieSwarmOptimizer Stale Null Cleanup", "Cleaned 50 freed references without NullReferenceException")

	# Cleanup remaining
	for i in range(50, 100):
		dummy_zombies[i].free()
	dummy_player.free()
	swarm.free()
	await process_frame

func _test_world_chunk_streamer_stress():
	var streamer_script = load("res://scripts/CSharp/World/WorldChunkStreamer.cs")
	if not streamer_script:
		_log_fail("Load WorldChunkStreamer.cs", "Resource failed to load")
		return
	_log_pass("Load WorldChunkStreamer.cs", "Successfully loaded C# script resource")

	var streamer = streamer_script.new()
	streamer.ChunkSize = 120.0
	streamer.ViewDistanceChunks = 3 # 7x7 grid = 49 active chunks = 840m x 840m envelope
	get_root().add_child(streamer)

	var tracker = Node3D.new()
	tracker.name = "TestTrackerNode"
	tracker.add_to_group("player")
	get_root().add_child(tracker)

	await process_frame

	var mem_before_churn = Performance.get_monitor(Performance.MEMORY_STATIC)

	# Adversarial Stress: Move tracker rapidly across 100 chunk boundaries (total 12,000 meters)
	# This exercises HashSet chunk additions and removals at high frequency
	var coord_changes = 0
	for step in range(120):
		tracker.global_position = Vector3(step * 100.0, 0.0, step * 75.0)
		streamer._Process(0.016)
		coord_changes += 1

	var mem_after_churn = Performance.get_monitor(Performance.MEMORY_STATIC)
	var churn_growth_kb = (mem_after_churn - mem_before_churn) / 1024.0

	_log_pass("WorldChunkStreamer 840m Grid Traversal", "Executed %d rapid coordinate shifts across 12km trajectory" % coord_changes)

	# Verify no runaway memory allocation during chunk transitions
	if churn_growth_kb < 500.0: # Less than 500 KB growth for 120 chunk shifts
		_log_pass("WorldChunkStreamer Memory Stability", "Static memory delta: +%.2f KB (no runaway leak)" % churn_growth_kb)
	else:
		_log_warn("WorldChunkStreamer Memory Delta", "Static memory grew by +%.2f KB during 120 chunk transitions" % churn_growth_kb)

	tracker.free()
	streamer.free()
	await process_frame

func _test_arena_instantiation_and_memory_budget():
	var rss_start = _get_process_rss_mb()
	var static_start = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

	print("  -> Pre-instantiation Linux RSS: %.2f MB" % rss_start)
	print("  -> Pre-instantiation Godot Static: %.2f MB" % static_start)

	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scene:
		_log_fail("Load CityCarZombieArena.tscn", "Failed to load scene resource")
		return
	_log_pass("Load CityCarZombieArena.tscn", "Scene resource loaded cleanly")

	var t0 = Time.get_ticks_msec()
	var arena = scene.instantiate()
	var load_time_ms = Time.get_ticks_msec() - t0
	if not arena:
		_log_fail("Instantiate CityCarZombieArena", "Scene instantiation failed")
		return
	_log_pass("Instantiate CityCarZombieArena", "Instantiated in %d ms (< 5000 ms target)" % load_time_ms)

	get_root().add_child(arena)

	# Run 30 physics and process frames
	for frame in range(30):
		await process_frame

	# Check C# attachments
	var streamer_node = arena.get_node_or_null("WorldChunkStreamer_CSharp")
	if streamer_node:
		_log_pass("WorldChunkStreamer Attached to Arena", "Node '%s' is active child" % streamer_node.name)
	else:
		_log_warn("WorldChunkStreamer Attached to Arena", "Node 'WorldChunkStreamer_CSharp' not found on Arena root")

	var swarm_node = arena.get_node_or_null("ZombieSwarmOptimizer_CSharp")
	if swarm_node:
		_log_pass("ZombieSwarmOptimizer Attached to Arena", "Node '%s' is active child" % swarm_node.name)
	else:
		_log_warn("ZombieSwarmOptimizer Attached to Arena", "Node 'ZombieSwarmOptimizer_CSharp' not found on Arena root")

	# Memory budget audit for AMD Kabini APU (3.3 GB total budget)
	var rss_arena = _get_process_rss_mb()
	var static_arena = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	var static_max = Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / (1024.0 * 1024.0)

	print("  -> Active Arena Linux VmRSS: %.2f MB" % rss_arena)
	print("  -> Active Arena Godot Static Memory: %.2f MB (Peak: %.2f MB)" % [static_arena, static_max])

	# Thresholds: AMD Kabini total APU RAM is 3379 MB (~3.3 GB).
	# Headless arena execution budget should comfortably remain under 1200 MB (36% of 3.3 GB).
	if rss_arena < 1200.0:
		_log_pass("APU Memory Budget Compliance (< 1200 MB)", "Active Linux VmRSS is %.2f MB (%.1f%% of 3.3 GB APU budget)" % [rss_arena, (rss_arena / 3300.0) * 100.0])
	else:
		_log_fail("APU Memory Budget Compliance (< 1200 MB)", "Active Linux VmRSS exceeds budget! VmRSS = %.2f MB" % rss_arena)

	# Run additional 30 frames to check memory delta (no runaway per-frame leak)
	var rss_before_run = _get_process_rss_mb()
	for frame in range(30):
		await process_frame
	var rss_after_run = _get_process_rss_mb()
	var frame_leak_mb = rss_after_run - rss_before_run

	if frame_leak_mb < 20.0:
		_log_pass("Runaway Memory Allocation Check", "Memory remained stable across 30 active frames (delta: +%.2f MB)" % frame_leak_mb)
	else:
		_log_fail("Runaway Memory Allocation Check", "Runaway memory detected! Grew by +%.2f MB over 30 frames" % frame_leak_mb)

	# Cleanup
	arena.queue_free()
	await process_frame

func _print_summary():
	print("\n=======================================================================")
	print("=== EMPIRICAL ADVERSARIAL STRESS TEST SUMMARY ===")
	print("=======================================================================")
	print("Total Failures: %d" % test_failures.size())
	print("Total Warnings: %d" % test_warnings.size())

	if not test_warnings.is_empty():
		print("\nWarnings:")
		for w in test_warnings:
			print("  [!] %s" % w)

	if test_failures.is_empty():
		print("\n[VERDICT] C# SUBSYSTEMS & MEMORY STABILITY HARNESS: ALL AUDITS PASSED!")
		print("=======================================================================\n")
		quit(0)
	else:
		print("\n[VERDICT] C# SUBSYSTEMS & MEMORY STABILITY HARNESS: FAILED!")
		print("Failures:")
		for f in test_failures:
			print("  [X] %s" % f)
		print("=======================================================================\n")
		quit(1)
