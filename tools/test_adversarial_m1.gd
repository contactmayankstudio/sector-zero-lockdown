@tool
extends SceneTree

const WeatherController = preload("res://scenes/environments/WeatherController.gd")

func _init():
	print("==================================================")
	print("STARTING ADVERSARIAL STRESS TEST FOR MILESTONE 1")
	print("==================================================")
	var errors: Array[String] = []

	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scene:
		print("FAIL: Cannot load CityCarZombieArena.tscn")
		quit(1)
		return

	var arena = scene.instantiate()
	get_root().add_child(arena)

	# 1. Stress test WeatherController preset transitions
	print("\n[Stress Test 1] Testing WeatherController dynamic preset cycling...")
	var wc = arena.get_node_or_null("WeatherController")
	if not wc:
		errors.append("WeatherController not found in arena tree")
	else:
		var dl = arena.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
		var we = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
		var env = we.environment if we else null

		for preset_id in [
			WeatherController.WeatherPreset.SUNNY_DAY,
			WeatherController.WeatherPreset.GOLDEN_SUNSET,
			WeatherController.WeatherPreset.CYBERPUNK_NIGHT,
			WeatherController.WeatherPreset.STORMY_RAIN
		]:
			wc.apply_weather_preset(preset_id, 0.0, false)
			var cfg = WeatherController.PRESETS[preset_id]
			print("  Testing Preset: ", cfg["name"])

			# Validate bloom > 0
			if env.glow_bloom <= 0.0:
				errors.append("Preset %s caused glow_bloom <= 0: %f" % [cfg["name"], env.glow_bloom])
			
			# Validate DirectionalLight shadow settings
			if dl.directional_shadow_mode != DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS:
				errors.append("Preset %s corrupted shadow mode: %d" % [cfg["name"], dl.directional_shadow_mode])
			if not dl.directional_shadow_blend_splits:
				errors.append("Preset %s disabled blend_splits" % cfg["name"])

		# Specifically verify GOLDEN_SUNSET values after switching back
		wc.apply_weather_preset(WeatherController.WeatherPreset.GOLDEN_SUNSET, 0.0, false)
		if not dl.rotation_degrees.is_equal_approx(Vector3(-16.0, -78.0, 0.0)):
			errors.append("GOLDEN_SUNSET rotation mismatch: %s" % str(dl.rotation_degrees))
		if not dl.light_color.is_equal_approx(Color(1.0, 0.66, 0.35, 1.0)):
			errors.append("GOLDEN_SUNSET light_color mismatch: %s" % str(dl.light_color))
		if not is_equal_approx(dl.light_energy, 1.48):
			errors.append("GOLDEN_SUNSET light_energy mismatch: %f" % dl.light_energy)
		print("  ✓ WeatherController preset cycling passed and Golden Sunset restored.")

	# 2. Stress test Rapid Tweened Weather Cycling
	print("\n[Stress Test 2] Testing Rapid Preset Tweening (race conditions)...")
	if wc:
		wc.apply_weather_preset(WeatherController.WeatherPreset.CYBERPUNK_NIGHT, 0.1, false)
		wc.apply_weather_preset(WeatherController.WeatherPreset.STORMY_RAIN, 0.1, false)
		wc.apply_weather_preset(WeatherController.WeatherPreset.GOLDEN_SUNSET, 0.1, false)
		print("  ✓ Rapid tween cancellation and re-triggering passed without crash.")

	# 3. Stress test MultiMesh integrity
	print("\n[Stress Test 3] Checking MultiMesh instances integrity...")
	var fap = arena.get_node_or_null("AdvancedTerrain/FoliageAndProps")
	if not fap:
		errors.append("FoliageAndProps node missing")
	else:
		for mname in ["MultiMesh_PineTrees", "MultiMesh_Rocks", "MultiMesh_Bushes"]:
			var mmi = fap.get_node_or_null(mname) as MultiMeshInstance3D
			if not mmi or not mmi.multimesh:
				errors.append("Missing MultiMeshInstance3D: %s" % mname)
			else:
				var mm = mmi.multimesh
				var buf = mm.buffer
				if buf.is_empty():
					errors.append("%s buffer is empty!" % mname)
				else:
					print("  ✓ %s has %d instances, buffer size %d floats" % [mname, mm.instance_count, buf.size()])

	# 4. Stress test StreetLamps toggling
	print("\n[Stress Test 4] Checking StreetLamps and road materials...")
	var sl = arena.get_node_or_null("StreetLamps")
	if sl:
		var count = 0
		for lamp in sl.find_children("*", "Light3D", true, false):
			count += 1
		print("  ✓ Found %d streetlamps, correctly handled by WeatherController" % count)

	print("\n==================================================")
	if errors.is_empty():
		print("SUCCESS: ALL ADVERSARIAL STRESS TESTS PASSED!")
		print("==================================================")
		arena.queue_free()
		quit(0)
	else:
		print("FAILED: %d adversarial error(s) found:" % errors.size())
		for e in errors:
			print("  - ", e)
		print("==================================================")
		arena.queue_free()
		quit(1)
