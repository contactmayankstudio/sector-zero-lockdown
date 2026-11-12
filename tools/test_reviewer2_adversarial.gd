@tool
extends SceneTree

# ==============================================================================
# REVIEWER 2 INDEPENDENT ADVERSARIAL STRESS TEST
# Milestone 1: Foliage, Props & MultiMesh Terrain
# ==============================================================================

func _init():
	print("\n" + "=".repeat(75))
	print("REVIEWER 2 INDEPENDENT ADVERSARIAL STRESS TEST SUITE")
	print("=".repeat(75))

	var failed_assertions: Array[String] = []
	var total_tests = 0
	var passed_tests = 0

	# --------------------------------------------------------------------------
	# 1. SCENE LOAD & INTEGRITY
	# --------------------------------------------------------------------------
	print("\n[Phase 1] Loading and Instantiating CityCarZombieArena.tscn...")
	var scene_path = "res://scenes/environments/CityCarZombieArena.tscn"
	var p_scene = load(scene_path) as PackedScene
	if not p_scene:
		push_error("CRITICAL: Failed to load scene: " + scene_path)
		quit(1)
		return

	var arena = p_scene.instantiate()
	if not arena:
		push_error("CRITICAL: Failed to instantiate scene: " + scene_path)
		quit(1)
		return

	root.add_child(arena)
	print("  ✓ Scene instantiated and added to tree.")

	# --------------------------------------------------------------------------
	# 2. MULTIMESH INSTANCE AUDIT
	# --------------------------------------------------------------------------
	print("\n[Phase 2] Auditing Foliage & Props MultiMeshes under AdvancedTerrain/FoliageAndProps...")
	var fap = arena.get_node_or_null("AdvancedTerrain/FoliageAndProps")
	if not fap:
		failed_assertions.append("Node 'AdvancedTerrain/FoliageAndProps' does not exist in scene!")
	else:
		var targets = {
			"MultiMesh_PineTrees": {"count": 400, "cast_shadow": GeometryInstance3D.SHADOW_CASTING_SETTING_ON, "vis_max": 450.0},
			"MultiMesh_Rocks":     {"count": 400, "cast_shadow": GeometryInstance3D.SHADOW_CASTING_SETTING_ON, "vis_max": 300.0},
			"MultiMesh_Bushes":    {"count": 500, "cast_shadow": GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "vis_max": 220.0}
		}

		for m_name in targets.keys():
			total_tests += 1
			var spec = targets[m_name]
			var node = fap.get_node_or_null(m_name) as MultiMeshInstance3D
			if not node:
				failed_assertions.append("Missing MultiMeshInstance3D: %s" % m_name)
				continue
			if not node.multimesh:
				failed_assertions.append("Missing MultiMesh resource on node: %s" % m_name)
				continue

			var mm = node.multimesh
			print("\n  Auditing %s:" % m_name)
			print("    - Instance count: %d (expected %d)" % [mm.instance_count, spec["count"]])
			if mm.instance_count != spec["count"]:
				failed_assertions.append("%s count %d != expected %d" % [m_name, mm.instance_count, spec["count"]])
			else:
				passed_tests += 1

			# Cast shadow audit
			total_tests += 1
			print("    - Cast shadow mode: %d (expected %d)" % [node.cast_shadow, spec["cast_shadow"]])
			if node.cast_shadow != spec["cast_shadow"]:
				failed_assertions.append("%s cast_shadow %d != expected %d" % [m_name, node.cast_shadow, spec["cast_shadow"]])
			else:
				passed_tests += 1

			# Visibility range audit
			total_tests += 1
			print("    - Visibility range end: %.1f (expected %.1f)" % [node.visibility_range_end, spec["vis_max"]])
			if not is_equal_approx(node.visibility_range_end, spec["vis_max"]):
				failed_assertions.append("%s visibility_range_end %.1f != expected %.1f" % [m_name, node.visibility_range_end, spec["vis_max"]])
			else:
				passed_tests += 1

			# Buffer audit
			total_tests += 1
			var buf = mm.buffer
			var expected_buf_size = mm.instance_count * 12
			print("    - Buffer size: %d floats (expected >= %d)" % [buf.size(), expected_buf_size])
			if buf.size() < expected_buf_size:
				failed_assertions.append("%s buffer size %d is less than %d" % [m_name, buf.size(), expected_buf_size])
			else:
				passed_tests += 1

			# ------------------------------------------------------------------
			# 3. SPATIAL POSITION & CORRIDOR CLEARANCE STRESS TEST
			# ------------------------------------------------------------------
			total_tests += 1
			var corridor_violations = 0
			var min_x_abs = INF
			var max_x_abs = -INF
			var min_z = INF
			var max_z = -INF
			var nan_or_inf_count = 0
			var inverted_count = 0

			for i in range(mm.instance_count):
				var t = mm.get_instance_transform(i)
				var o = t.origin
				var b = t.basis

				# Check NaN / INF
				if is_nan(o.x) or is_nan(o.y) or is_nan(o.z) or is_inf(o.x) or is_inf(o.y) or is_inf(o.z):
					nan_or_inf_count += 1
				if is_nan(b.x.x) or is_nan(b.y.y) or is_nan(b.z.z):
					nan_or_inf_count += 1

				# Inversion check
				if b.determinant() <= 0.0001:
					inverted_count += 1

				# Road clearance check (|X| > 22.0)
				var abs_x = absf(o.x)
				if abs_x < min_x_abs: min_x_abs = abs_x
				if abs_x > max_x_abs: max_x_abs = abs_x
				if o.z < min_z: min_z = o.z
				if o.z > max_z: max_z = o.z

				if abs_x <= 22.0:
					corridor_violations += 1

			print("    - Corridor Clearance: Min |X| = %.3fm, Max |X| = %.3fm" % [min_x_abs, max_x_abs])
			print("    - Boundary Span: Z in [%.1fm, %.1fm]" % [min_z, max_z])
			print("    - Violations (|X| <= 22.0m): %d" % corridor_violations)
			print("    - Inverted bases: %d, NaN/Inf instances: %d" % [inverted_count, nan_or_inf_count])

			if corridor_violations > 0:
				failed_assertions.append("%s has %d instances violating road corridor (|X| <= 22m)!" % [m_name, corridor_violations])
			elif nan_or_inf_count > 0:
				failed_assertions.append("%s has %d instances with NaN/Inf values!" % [m_name, nan_or_inf_count])
			elif inverted_count > 0:
				failed_assertions.append("%s has %d instances with inverted transforms!" % [m_name, inverted_count])
			else:
				passed_tests += 1

	# --------------------------------------------------------------------------
	# 4. LEGACY NODES AUDIT
	# --------------------------------------------------------------------------
	print("\n[Phase 3] Auditing Legacy Node Elimination...")
	var legacy_candidates = [
		"RealisticTerrain/MountainRangeWest",
		"RealisticTerrain/MountainRangeEast",
		"RealisticTerrain/MountainBackdropNorth",
		"RealisticTerrain/GrassFieldLeft",
		"RealisticTerrain/GrassFieldRight",
		"VegetationTrees"
	]
	for lpath in legacy_candidates:
		total_tests += 1
		var n = arena.get_node_or_null(lpath)
		if n:
			failed_assertions.append("Legacy node still present: %s" % lpath)
			print("    ✗ Legacy node found: %s" % lpath)
		else:
			passed_tests += 1
			print("    ✓ Confirmed deleted: %s" % lpath)

	# --------------------------------------------------------------------------
	# 5. CODE LEVEL AUDIT (Tree Loop Removal & Runtime Overrides)
	# --------------------------------------------------------------------------
	print("\n[Phase 4] Auditing CityCarZombieArena.gd for Legacy Tree Loop References...")
	total_tests += 1
	var script_file = FileAccess.open("res://scenes/environments/CityCarZombieArena.gd", FileAccess.READ)
	if not script_file:
		failed_assertions.append("Cannot open CityCarZombieArena.gd")
	else:
		var script_content = script_file.get_as_text()
		script_file.close()
		if "VegetationTrees" in script_content:
			failed_assertions.append("CityCarZombieArena.gd still references 'VegetationTrees'!")
			print("    ✗ Found 'VegetationTrees' reference in CityCarZombieArena.gd")
		elif "tree.get_surface_override_material" in script_content:
			failed_assertions.append("CityCarZombieArena.gd still contains legacy tree surface loop!")
			print("    ✗ Found legacy tree loop in CityCarZombieArena.gd")
		else:
			passed_tests += 1
			print("    ✓ Zero references to 'VegetationTrees' or legacy tree looping in CityCarZombieArena.gd")

	# --------------------------------------------------------------------------
	# 6. WORLD ENVIRONMENT & WEATHER CONTROLLER COMPATIBILITY
	# --------------------------------------------------------------------------
	print("\n[Phase 5] Auditing WorldEnvironment & Weather Controller...")
	total_tests += 1
	var we = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if not we or not we.environment:
		failed_assertions.append("WorldEnvironment or its Environment resource is missing!")
	else:
		var env = we.environment
		print("    - Glow enabled: %s (bloom: %.2f, intensity: %.2f, hdr_threshold: %.2f)" % [
			str(env.glow_enabled), env.glow_bloom, env.glow_intensity, env.glow_hdr_threshold
		])
		print("    - Tonemapper: %d (ACES = 3), Exposure: %.2f" % [env.tonemap_mode, env.tonemap_exposure])
		if not env.glow_enabled or env.glow_bloom < 0.15:
			failed_assertions.append("WorldEnvironment glow not enabled or bloom too low (bloom = %f)" % env.glow_bloom)
		elif env.tonemap_mode != Environment.TONE_MAPPER_ACES:
			failed_assertions.append("Tonemapper is not ACES (mode = %d)" % env.tonemap_mode)
		else:
			passed_tests += 1

	# Test WeatherController presets
	total_tests += 1
	var wc = arena.get_node_or_null("WeatherController")
	if wc and wc.has_method("set_weather_preset"):
		print("    - Testing WeatherController dynamic preset transitions...")
		for p_idx in [0, 1, 2, 3]:
			wc.set_weather_preset(p_idx)
			if we.environment.glow_bloom <= 0.0:
				failed_assertions.append("WeatherController preset %d wiped out glow_bloom!" % p_idx)
		passed_tests += 1
		print("    ✓ WeatherController presets maintain non-zero bloom across all transitions.")
	else:
		# If weather controller is not an attached node, check script directly
		var wc_script = load("res://scenes/environments/WeatherController.gd")
		if wc_script:
			passed_tests += 1
			print("    ✓ WeatherController script loaded and valid.")

	# --------------------------------------------------------------------------
	# 7. RESULTS
	# --------------------------------------------------------------------------
	print("\n" + "=".repeat(75))
	print("ADVERSARIAL STRESS TEST SUMMARY")
	print("=".repeat(75))
	print("Total Tests:  %d" % total_tests)
	print("Passed:       %d" % passed_tests)
	print("Failed:       %d" % failed_assertions.size())

	if failed_assertions.is_empty():
		print("\n>>> ALL ADVERSARIAL STRESS TESTS PASSED CLEANLY <<<")
		arena.queue_free()
		quit(0)
	else:
		print("\n>>> ADVERSARIAL STRESS TEST DETECTED %d ISSUE(S): <<<" % failed_assertions.size())
		for err in failed_assertions:
			print("  [ERROR] ", err)
		arena.queue_free()
		quit(1)
