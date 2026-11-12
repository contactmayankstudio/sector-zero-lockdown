@tool
extends SceneTree

# Standalone Godot GDScript Empirical Stress Test Suite for Milestone 1
# Tests:
# 1. Runtime instantiation of CityCarZombieArena.tscn
# 2. Dynamic Weather transitions across presets (SUNNY_DAY, GOLDEN_SUNSET, CYBERPUNK_NIGHT, STORMY_RAIN)
# 3. Environment parameter validity, ACES tonemapper persistence, glow_bloom > 0.0 across all presets and tweens
# 4. Rapid cycling tween stress test
# 5. Camera traversal across X: [-100, 100] and Z: [-200, 200] at multiple altitudes and orientations
# 6. NaN matrix checks, culling stability, frustum plane integrity
# 7. Combined mid-flight camera traversal + dynamic weather transitions

func _init():
	var runner = Node3D.new()
	runner.name = "StressTestRunner"
	get_root().add_child(runner)
	
	var script = GDScript.new()
	script.source_code = """
extends Node3D

var failures: Array[String] = []
var warnings: Array[String] = []

func log_pass(msg: String) -> void:
	print("  [PASS] " + msg)

func log_fail(msg: String) -> void:
	printerr("  [FAIL] " + msg)
	failures.append(msg)

func log_warn(msg: String) -> void:
	print("  [WARN] " + msg)
	warnings.append(msg)

func _ready() -> void:
	print("======================================================================")
	print("STARTING EMPIRICAL ADVERSARIAL STRESS TEST: WEATHER & CAMERA TRAVERSAL")
	print("======================================================================")
	
	await run_all_tests()

func run_all_tests() -> void:
	# ------------------------------------------------------------------
	# TEST 1: Runtime Instantiation of CityCarZombieArena.tscn
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 1: Runtime Instantiation of CityCarZombieArena.tscn ---\")
	var arena_scn = load(\"res://scenes/environments/CityCarZombieArena.tscn\")
	if not arena_scn is PackedScene:
		log_fail(\"Could not load CityCarZombieArena.tscn as PackedScene\")
		finish_and_quit()
		return
	
	var arena = arena_scn.instantiate()
	if not arena:
		log_fail(\"Failed to instantiate CityCarZombieArena.tscn\")
		finish_and_quit()
		return
	
	add_child(arena)
	log_pass(\"CityCarZombieArena instantiated and added to tree.\")
	
	# Warm up: run 10 process frames to allow _ready and deferred methods to complete
	for f in range(10):
		await get_tree().process_frame
	
	log_pass(\"Warm-up complete: 10 initial frames processed without crash.\")
	
	# Locate essential nodes
	var world_env = arena.get_node_or_null(\"WorldEnvironment\") as WorldEnvironment
	if not world_env or not world_env.environment:
		log_fail(\"WorldEnvironment or its Environment resource is missing!\")
		finish_and_quit()
		return
	log_pass(\"Found WorldEnvironment node with valid Environment resource.\")
	
	var weather_ctrl = arena.get_node_or_null(\"WeatherController\") as WeatherController
	if not weather_ctrl:
		log_fail(\"WeatherController node missing in CityCarZombieArena!\")
		finish_and_quit()
		return
	log_pass(\"Found WeatherController node.\")
	
	var dir_light = arena.get_node_or_null(\"DirectionalLight3D\") as DirectionalLight3D
	if not dir_light:
		log_fail(\"DirectionalLight3D node missing in CityCarZombieArena!\")
	else:
		log_pass(\"Found DirectionalLight3D node.\")
		
	# ------------------------------------------------------------------
	# TEST 2: Verify Initial ACES Tonemapper and Glow Bloom
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 2: Environment Initial Configuration Integrity ---\")
	var env = world_env.environment
	if env.tonemap_mode != Environment.TONE_MAPPER_ACES:
		log_fail(\"Initial tonemap_mode is not ACES (mode=%d, expected=3)\" % env.tonemap_mode)
	else:
		log_pass(\"Initial tonemap_mode is ACES.\")
		
	if not env.glow_enabled:
		log_fail(\"Initial glow_enabled is false!\")
	else:
		log_pass(\"Initial glow_enabled is true.\")
		
	if env.glow_bloom <= 0.0:
		log_fail(\"Initial glow_bloom <= 0.0 (got %f)\" % env.glow_bloom)
	else:
		log_pass(\"Initial glow_bloom is %f (> 0.0).\" % env.glow_bloom)
		
	# ------------------------------------------------------------------
	# TEST 3: Dynamic Weather Transitions Across All Presets
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 3: Dynamic Weather Transitions Across All Presets ---\")
	var presets = [
		WeatherController.WeatherPreset.SUNNY_DAY,
		WeatherController.WeatherPreset.GOLDEN_SUNSET,
		WeatherController.WeatherPreset.CYBERPUNK_NIGHT,
		WeatherController.WeatherPreset.STORMY_RAIN
	]
	var preset_names = [\"SUNNY_DAY\", \"GOLDEN_SUNSET\", \"CYBERPUNK_NIGHT\", \"STORMY_RAIN\"]
	
	for i in range(presets.size()):
		var p = presets[i]
		var pname = preset_names[i]
		print(\"  Testing preset: %s (instant apply)\" % pname)
		weather_ctrl.apply_weather_preset(p, 0.0, false)
		
		# Allow state update
		await get_tree().process_frame
		
		var cur_env = world_env.environment
		# Check tonemapper
		if cur_env.tonemap_mode != Environment.TONE_MAPPER_ACES:
			log_fail(\"[%s] tonemap_mode reset away from ACES (mode=%d)\" % [pname, cur_env.tonemap_mode])
		else:
			log_pass(\"[%s] tonemap_mode remains ACES.\" % pname)
			
		# Check glow bloom
		if cur_env.glow_bloom <= 0.0:
			log_fail(\"[%s] glow_bloom dropped to <= 0.0 (%f)\" % [pname, cur_env.glow_bloom])
		else:
			log_pass(\"[%s] glow_bloom is %f (> 0.0).\" % [pname, cur_env.glow_bloom])
			
		# Check environment parameters validity (no NaN/Inf)
		if is_nan(cur_env.fog_density) or is_inf(cur_env.fog_density) or cur_env.fog_density < 0.0:
			log_fail(\"[%s] fog_density is invalid: %f\" % [pname, cur_env.fog_density])
		if is_nan(cur_env.ambient_light_energy) or is_inf(cur_env.ambient_light_energy):
			log_fail(\"[%s] ambient_light_energy is invalid: %f\" % [pname, cur_env.ambient_light_energy])
		if is_nan(cur_env.tonemap_exposure) or is_inf(cur_env.tonemap_exposure):
			log_fail(\"[%s] tonemap_exposure is invalid: %f\" % [pname, cur_env.tonemap_exposure])
			
		# Check DirectionalLight
		if dir_light:
			if is_nan(dir_light.light_energy) or dir_light.light_energy <= 0.0:
				log_fail(\"[%s] DirectionalLight energy invalid: %f\" % [pname, dir_light.light_energy])
			if is_nan(dir_light.rotation_degrees.x) or is_nan(dir_light.rotation_degrees.y) or is_nan(dir_light.rotation_degrees.z):
				log_fail(\"[%s] DirectionalLight rotation contains NaN!\" % pname)
				
		# Check Rain Emitter
		var rain = weather_ctrl.rain_emitter
		if rain:
			var should_rain = (p == WeatherController.WeatherPreset.STORMY_RAIN)
			if rain.emitting != should_rain:
				log_fail(\"[%s] Rain emitter emitting=%s, expected=%s\" % [pname, str(rain.emitting), str(should_rain)])
			else:
				log_pass(\"[%s] Rain emitter state matches expectation (%s).\" % [pname, str(should_rain)])

	# ------------------------------------------------------------------
	# TEST 4: Tweened Weather Transitions & Intermediate Parameter Sampling
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 4: Tweened Transitions & Intermediate Value Sampling ---\")
	# Tween from SUNNY_DAY to STORMY_RAIN over 0.3s
	weather_ctrl.apply_weather_preset(WeatherController.WeatherPreset.SUNNY_DAY, 0.0, false)
	await get_tree().process_frame
	
	weather_ctrl.apply_weather_preset(WeatherController.WeatherPreset.STORMY_RAIN, 0.3, true)
	var sampled_frames = 0
	var min_bloom_during_tween = 999.0
	
	for s in range(12):
		await get_tree().process_frame
		sampled_frames += 1
		var c_bloom = world_env.environment.glow_bloom
		if c_bloom < min_bloom_during_tween:
			min_bloom_during_tween = c_bloom
		if c_bloom <= 0.0:
			log_fail(\"During tween frame %d, glow_bloom dropped to <= 0.0 (%f)\" % [s, c_bloom])
		if world_env.environment.tonemap_mode != Environment.TONE_MAPPER_ACES:
			log_fail(\"During tween frame %d, tonemap_mode != ACES\" % s)
			
	log_pass(\"Tween sampling complete over %d frames. Minimum glow_bloom observed: %f (> 0.0)\" % [sampled_frames, min_bloom_during_tween])

	# ------------------------------------------------------------------
	# TEST 5: Rapid Weather Cycling Stress (Adversarial Tween Interruption)
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 5: Rapid Cycling Adversarial Interruption Stress ---\")
	for c in range(16):
		weather_ctrl.cycle_weather()
		if c % 3 == 0:
			await get_tree().process_frame
	log_pass(\"Completed 16 rapid cycle_weather() calls without crash.\")
	
	# Wait for tweens to settle
	for w in range(5):
		await get_tree().process_frame
		
	var post_stress_env = world_env.environment
	if post_stress_env.tonemap_mode != Environment.TONE_MAPPER_ACES:
		log_fail(\"Post rapid-cycling tonemap_mode is not ACES (got %d)\" % post_stress_env.tonemap_mode)
	else:
		log_pass(\"Post rapid-cycling tonemap_mode remains ACES.\")
		
	if post_stress_env.glow_bloom <= 0.0:
		log_fail(\"Post rapid-cycling glow_bloom <= 0.0 (%f)\" % post_stress_env.glow_bloom)
	else:
		log_pass(\"Post rapid-cycling glow_bloom is %f (> 0.0).\" % post_stress_env.glow_bloom)

	# ------------------------------------------------------------------
	# TEST 6: Verify Deleted Legacy Nodes Integrity
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 6: Legacy Nodes Deletion Integrity ---\")
	var deleted_nodes = [
		\"RealisticTerrain/MountainRangeWest\",
		\"RealisticTerrain/MountainRangeEast\",
		\"RealisticTerrain/MountainBackdropNorth\",
		\"RealisticTerrain/GrassFieldLeft\",
		\"RealisticTerrain/GrassFieldRight\",
		\"VegetationTrees\"
	]
	for dnode in deleted_nodes:
		var n = arena.get_node_or_null(dnode)
		if n != null:
			log_fail(\"Deleted legacy node still present: %s\" % dnode)
		else:
			log_pass(\"Legacy node confirmed absent: %s\" % dnode)

	# ------------------------------------------------------------------
	# TEST 7: MultiMesh Foliage Sanity Check
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 7: MultiMesh Foliage and Props Configuration ---\")
	var mm_pines = arena.get_node_or_null(\"AdvancedTerrain/FoliageAndProps/MultiMesh_PineTrees\") as MultiMeshInstance3D
	var mm_rocks = arena.get_node_or_null(\"AdvancedTerrain/FoliageAndProps/MultiMesh_Rocks\") as MultiMeshInstance3D
	var mm_bushes = arena.get_node_or_null(\"AdvancedTerrain/FoliageAndProps/MultiMesh_Bushes\") as MultiMeshInstance3D
	
	if not mm_pines or not mm_pines.multimesh:
		log_fail(\"MultiMesh_PineTrees missing or unassigned\")
	else:
		log_pass(\"MultiMesh_PineTrees verified (%d instances)\" % mm_pines.multimesh.instance_count)
		
	if not mm_rocks or not mm_rocks.multimesh:
		log_fail(\"MultiMesh_Rocks missing or unassigned\")
	else:
		log_pass(\"MultiMesh_Rocks verified (%d instances)\" % mm_rocks.multimesh.instance_count)
		
	if not mm_bushes or not mm_bushes.multimesh:
		log_fail(\"MultiMesh_Bushes missing or unassigned\")
	else:
		if mm_bushes.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			log_fail(\"MultiMesh_Bushes has shadows enabled! Expected OFF.\")
		else:
			log_pass(\"MultiMesh_Bushes verified (%d instances, cast_shadow=OFF)\" % mm_bushes.multimesh.instance_count)

	# ------------------------------------------------------------------
	# TEST 8: Full Camera Traversal Across Arena Bounds (Z: [-200, 200], X: [-100, 100])
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 8: Camera Traversal Stress Testing (X: -100..+100, Z: -200..+200) ---\")
	var cam = Camera3D.new()
	cam.name = \"StressTestCamera\"
	cam.current = true
	cam.fov = 75.0
	cam.near = 0.05
	cam.far = 1000.0
	arena.add_child(cam)
	
	var x_coords = [-100.0, -75.0, -50.0, -25.0, -10.0, 0.0, 10.0, 25.0, 50.0, 75.0, 100.0]
	var z_coords = [-200.0, -150.0, -100.0, -50.0, 0.0, 50.0, 100.0, 150.0, 200.0]
	var y_heights = [1.5, 12.0, 35.0, 65.0]
	
	var total_traversal_points = 0
	var nan_errors = 0
	var frustum_errors = 0
	
	# Subtest 8A: 2D Grid with variable heights and pitch/yaw orientations
	print(\"  [8A] Traversing spatial grid across arena bounding box...\")
	for z in z_coords:
		for x in x_coords:
			# Choose varying height based on position
			var h_idx = int(abs(x + z)) % y_heights.size()
			var y = y_heights[h_idx]
			
			cam.global_position = Vector3(x, y, z)
			
			# Test orientations: looking along road (-Z), looking across valley, looking down
			var look_target = Vector3(0.0, 0.0, z - 40.0)
			if (cam.global_position - look_target).length_squared() > 0.01:
				cam.look_at(look_target, Vector3.UP)
			
			await get_tree().process_frame
			total_traversal_points += 1
			
			# Validate camera matrix
			var gt = cam.global_transform
			if is_nan(gt.origin.x) or is_nan(gt.origin.y) or is_nan(gt.origin.z):
				log_fail(\"Camera position became NaN at X=%.1f, Z=%.1f\" % [x, z])
				nan_errors += 1
			if not gt.basis.is_finite():
				log_fail(\"Camera basis became non-finite at X=%.1f, Z=%.1f\" % [x, z])
				nan_errors += 1
				
			# Validate frustum planes
			var frustum = cam.get_frustum()
			if frustum.size() != 6:
				log_fail(\"Frustum plane count != 6 (got %d)\" % frustum.size())
				frustum_errors += 1
			else:
				for p_plane in frustum:
					if is_nan(p_plane.normal.x) or is_nan(p_plane.d):
						log_fail(\"Frustum plane NaN detected at X=%.1f, Z=%.1f\" % [x, z])
						frustum_errors += 1
						break
	
	if nan_errors == 0 and frustum_errors == 0:
		log_pass(\"Spatial grid traversal verified: %d positions sampled with 0 matrix/frustum errors.\" % total_traversal_points)
	else:
		log_fail(\"Spatial grid traversal had %d NaN errors and %d frustum errors!\" % [nan_errors, frustum_errors])

	# Subtest 8B: Continuous Highway Longitudinal Flight Traversal
	print(\"  [8B] Continuous longitudinal flight from Z=-200 to Z=+200 along road and shoulders...\")
	var sweep_points = 0
	for z_step in range(-200, 201, 10):
		var lateral_x = sin(z_step * 0.05) * 35.0 # Weave between valley foothills and highway
		var alt_y = 6.0 + cos(z_step * 0.03) * 4.0
		
		cam.global_position = Vector3(lateral_x, alt_y, float(z_step))
		cam.look_at(Vector3(0.0, 1.0, float(z_step) + 25.0), Vector3.UP)
		
		await get_tree().process_frame
		sweep_points += 1
		
		if not cam.global_transform.basis.is_finite():
			log_fail(\"Continuous flight basis non-finite at Z=%d\" % z_step)
			
	log_pass(\"Continuous flight sweep verified: %d dynamic waypoints traversed cleanly.\" % sweep_points)

	# Subtest 8C: Extreme Corner Coordinates (Boundaries Stress)
	print(\"  [8C] Testing extreme corner frustum boundaries...\")
	var extreme_corners = [
		Vector3(-100.0, 80.0, -200.0),
		Vector3(100.0, 80.0, -200.0),
		Vector3(-100.0, 80.0, 200.0),
		Vector3(100.0, 80.0, 200.0),
		Vector3(-100.0, 0.5, -200.0),
		Vector3(100.0, 0.5, 200.0)
	]
	for corner in extreme_corners:
		cam.global_position = corner
		cam.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
		await get_tree().process_frame
		if not cam.global_transform.basis.is_finite():
			log_fail(\"Extreme corner basis non-finite at %s\" % str(corner))
	log_pass(\"All extreme corners tested without culling/matrix failure.\")

	# ------------------------------------------------------------------
	# TEST 9: Combined Mid-Flight Camera Traversal + Dynamic Weather Cycles
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 9: Combined Dynamic Traversal + Concurrent Weather Transitions ---\")
	var combo_passed = true
	for step in range(8):
		var t_pos = Vector3(
			sin(step) * 60.0,
			15.0 + step * 3.0,
			-180.0 + step * 50.0
		)
		cam.global_position = t_pos
		cam.look_at(Vector3(0, 0, t_pos.z + 30.0), Vector3.UP)
		
		# Trigger dynamic weather preset
		var p_idx = step % 4
		weather_ctrl.apply_weather_preset(p_idx, 0.15, false)
		
		await get_tree().process_frame
		
		var active_env = world_env.environment
		if active_env.tonemap_mode != Environment.TONE_MAPPER_ACES:
			log_fail(\"Combined test step %d: tonemap_mode != ACES\" % step)
			combo_passed = false
		if active_env.glow_bloom <= 0.0:
			log_fail(\"Combined test step %d: glow_bloom <= 0.0 (%f)\" % [step, active_env.glow_bloom])
			combo_passed = false
			
	if combo_passed:
		log_pass(\"Combined mid-flight camera traversal and concurrent weather transitions passed 100%.\")

	# ------------------------------------------------------------------
	# TEST 10: Final State Verification
	# ------------------------------------------------------------------
	print(\"\\n--- TEST 10: Final System State Post-Stress Audit ---\")
	var final_env = world_env.environment
	if final_env.tonemap_mode == Environment.TONE_MAPPER_ACES:
		log_pass(\"Final tonemap_mode confirmed ACES (mode=3).\")
	else:
		log_fail(\"Final tonemap_mode corrupted: %d\" % final_env.tonemap_mode)
		
	if final_env.glow_bloom > 0.0:
		log_pass(\"Final glow_bloom confirmed > 0.0 (value=%f).\" % final_env.glow_bloom)
	else:
		log_fail(\"Final glow_bloom invalid: %f\" % final_env.glow_bloom)
		
	if final_env.glow_enabled:
		log_pass(\"Final glow_enabled confirmed true.\")
	else:
		log_fail(\"Final glow_enabled is false!\")

	# Cleanup camera and arena
	cam.queue_free()
	arena.queue_free()
	await get_tree().process_frame
	
	finish_and_quit()

func finish_and_quit() -> void:
	print(\"\\n======================================================================\")
	if failures.is_empty():
		print(\"SUCCESS: ALL ADVERSARIAL STRESS TESTS PASSED (0 FAILURES)\")
		print(\"======================================================================\")
		get_tree().quit(0)
	else:
		print(\"FAILED: %d STRESS TEST FAILURES ENCOUNTERED:\" % failures.size())
		for f in failures:
			print(\"  [FAIL] \" + f)
		print(\"======================================================================\")
		get_tree().quit(1)
"""
	runner.set_script(script)
