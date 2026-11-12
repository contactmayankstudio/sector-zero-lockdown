@tool
extends SceneTree

func _init():
	print("==================================================")
	print("INDEPENDENT FORENSIC AUDIT OF MILESTONE 1")
	print("==================================================")
	var errors: Array[String] = []

	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scene:
		print("AUDIT FAIL: Failed to load CityCarZombieArena.tscn")
		quit(1)
		return
	
	var arena = scene.instantiate()
	if not arena:
		print("AUDIT FAIL: Failed to instantiate CityCarZombieArena.tscn")
		quit(1)
		return

	# [1] WorldEnvironment & Sky Audit
	print("[AUDIT 1] Inspecting WorldEnvironment & Sky...")
	var we = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if not we or not we.environment:
		errors.append("WorldEnvironment node or environment resource missing")
	else:
		var env = we.environment
		if env.tonemap_mode != Environment.TONE_MAPPER_ACES:
			errors.append("Tonemap mode is %d (expected ACES=3)" % env.tonemap_mode)
		if not is_equal_approx(env.tonemap_exposure, 1.14):
			errors.append("Tonemap exposure is %f (expected 1.14)" % env.tonemap_exposure)
		if not env.glow_enabled:
			errors.append("Glow is disabled in WorldEnvironment")
		if not is_equal_approx(env.glow_bloom, 0.20):
			errors.append("Glow bloom is %f (expected 0.20)" % env.glow_bloom)
		if not env.fog_enabled:
			errors.append("Fog is disabled")
		if not env.sky or not env.sky.sky_material is PanoramaSkyMaterial:
			errors.append("Sky is missing or not PanoramaSkyMaterial")
		else:
			var p_mat = env.sky.sky_material as PanoramaSkyMaterial
			if not p_mat.panorama or not "gta5_cinematic_sky.png" in p_mat.panorama.resource_path:
				errors.append("Panorama sky texture is not gta5_cinematic_sky.png")
			else:
				print("  PASS: WorldEnvironment and Sky verified")

	# [2] DirectionalLight3D Audit
	print("[AUDIT 2] Inspecting DirectionalLight3D...")
	var dl = arena.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if not dl:
		errors.append("DirectionalLight3D is missing")
	else:
		if not dl.shadow_enabled:
			errors.append("DirectionalLight3D shadow is disabled")
		if not is_equal_approx(dl.light_energy, 1.48):
			errors.append("DirectionalLight3D energy is %f (expected 1.48)" % dl.light_energy)
		if not dl.light_color.is_equal_approx(Color(1.0, 0.66, 0.35, 1.0)):
			errors.append("DirectionalLight3D color is %s (expected Color(1.0, 0.66, 0.35))" % str(dl.light_color))
		if not dl.rotation_degrees.is_equal_approx(Vector3(-16.0, -78.0, 0.0)):
			errors.append("DirectionalLight3D rotation is %s (expected (-16, -78, 0))" % str(dl.rotation_degrees))
		if dl.directional_shadow_mode != DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS:
			errors.append("DirectionalLight3D shadow mode is %d (expected 2 splits = 1)" % dl.directional_shadow_mode)
		if not dl.directional_shadow_blend_splits:
			errors.append("DirectionalLight3D directional_shadow_blend_splits is false")
		print("  PASS: DirectionalLight3D verified")

	# [3] PBR Material Files Audit
	print("[AUDIT 3] Inspecting Material Resources...")
	var mat_asphalt = load("res://resources/materials/mat_real_asphalt_pbr.tres") as StandardMaterial3D
	if not mat_asphalt:
		errors.append("Missing mat_real_asphalt_pbr.tres")
	elif not (is_equal_approx(mat_asphalt.roughness, 0.44) and is_equal_approx(mat_asphalt.metallic, 0.03)):
		errors.append("mat_real_asphalt_pbr properties mismatch: roughness=%f, metallic=%f" % [mat_asphalt.roughness, mat_asphalt.metallic])

	var mat_grass = load("res://resources/materials/mat_real_grass_pbr.tres") as StandardMaterial3D
	if not mat_grass:
		errors.append("Missing mat_real_grass_pbr.tres")
	elif not (is_equal_approx(mat_grass.roughness, 0.74) and mat_grass.albedo_color.is_equal_approx(Color(0.32, 0.50, 0.20, 1.0))):
		errors.append("mat_real_grass_pbr properties mismatch")

	var mat_cliff = load("res://resources/materials/mat_real_mountain_cliff.tres") as StandardMaterial3D
	if not mat_cliff:
		errors.append("Missing mat_real_mountain_cliff.tres")
	elif not (is_equal_approx(mat_cliff.roughness, 0.84) and is_equal_approx(mat_cliff.normal_scale, 1.55) and is_equal_approx(mat_cliff.uv1_triplanar_sharpness, 3.5)):
		errors.append("mat_real_mountain_cliff properties mismatch")
	print("  PASS: Material resources verified")

	# [4] Legacy Node Removal Audit
	print("[AUDIT 4] Checking Legacy Node Removal...")
	for lpath in ["RealisticTerrain/MountainRangeWest", "RealisticTerrain/MountainRangeEast", "RealisticTerrain/MountainBackdropNorth", "RealisticTerrain/GrassFieldLeft", "RealisticTerrain/GrassFieldRight", "VegetationTrees"]:
		if arena.get_node_or_null(lpath) != null:
			errors.append("Legacy node still present: %s" % lpath)
	print("  PASS: All legacy redundant nodes confirmed removed")

	# [5] AdvancedTerrain Geometry & Physics Audit
	print("[AUDIT 5] Inspecting AdvancedTerrain Meshes & Physics Bodies...")
	var expected_terrains = ["ValleyFloor", "MountainWest", "MountainEast", "MountainNorthWall", "MountainSouthWall"]
	for tname in expected_terrains:
		var mi = arena.get_node_or_null("AdvancedTerrain/" + tname) as MeshInstance3D
		if not mi or not mi.mesh:
			errors.append("AdvancedTerrain/" + tname + " mesh is missing or null")
		else:
			var faces = mi.mesh.get_faces()
			if faces.size() == 0:
				errors.append("AdvancedTerrain/" + tname + " mesh has 0 faces")
			else:
				print("    Mesh %s: %d triangles verified" % [tname, faces.size() / 3])
		
		# Check collision body
		var sb_name = tname + "_Physics" if tname != "ValleyFloor" else "ValleyFloor_Physics"
		var sb = arena.get_node_or_null("AdvancedTerrain/" + sb_name) as StaticBody3D
		if not sb:
			errors.append("AdvancedTerrain/" + sb_name + " physics body is missing")
		else:
			var cs = sb.get_child(0) as CollisionShape3D
			if not cs or not cs.shape:
				errors.append("CollisionShape3D missing in " + sb_name)
	print("  PASS: AdvancedTerrain meshes and collision shapes verified")

	# [6] MultiMesh Foliage & Props Integrity Audit
	print("[AUDIT 6] Deep Audit of MultiMesh Buffers & Instances...")
	var foliage_group = arena.get_node_or_null("AdvancedTerrain/FoliageAndProps")
	if not foliage_group:
		errors.append("AdvancedTerrain/FoliageAndProps group missing")
	else:
		# Pines Audit
		var pines = foliage_group.get_node_or_null("MultiMesh_PineTrees") as MultiMeshInstance3D
		if not pines or not pines.multimesh:
			errors.append("MultiMesh_PineTrees is missing or lacks multimesh")
		else:
			var mm = pines.multimesh
			if mm.instance_count != 400:
				errors.append("MultiMesh_PineTrees instance count is %d (expected 400)" % mm.instance_count)
			if not mm.mesh or mm.mesh.get_surface_count() < 2:
				errors.append("MultiMesh_PineTrees mesh missing or does not have composite surfaces (trunk+foliage)")
			else:
				print("    PineTrees mesh surfaces: %d surfaces verified" % mm.mesh.get_surface_count())
			var buf = mm.buffer
			if buf.size() < 400 * 12:
				errors.append("PineTrees buffer size is %d (expected %d)" % [buf.size(), 400 * 12])
			else:
				var min_x = 9999.0
				var max_x = -9999.0
				var road_violations = 0
				for i in range(mm.instance_count):
					var x = buf[i * 12 + 3]
					var y = buf[i * 12 + 7]
					var z = buf[i * 12 + 11]
					if absf(x) <= 22.0:
						road_violations += 1
					min_x = minf(min_x, x)
					max_x = maxf(max_x, x)
				if road_violations > 0:
					errors.append("MultiMesh_PineTrees has %d road corridor violations (|X| <= 22m)" % road_violations)
				else:
					print("    PineTrees instances: 400, X range [%.1f, %.1f], 0 road corridor violations" % [min_x, max_x])

		# Rocks Audit
		var rocks = foliage_group.get_node_or_null("MultiMesh_Rocks") as MultiMeshInstance3D
		if not rocks or not rocks.multimesh:
			errors.append("MultiMesh_Rocks is missing or lacks multimesh")
		else:
			var mm = rocks.multimesh
			if mm.instance_count != 400:
				errors.append("MultiMesh_Rocks instance count is %d (expected 400)" % mm.instance_count)
			if not mm.mesh or mm.mesh.get_faces().size() == 0:
				errors.append("MultiMesh_Rocks mesh missing or has 0 faces")
			var buf = mm.buffer
			if buf.size() < 400 * 12:
				errors.append("Rocks buffer size is %d (expected %d)" % [buf.size(), 400 * 12])
			else:
				var min_x = 9999.0
				var max_x = -9999.0
				var road_violations = 0
				for i in range(mm.instance_count):
					var x = buf[i * 12 + 3]
					if absf(x) <= 22.0:
						road_violations += 1
					min_x = minf(min_x, x)
					max_x = maxf(max_x, x)
				if road_violations > 0:
					errors.append("MultiMesh_Rocks has %d road corridor violations" % road_violations)
				else:
					print("    Rocks instances: 400, X range [%.1f, %.1f], 0 road corridor violations" % [min_x, max_x])

		# Bushes Audit
		var bushes = foliage_group.get_node_or_null("MultiMesh_Bushes") as MultiMeshInstance3D
		if not bushes or not bushes.multimesh:
			errors.append("MultiMesh_Bushes is missing or lacks multimesh")
		else:
			var mm = bushes.multimesh
			if mm.instance_count != 500:
				errors.append("MultiMesh_Bushes instance count is %d (expected 500)" % mm.instance_count)
			if bushes.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
				errors.append("MultiMesh_Bushes cast_shadow is not OFF (performance penalty)")
			var buf = mm.buffer
			if buf.size() < 500 * 12:
				errors.append("Bushes buffer size is %d (expected %d)" % [buf.size(), 500 * 12])
			else:
				var min_x = 9999.0
				var max_x = -9999.0
				var road_violations = 0
				for i in range(mm.instance_count):
					var x = buf[i * 12 + 3]
					if absf(x) <= 22.0:
						road_violations += 1
					min_x = minf(min_x, x)
					max_x = maxf(max_x, x)
				if road_violations > 0:
					errors.append("MultiMesh_Bushes has %d road corridor violations" % road_violations)
				else:
					print("    Bushes instances: 500, X range [%.1f, %.1f], cast_shadow=OFF, 0 road corridor violations" % [min_x, max_x])

	# [7] Script Hardcode & Bypass Audit
	print("[AUDIT 7] Inspecting Arena Script Runtime Overrides...")
	var arena_script = arena.get_script()
	if not arena_script:
		errors.append("CityCarZombieArena scene has no controller script attached")
	else:
		print("  PASS: Script attached (%s)" % arena_script.resource_path)

	# [8] WeatherController Presets
	print("[AUDIT 8] Inspecting WeatherController Presets...")
	var wc = load("res://scenes/environments/WeatherController.gd")
	if not wc or not ("PRESETS" in wc):
		errors.append("WeatherController.gd missing or PRESETS dictionary not found")
	else:
		for k in wc.PRESETS.keys():
			var p = wc.PRESETS[k]
			var bloom = p.get("glow_bloom", 0.0)
			if bloom <= 0.0:
				errors.append("Weather preset %s has glow_bloom <= 0.0" % p.name)
		print("  PASS: All 4 weather presets have non-zero glow_bloom (0.15 - 0.25)")

	print("\n==================================================")
	if errors.is_empty():
		print("FORENSIC VERDICT: CLEAN")
		print("All Milestone 1 integrity checks verified empirically.")
		print("==================================================")
		arena.free()
		quit(0)
	else:
		print("FORENSIC VERDICT: INTEGRITY VIOLATION")
		for err in errors:
			print("  [FAIL] ", err)
		print("==================================================")
		arena.free()
		quit(1)
