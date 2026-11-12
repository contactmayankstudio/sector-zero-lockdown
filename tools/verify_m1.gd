@tool
extends SceneTree

func _init():
	print("==================================================")
	print("STARTING COMPREHENSIVE MILESTONE 1 VERIFICATION")
	print("==================================================")
	var errors: Array[String] = []

	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scene:
		print("FAIL: Cannot load CityCarZombieArena.tscn")
		quit(1)
		return
	
	var arena = scene.instantiate()
	if not arena:
		print("FAIL: Cannot instantiate CityCarZombieArena.tscn")
		quit(1)
		return

	# -----------------------------------------------------------------
	# 1. WorldEnvironment & Sky Verification
	# -----------------------------------------------------------------
	print("\n[1] Checking WorldEnvironment & Sky...")
	var we = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if not we or not we.environment:
		errors.append("WorldEnvironment node or environment resource missing")
	else:
		var env = we.environment
		if env.tonemap_mode != Environment.TONE_MAPPER_ACES:
			errors.append("Tonemapper is not ACES (got %d, expected 3)" % env.tonemap_mode)
		if not is_equal_approx(env.tonemap_exposure, 1.14):
			errors.append("Tonemap exposure != 1.14 (got %f)" % env.tonemap_exposure)
		if not env.glow_enabled:
			errors.append("Glow is not enabled")
		if not is_equal_approx(env.glow_bloom, 0.20):
			errors.append("Glow bloom != 0.20 (got %f)" % env.glow_bloom)
		if not is_equal_approx(env.glow_intensity, 0.50):
			errors.append("Glow intensity != 0.50 (got %f)" % env.glow_intensity)
		if not is_equal_approx(env.glow_hdr_threshold, 0.95):
			errors.append("Glow hdr threshold != 0.95 (got %f)" % env.glow_hdr_threshold)
		if env.glow_blend_mode != Environment.GLOW_BLEND_MODE_SOFTLIGHT:
			errors.append("Glow blend mode is not SOFTLIGHT (got %d)" % env.glow_blend_mode)
		if not env.fog_enabled:
			errors.append("Fog is not enabled")
		if not env.fog_light_color.is_equal_approx(Color(0.95, 0.62, 0.35, 1.0)):
			errors.append("Fog light color != (0.95, 0.62, 0.35) (got %s)" % str(env.fog_light_color))
		if not env.ambient_light_color.is_equal_approx(Color(0.88, 0.65, 0.48, 1.0)):
			errors.append("Ambient light color != (0.88, 0.65, 0.48) (got %s)" % str(env.ambient_light_color))

		# Sky Resource
		var sky = env.sky
		if not sky:
			errors.append("Environment sky missing")
		elif not sky.sky_material is PanoramaSkyMaterial:
			errors.append("Sky material is not PanoramaSkyMaterial")
		else:
			var p_mat = sky.sky_material as PanoramaSkyMaterial
			var p_tex = p_mat.panorama
			if not p_tex:
				errors.append("Sky panorama texture missing")
			elif not "gta5_cinematic_sky.png" in p_tex.resource_path:
				errors.append("Sky texture is not gta5_cinematic_sky.png (got %s)" % p_tex.resource_path)
			else:
				print("  ✓ Sky panorama texture: ", p_tex.resource_path)

	# -----------------------------------------------------------------
	# 2. DirectionalLight3D Verification
	# -----------------------------------------------------------------
	print("\n[2] Checking DirectionalLight3D...")
	var dl = arena.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if not dl:
		errors.append("DirectionalLight3D missing")
	else:
		if not dl.shadow_enabled:
			errors.append("DirectionalLight3D shadow is not enabled")
		if not is_equal_approx(dl.light_energy, 1.48):
			errors.append("DirectionalLight3D energy != 1.48 (got %f)" % dl.light_energy)
		if not dl.light_color.is_equal_approx(Color(1.0, 0.66, 0.35, 1.0)):
			errors.append("DirectionalLight3D color != (1.0, 0.66, 0.35) (got %s)" % str(dl.light_color))
		if not is_equal_approx(dl.shadow_bias, 0.035):
			errors.append("DirectionalLight3D shadow bias != 0.035 (got %f)" % dl.shadow_bias)
		if dl.directional_shadow_mode != DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS:
			errors.append("DirectionalLight3D shadow mode != SHADOW_PARALLEL_2_SPLITS (got %d)" % dl.directional_shadow_mode)
		if not dl.directional_shadow_blend_splits:
			errors.append("DirectionalLight3D directional_shadow_blend_splits is false")
		if not is_equal_approx(dl.directional_shadow_max_distance, 85.0):
			errors.append("DirectionalLight3D max shadow distance != 85.0 (got %f)" % dl.directional_shadow_max_distance)
		if not dl.rotation_degrees.is_equal_approx(Vector3(-16.0, -78.0, 0.0)):
			errors.append("DirectionalLight3D rotation != (-16, -78, 0) (got %s)" % str(dl.rotation_degrees))
		else:
			print("  ✓ DirectionalLight3D rotation degrees: ", dl.rotation_degrees)
			print("  ✓ DirectionalLight3D color & energy: ", dl.light_color, " @ ", dl.light_energy)

	# -----------------------------------------------------------------
	# 3. Materials PBR Resources Verification
	# -----------------------------------------------------------------
	print("\n[3] Checking PBR Material Resources (.tres)...")
	var mat_asphalt = load("res://resources/materials/mat_real_asphalt_pbr.tres") as StandardMaterial3D
	if not mat_asphalt:
		errors.append("Cannot load mat_real_asphalt_pbr.tres")
	else:
		if not is_equal_approx(mat_asphalt.roughness, 0.44):
			errors.append("Asphalt roughness != 0.44 (got %f)" % mat_asphalt.roughness)
		if not is_equal_approx(mat_asphalt.metallic_specular, 0.60):
			errors.append("Asphalt specular != 0.60 (got %f)" % mat_asphalt.metallic_specular)
		if not is_equal_approx(mat_asphalt.metallic, 0.03):
			errors.append("Asphalt metallic != 0.03 (got %f)" % mat_asphalt.metallic)
		if not is_equal_approx(mat_asphalt.normal_scale, 0.95):
			errors.append("Asphalt normal_scale != 0.95 (got %f)" % mat_asphalt.normal_scale)
		print("  ✓ mat_real_asphalt_pbr: roughness=%.2f, specular=%.2f, metallic=%.2f, normal=%.2f" % [
			mat_asphalt.roughness, mat_asphalt.metallic_specular, mat_asphalt.metallic, mat_asphalt.normal_scale
		])

	var mat_grass = load("res://resources/materials/mat_real_grass_pbr.tres") as StandardMaterial3D
	if not mat_grass:
		errors.append("Cannot load mat_real_grass_pbr.tres")
	else:
		if not mat_grass.albedo_color.is_equal_approx(Color(0.32, 0.50, 0.20, 1.0)):
			errors.append("Grass albedo != (0.32, 0.50, 0.20) (got %s)" % str(mat_grass.albedo_color))
		if not is_equal_approx(mat_grass.roughness, 0.74):
			errors.append("Grass roughness != 0.74 (got %f)" % mat_grass.roughness)
		if not is_equal_approx(mat_grass.metallic_specular, 0.28):
			errors.append("Grass specular != 0.28 (got %f)" % mat_grass.metallic_specular)
		if not is_equal_approx(mat_grass.normal_scale, 0.90):
			errors.append("Grass normal_scale != 0.90 (got %f)" % mat_grass.normal_scale)
		print("  ✓ mat_real_grass_pbr: albedo=%s, roughness=%.2f, specular=%.2f, normal=%.2f" % [
			str(mat_grass.albedo_color), mat_grass.roughness, mat_grass.metallic_specular, mat_grass.normal_scale
		])

	var mat_mtn = load("res://resources/materials/mat_real_mountain_cliff.tres") as StandardMaterial3D
	if not mat_mtn:
		errors.append("Cannot load mat_real_mountain_cliff.tres")
	else:
		if not mat_mtn.albedo_color.is_equal_approx(Color(0.48, 0.46, 0.44, 1.0)):
			errors.append("Mountain albedo != (0.48, 0.46, 0.44) (got %s)" % str(mat_mtn.albedo_color))
		if not is_equal_approx(mat_mtn.roughness, 0.84):
			errors.append("Mountain roughness != 0.84 (got %f)" % mat_mtn.roughness)
		if not is_equal_approx(mat_mtn.normal_scale, 1.55):
			errors.append("Mountain normal_scale != 1.55 (got %f)" % mat_mtn.normal_scale)
		if not is_equal_approx(mat_mtn.uv1_triplanar_sharpness, 3.5):
			errors.append("Mountain uv1_triplanar_sharpness != 3.5 (got %f)" % mat_mtn.uv1_triplanar_sharpness)
		print("  ✓ mat_real_mountain_cliff: albedo=%s, roughness=%.2f, normal=%.2f, tri_sharp=%.1f" % [
			str(mat_mtn.albedo_color), mat_mtn.roughness, mat_mtn.normal_scale, mat_mtn.uv1_triplanar_sharpness
		])

	# -----------------------------------------------------------------
	# 4. Legacy Duplicate Node Cleanup Verification
	# -----------------------------------------------------------------
	print("\n[4] Checking Legacy Node Cleanup...")
	var legacy_nodes = [
		"RealisticTerrain/MountainRangeWest",
		"RealisticTerrain/MountainRangeEast",
		"RealisticTerrain/MountainBackdropNorth",
		"RealisticTerrain/GrassFieldLeft",
		"RealisticTerrain/GrassFieldRight",
		"VegetationTrees"
	]
	for lpath in legacy_nodes:
		var n = arena.get_node_or_null(lpath)
		if n:
			errors.append("Legacy node still exists: %s" % lpath)
		else:
			print("  ✓ Cleaned up legacy node: %s" % lpath)

	# -----------------------------------------------------------------
	# 5. Foliage MultiMesh Verification
	# -----------------------------------------------------------------
	print("\n[5] Checking Foliage & MultiMeshes under AdvancedTerrain/FoliageAndProps...")
	var foliage_props = arena.get_node_or_null("AdvancedTerrain/FoliageAndProps")
	if not foliage_props:
		errors.append("AdvancedTerrain/FoliageAndProps missing")
	else:
		# Pines
		var pines = foliage_props.get_node_or_null("MultiMesh_PineTrees") as MultiMeshInstance3D
		if not pines or not pines.multimesh:
			errors.append("MultiMesh_PineTrees or its multimesh missing")
		else:
			var count = pines.multimesh.instance_count
			print("  ✓ MultiMesh_PineTrees count: ", count)
			if count < 350 or count > 450:
				errors.append("MultiMesh_PineTrees count out of expected ~400 range (got %d)" % count)
			var buf = pines.multimesh.buffer
			if buf.size() < count * 12:
				errors.append("MultiMesh_PineTrees buffer size is insufficient (got %d, expected %d)" % [buf.size(), count * 12])
			else:
				var road_violations = 0
				for i in range(count):
					var x = buf[i * 12 + 3]
					if absf(x) <= 22.0:
						road_violations += 1
				if road_violations > 0:
					errors.append("MultiMesh_PineTrees has %d instances within road corridor (|X| <= 22)" % road_violations)
				else:
					print("  ✓ All %d PineTrees respect road exclusion (|X| > 22m)" % count)

		# Rocks
		var rocks = foliage_props.get_node_or_null("MultiMesh_Rocks") as MultiMeshInstance3D
		if not rocks or not rocks.multimesh:
			errors.append("MultiMesh_Rocks or its multimesh missing")
		else:
			var count = rocks.multimesh.instance_count
			print("  ✓ MultiMesh_Rocks count: ", count)
			if count < 350 or count > 450:
				errors.append("MultiMesh_Rocks count out of expected ~400 range (got %d)" % count)
			var buf = rocks.multimesh.buffer
			if buf.size() < count * 12:
				errors.append("MultiMesh_Rocks buffer size is insufficient (got %d, expected %d)" % [buf.size(), count * 12])
			else:
				var road_violations = 0
				for i in range(count):
					var x = buf[i * 12 + 3]
					if absf(x) <= 22.0:
						road_violations += 1
				if road_violations > 0:
					errors.append("MultiMesh_Rocks has %d instances within road corridor (|X| <= 22)" % road_violations)
				else:
					print("  ✓ All %d Rocks respect road exclusion (|X| > 22m)" % count)

		# Bushes
		var bushes = foliage_props.get_node_or_null("MultiMesh_Bushes") as MultiMeshInstance3D
		if not bushes or not bushes.multimesh:
			errors.append("MultiMesh_Bushes or its multimesh missing")
		else:
			var count = bushes.multimesh.instance_count
			print("  ✓ MultiMesh_Bushes count: ", count)
			if count < 450 or count > 550:
				errors.append("MultiMesh_Bushes count out of expected ~500 range (got %d)" % count)
			if bushes.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
				errors.append("MultiMesh_Bushes cast_shadow != SHADOW_CASTING_SETTING_OFF")
			else:
				print("  ✓ MultiMesh_Bushes cast_shadow is OFF (optimal performance)")
			var buf = bushes.multimesh.buffer
			if buf.size() < count * 12:
				errors.append("MultiMesh_Bushes buffer size is insufficient (got %d, expected %d)" % [buf.size(), count * 12])
			else:
				var road_violations = 0
				for i in range(count):
					var x = buf[i * 12 + 3]
					if absf(x) <= 22.0:
						road_violations += 1
				if road_violations > 0:
					errors.append("MultiMesh_Bushes has %d instances within road corridor (|X| <= 22)" % road_violations)
				else:
					print("  ✓ All %d Bushes respect road exclusion (|X| > 22m)" % count)

	# -----------------------------------------------------------------
	# 6. WeatherController Presets Verification
	# -----------------------------------------------------------------
	print("\n[6] Checking WeatherController Presets...")
	var wc_script = load("res://scenes/environments/WeatherController.gd")
	if wc_script:
		var presets = wc_script.PRESETS
		for k in presets.keys():
			var p = presets[k]
			var bloom = p.get("glow_bloom", 0.0)
			if bloom <= 0.0:
				errors.append("Weather preset %s has glow_bloom <= 0.0 (got %f)" % [p.name, bloom])
			else:
				print("  ✓ Preset %s glow_bloom: %.2f" % [p.name, bloom])

	# -----------------------------------------------------------------
	# Final Report
	# -----------------------------------------------------------------
	print("\n==================================================")
	if errors.is_empty():
		print("SUCCESS: ALL MILESTONE 1 VERIFICATION CHECKS PASSED!")
		print("==================================================")
		arena.free()
		quit(0)
	else:
		print("FAILED: %d verification error(s) found:" % errors.size())
		for e in errors:
			print("  - ", e)
		print("==================================================")
		arena.free()
		quit(1)
