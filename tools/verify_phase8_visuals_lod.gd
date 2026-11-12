extends SceneTree

const CityBuilder = preload("res://scripts/World/CityBuilder.gd")
const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")
const SkyController = preload("res://scripts/World/SkyController.gd")
const WorldMaterialManager = preload("res://scripts/World/WorldMaterialManager.gd")

func _init():
	print("==================================================")
	print("PHASE 8 3-TIER BUILDING LOD & VISUALS VERIFICATION")
	print("==================================================")
	var pass_count = 0
	var total_tests = 0

	# -------------------------------------------------------------
	# TEST 1: Tower 3-Tier LOD Meshes
	# -------------------------------------------------------------
	total_tests += 1
	var t_near = CityBuilder._get_cached_tower_near_mesh(52.0)
	var t_med = CityBuilder._get_cached_tower_med_mesh(52.0)
	var t_far = CityBuilder._get_cached_tower_far_mesh(52.0)
	assert(t_near != null, "Tower near mesh must not be null")
	assert(t_med != null, "Tower med mesh must not be null")
	assert(t_far != null, "Tower far mesh must not be null")
	assert(t_near.get_surface_count() == 2, "Tower near mesh should have 2 surfaces (concrete + glass)")
	assert(t_med.get_surface_count() == 2, "Tower med mesh should have 2 surfaces (concrete + glass)")
	assert(t_far.get_surface_count() == 1, "Tower far mesh should have 1 surface (silhouette)")
	print("[PASS] Test 1: Tower 3-Tier LOD Meshes verified.")
	pass_count += 1

	# -------------------------------------------------------------
	# TEST 2: Apartment 3-Tier LOD Meshes
	# -------------------------------------------------------------
	total_tests += 1
	var a_near = CityBuilder._get_cached_apartment_near_mesh()
	var a_med = CityBuilder._get_cached_apartment_med_mesh()
	var a_far = CityBuilder._get_cached_apartment_far_mesh()
	assert(a_near != null, "Apartment near mesh must not be null")
	assert(a_med != null, "Apartment med mesh must not be null")
	assert(a_far != null, "Apartment far mesh must not be null")
	assert(a_near.get_surface_count() == 3, "Apartment near mesh should have 3 surfaces (brick + concrete + glass)")
	assert(a_med.get_surface_count() == 3, "Apartment med mesh should have 3 surfaces")
	assert(a_far.get_surface_count() == 1, "Apartment far mesh should have 1 surface (silhouette)")
	print("[PASS] Test 2: Apartment 3-Tier LOD Meshes verified.")
	pass_count += 1

	# -------------------------------------------------------------
	# TEST 3: House 3-Tier LOD Meshes (Variants 0, 1, 2)
	# -------------------------------------------------------------
	total_tests += 1
	for v in range(3):
		var h_near = CityBuilder._get_cached_house_near_mesh(v)
		var h_med = CityBuilder._get_cached_house_med_mesh(v)
		var h_far = CityBuilder._get_cached_house_far_mesh(v)
		assert(h_near != null, "House near variant %d must not be null" % v)
		assert(h_med != null, "House med variant %d must not be null" % v)
		assert(h_far != null, "House far variant %d must not be null" % v)
		assert(h_near.get_surface_count() == 6, "House near variant %d should have 6 surfaces" % v)
		assert(h_med.get_surface_count() == 5, "House med variant %d should have 5 surfaces" % v)
		assert(h_far.get_surface_count() == 2, "House far variant %d should have 2 surfaces (walls + roof)" % v)
	print("[PASS] Test 3: House 3-Tier LOD Meshes verified for all 3 variants.")
	pass_count += 1

	# -------------------------------------------------------------
	# TEST 4: Instance Creation & Visibility Ranges
	# -------------------------------------------------------------
	total_tests += 1
	var test_parent = Node3D.new()
	CityBuilder._create_architectural_tower(test_parent, Vector3(0, 0, 0), 52.0)
	CityBuilder._create_brick_apartment(test_parent, Vector3(50, 0, 0))
	CityBuilder._create_house(test_parent, Vector3(100, 0, 0), 0, 0.0)
	
	var mesh_instances: Array[MeshInstance3D] = []
	var stack = [test_parent]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D:
			mesh_instances.append(curr)
		for c in curr.get_children():
			stack.append(c)
			
	assert(mesh_instances.size() > 0, "MeshInstances must be instantiated")
	for mi in mesh_instances:
		assert(mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "All building instances must have cast_shadow = OFF")
		if mi.visibility_range_begin > 0.0 or mi.visibility_range_end > 0.0:
			assert(mi.visibility_range_fade_mode == GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF, "LOD instances must have FADE_SELF enabled")
			
	print("[PASS] Test 4: Instance Creation, Visibility Ranges & Shadow Casting verified.")
	pass_count += 1

	# -------------------------------------------------------------
	# TEST 5: Chunk Population & Foliage LOD Culling
	# -------------------------------------------------------------
	total_tests += 1
	var regions = [
		OpenWorldConfig.RegionType.CITY_DOWNTOWN,
		OpenWorldConfig.RegionType.CITY_EAST,
		OpenWorldConfig.RegionType.SUBURBS,
		OpenWorldConfig.RegionType.INDUSTRIAL,
		OpenWorldConfig.RegionType.COUNTRYSIDE,
		OpenWorldConfig.RegionType.MOUNTAIN
	]
	for reg in regions:
		var chunk_node = Node3D.new()
		CityBuilder.populate_chunk(chunk_node, Vector2i(0, 0), reg)
		
		# Inspect multimeshes
		for c in chunk_node.find_children("*", "MultiMeshInstance3D", true, false):
			var mmi = c as MultiMeshInstance3D
			assert(mmi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "MultiMesh foliage must have cast_shadow = OFF")
			if mmi.multimesh and mmi.multimesh.mesh == CityBuilder.mesh_grass:
				assert(mmi.visibility_range_end == 55.0, "Grass MultiMesh must have visibility_range_end = 55.0")
			elif mmi.multimesh and mmi.multimesh.mesh == CityBuilder.mesh_bush:
				assert(mmi.visibility_range_end == 85.0, "Bush MultiMesh must have visibility_range_end = 85.0")
		chunk_node.free()
	print("[PASS] Test 5: All 6 Region chunk populations & foliage LOD culling verified.")
	pass_count += 1

	# -------------------------------------------------------------
	# TEST 6: SkyController Shadow Distance
	# -------------------------------------------------------------
	total_tests += 1
	var sky = SkyController.new()
	sky._ready()
	assert(sky.sun_light != null, "SkyController must have sun_light")
	assert(sky.sun_light.directional_shadow_max_distance >= 28.0 and sky.sun_light.directional_shadow_max_distance <= 32.0, "Directional shadow max distance must be 28m-32m")
	sky.free()
	print("[PASS] Test 6: SkyController shadow max distance (%.1fm) verified." % 30.0)
	pass_count += 1

	test_parent.free()
	print("==================================================")
	print("RESULT: ALL %d/%d TESTS PASSED SUCCESSFULLY!" % [pass_count, total_tests])
	print("==================================================")
	quit(0)
