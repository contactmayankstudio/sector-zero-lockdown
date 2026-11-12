@tool
extends SceneTree

# =============================================================================
# ADVANCED REALISTIC TERRAIN BUILDER — Sector Zero: Lockdown
# GTA 5 / GT5 Level Realism for Mountains & Ground
# Resolution: 128x200 grid with 4-layer fractal noise + hydraulic erosion sim
# Triplanar material support, smooth analytic normals, full physics collision
# =============================================================================

const ARENA_SAVE_PATH := "res://scenes/environments/CityCarZombieArena.tscn"

func _init():
	print("=== Advanced Terrain Builder Starting ===")
	_build_and_save()
	quit()

func _build_and_save():
	var arena_scene = load(ARENA_SAVE_PATH)
	if not arena_scene:
		push_error("Cannot load " + ARENA_SAVE_PATH)
		return
	
	var arena = arena_scene.instantiate()
	
	# 1. Clean up legacy terrain nodes inside RealisticTerrain
	var real_terrain = arena.get_node_or_null("RealisticTerrain")
	if real_terrain:
		for legacy_name in ["MountainRangeWest", "MountainRangeEast", "MountainBackdropNorth", 
							"GrassFieldLeft", "GrassFieldRight"]:
			var leg_node = real_terrain.get_node_or_null(legacy_name)
			if leg_node:
				leg_node.free()
				print("Cleaned up legacy duplicate node: RealisticTerrain/" + legacy_name)

	# 2. Clean up legacy individual tree nodes
	var old_trees = arena.get_node_or_null("VegetationTrees")
	if old_trees:
		old_trees.free()
		print("Cleaned up legacy VegetationTrees node hierarchy.")

	# 3. Clean up legacy city buildings that block mountain roads
	var old_buildings = arena.get_node_or_null("CityBuildings")
	if old_buildings:
		old_buildings.free()
		print("Cleaned up legacy CityBuildings node hierarchy.")

	# 3. Clean up existing AdvancedTerrain or Foliage nodes
	for child in arena.get_children():
		if child.name in ["Terrain", "TerrainRoot", "MountainRangeWest", "MountainRangeEast", 
						   "MountainBackdropNorth", "AdvancedTerrain", "TerrainGroup", "FoliageAndProps"]:
			child.free()

	# 4. Bake WorldEnvironment settings into scene permanently
	var world_env = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env and world_env.environment:
		var env = world_env.environment
		env.tonemap_mode = Environment.TONE_MAPPER_ACES
		env.tonemap_exposure = 1.0
		env.fog_enabled = true
		env.fog_density = 0.00010
		env.fog_light_color = Color(0.70, 0.80, 0.90, 1.0)
		env.fog_aerial_perspective = 0.0
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.60, 0.70, 0.82, 1.0)
		env.ambient_light_energy = 0.48
		env.glow_enabled = true
		env.glow_bloom = 0.02
		env.glow_intensity = 0.10
		env.glow_hdr_threshold = 1.05
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		var sky_res = load("res://resources/materials/mat_photorealistic_sky.tres")
		if sky_res:
			env.sky = sky_res

	# 5. Bake DirectionalLight3D settings into scene permanently (Natural Sun Warmth)
	var dir_light = arena.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if dir_light:
		dir_light.rotation_degrees = Vector3(-45.0, -35.0, 0.0)
		dir_light.light_color = Color(1.0, 0.97, 0.90, 1.0)
		dir_light.light_energy = 1.15
		dir_light.shadow_enabled = true
		dir_light.shadow_bias = 0.025
		dir_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
		dir_light.directional_shadow_blend_splits = true
		dir_light.directional_shadow_max_distance = 160.0

	# 6. Bake HighwayAsphalt material into scene permanently
	var road_mesh = arena.get_node_or_null("RealisticTerrain/HighwayAsphalt/Mesh") as MeshInstance3D
	if road_mesh:
		var r_mat = road_mesh.get_surface_override_material(0)
		if r_mat is StandardMaterial3D:
			r_mat.albedo_color = Color(0.28, 0.28, 0.30, 1.0)
			r_mat.normal_scale = 0.95
			r_mat.roughness = 0.44
			r_mat.metallic_specular = 0.60
			r_mat.metallic = 0.03

	# 7. Remove blocking curb & shoulder box colliders so cars and bikes can drive off the highway seamlessly
	for sb_name in ["SidewalkLeft", "SidewalkRight", "DirtShoulderLeft", "DirtShoulderRight"]:
		var sb_node = arena.get_node_or_null("RealisticTerrain/" + sb_name)
		if sb_node:
			var col = sb_node.get_node_or_null("Col")
			if col:
				col.free()

	var terrain_group = Node3D.new()
	terrain_group.name = "AdvancedTerrain"
	arena.add_child(terrain_group)
	terrain_group.owner = arena
	
	# =============================================
	# GROUND PLANE — Valley Floor (Zameen)
	# =============================================
	_build_valley_floor(terrain_group, arena)
	# Dirt paths omitted to avoid z-fighting; clean grass floor used instead
	
	# =============================================
	# WEST MOUNTAIN RANGE (Left Side)
	# =============================================
	_build_realistic_mountain(
		terrain_group, arena, "MountainWest",
		Vector3(-145.0, 0.0, -210.0),  # center
		140.0,  # width
		420.0,  # length
		45.0,   # max height
		true,   # west side (valley on east)
		42      # seed
	)
	
	# =============================================
	# EAST MOUNTAIN RANGE (Right Side)  
	# =============================================
	_build_realistic_mountain(
		terrain_group, arena, "MountainEast",
		Vector3(145.0, 0.0, -210.0),
		140.0, 420.0, 45.0,
		false,  # east side (valley on west)
		73
	)
	
	# =============================================
	# NORTH MOUNTAIN WALL (Far Backdrop)
	# =============================================
	_build_north_wall(terrain_group, arena)
	
	# =============================================
	# SOUTH MOUNTAIN WALL (Behind Player Start)
	# =============================================
	_build_south_wall(terrain_group, arena)
	
	# =============================================
	# FOLIAGE & PROPS MULTIMESH SYSTEM
	# =============================================
	_build_foliage_and_props(terrain_group, arena)
	
	# =============================================
	# LAKE & ATMOSPHERE (Water & Ambient sounds/particles)
	# =============================================
	_build_lake(terrain_group, arena)
	_build_atmosphere(terrain_group, arena)
	
	# Save the scene
	var packed = PackedScene.new()
	packed.pack(arena)
	var err = ResourceSaver.save(packed, ARENA_SAVE_PATH)
	if err == OK:
		print("✓ Advanced terrain saved to: " + ARENA_SAVE_PATH)
	else:
		push_error("Failed to save: " + str(err))
	
	arena.free()

# =============================================================================
# VALLEY FLOOR — Realistic uneven ground with grass, dirt, path variation
# =============================================================================
func _build_valley_floor(parent: Node, owner: Node):
	# High-res ground mesh for the playable valley floor
	# Uses 4 noise layers for natural undulation
	var noise_macro = FastNoiseLite.new()
	noise_macro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_macro.frequency = 0.004
	noise_macro.fractal_octaves = 3
	noise_macro.seed = 100
	
	var noise_detail = FastNoiseLite.new()
	noise_detail.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_detail.frequency = 0.025
	noise_detail.fractal_octaves = 2
	noise_detail.seed = 200
	
	var xsamp = 80
	var zsamp = 140
	var total_w = 260.0  # full valley width
	var total_l = 440.0
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var verts: Array[Vector3] = []
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var wx = (u - 0.5) * total_w
			var wz = (v - 0.5) * total_l + (-210.0)
			
			# Slight height variation for natural ground feel
			var n1 = noise_macro.get_noise_2d(wx, wz)
			var n2 = noise_detail.get_noise_2d(wx, wz)
			var h = n1 * 1.8 + n2 * 0.5  # ±2m undulation
			
			# Road and shoulder zone depressed below y = 0.0 to eliminate Z-fighting with asphalt highway
			var road_dist = absf(wx)
			if road_dist < 15.0:
				h = -0.15
			elif road_dist < 24.0:
				var t = (road_dist - 15.0) / 9.0
				h = lerpf(-0.15, h, smoothstep(0.0, 1.0, t))
			
			# Smoothly blend to 0.0 at mountain boundaries (x = ±75m) so cars drive seamlessly onto mountains
			var mtn_edge_dist = absf(wx)
			if mtn_edge_dist > 58.0:
				h *= clampf((75.0 - mtn_edge_dist) / 17.0, 0.0, 1.0)
			
			var pos = Vector3(wx, h, wz)
			verts.append(pos)
			# World-space UV mapping: 1 crisp texture tile every 12.5 meters
			st.set_uv(Vector2(wx * 0.08, wz * 0.08))
			st.add_vertex(pos)
	
	# Triangulate
	for zi in range(zsamp - 1):
		for xi in range(xsamp - 1):
			var i0 = zi * xsamp + xi
			var i1 = i0 + 1
			var i2 = (zi + 1) * xsamp + xi
			var i3 = i2 + 1
			st.add_index(i0); st.add_index(i2); st.add_index(i1)
			st.add_index(i1); st.add_index(i2); st.add_index(i3)
	
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	
	var mi = MeshInstance3D.new()
	mi.name = "ValleyFloor"
	mi.mesh = mesh
	
	# Apply grass material
	var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
	if grass_mat:
		var gm = grass_mat.duplicate()
		gm.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
		gm.roughness = 0.82
		gm.metallic_specular = 0.20
		gm.normal_scale = 1.10
		gm.uv1_scale = Vector3(1.0, 1.0, 1.0)
		mi.set_surface_override_material(0, gm)
	
	parent.add_child(mi)
	mi.owner = owner
	
	# Physics body for valley floor
	var sb = StaticBody3D.new()
	sb.name = "ValleyFloor_Physics"
	parent.add_child(sb)
	sb.owner = owner
	sb.global_position = Vector3.ZERO
	
	var cs = CollisionShape3D.new()
	var tmesh = ConcavePolygonShape3D.new()
	tmesh.set_faces(mesh.get_faces())
	cs.shape = tmesh
	sb.add_child(cs)
	cs.owner = owner

# =============================================================================
# REALISTIC MOUNTAIN — Advanced multi-layer fractal terrain
# This is the key function — replaces the old 26x42 flat procedural
# =============================================================================
func _build_realistic_mountain(parent: Node, owner: Node, seg_name: String,
	center: Vector3, width: float, length: float, max_h: float, 
	is_west: bool, seed_val: int):
	
	print("Building mountain: " + seg_name + " ...")
	
	# ---- 4 Noise Layers for Professional Terrain ----
	
	# Layer 1: Macro terrain shape (low freq, large scale)
	var n_macro = FastNoiseLite.new()
	n_macro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_macro.frequency = 0.0028
	n_macro.fractal_octaves = 5
	n_macro.fractal_lacunarity = 2.1
	n_macro.fractal_gain = 0.52
	n_macro.seed = seed_val
	
	# Layer 2: Smooth rolling mountain slopes (natural alpine curves, no jagged spikes)
	var n_ridge = FastNoiseLite.new()
	n_ridge.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_ridge.frequency = 0.0030
	n_ridge.fractal_type = FastNoiseLite.FRACTAL_FBM
	n_ridge.fractal_octaves = 3
	n_ridge.fractal_lacunarity = 2.0
	n_ridge.fractal_gain = 0.38
	n_ridge.seed = seed_val + 10
	
	# Layer 3: Detail/roughness noise (gentle surface texture)
	var n_detail = FastNoiseLite.new()
	n_detail.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_detail.frequency = 0.015
	n_detail.fractal_octaves = 2
	n_detail.seed = seed_val + 20
	
	# Layer 4: Domain-warped erosion simulation
	var n_warp = FastNoiseLite.new()
	n_warp.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_warp.frequency = 0.006
	n_warp.fractal_octaves = 2
	n_warp.seed = seed_val + 30
	
	# ---- Grid Resolution ----
	# 128 x 200 = 25,600 vertices — professional quality
	var xsamp = 128
	var zsamp = 200
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Store computed heights for normal calculation
	var heights: Array[float] = []
	heights.resize(xsamp * zsamp)
	
	# ---- First pass: compute all heights ----
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var wx = (u - 0.5) * width + center.x
			var wz = (v - 0.5) * length + center.z
			
			# Domain warp — bends the sampling coordinates for natural valley flow
			var warp_x = n_warp.get_noise_2d(wx * 0.8, wz * 0.8) * 12.0
			var warp_z = n_warp.get_noise_2d(wx * 0.8 + 5.0, wz * 0.8 + 5.0) * 12.0
			var swx = wx + warp_x
			var swz = wz + warp_z
			
			# Macro base
			var h_macro = (n_macro.get_noise_2d(swx, swz) + 0.4) * 1.1
			h_macro = clampf(h_macro, 0.0, 1.0)
			
			# Smooth rolling ridges
			var h_ridge_val = (n_ridge.get_noise_2d(swx, swz) + 0.5) * 0.9
			h_ridge_val = clampf(h_ridge_val, 0.0, 1.0)
			
			# Detail bumps
			var h_det = n_detail.get_noise_2d(swx, swz) * 0.06
			
			# Combine: macro dominates base shape, smooth ridges add depth
			var h_combined = (h_macro * 0.65 + h_ridge_val * 0.35) + h_det
			
			# ---- Valley-side gradient (ramp toward playable area) ----
			# West mountain: valley is on east side (high u = valley)
			# East mountain: valley is on west side (low u = valley)
			var valley_factor: float
			if is_west:
				valley_factor = 1.0 - u   # near valley = 0.0, outer peak = 1.0
			else:
				valley_factor = u          # near valley = 0.0, outer peak = 1.0
			
			var clamped_vf = clampf(valley_factor, 0.0, 1.0)
			
			# Smooth, drivable mountain slope
			# At clamped_vf == 0.0 (valley edge), height is exactly 0.0, perfectly flush with valley floor!
			var ramp = pow(clamped_vf, 1.45)
			# Ensure border is completely smooth with smoothstep at transition (0.0 to 0.08)
			var edge_blend = smoothstep(0.0, 0.08, clamped_vf)
			var final_h = ramp * h_combined * max_h * edge_blend
			
			# Natural drivable mountain passes and switchback paths
			# Allows car and bike to easily drive up the mountain
			var trail_wave = sin(wz * 0.045 + clamped_vf * 3.5)
			if absf(trail_wave) < 0.45 and clamped_vf < 0.85:
				final_h *= 0.50
			
			final_h = maxf(0.0, final_h)
			
			heights[zi * xsamp + xi] = final_h
	
	# ---- Second pass: emit vertices with analytic normals ----
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var lx = (u - 0.5) * width
			var lz = (v - 0.5) * length
			var h = heights[zi * xsamp + xi]
			var pos = Vector3(lx + center.x, h + center.y, lz + center.z)
			
			# Analytic normal from neighboring heights (smoother than generate_normals)
			var n_normal = _calc_normal(heights, xi, zi, xsamp, zsamp, width / float(xsamp - 1), length / float(zsamp - 1))
			
			# UV: triplanar-ready (use world-space xy and xz for cliff faces)
			var uv = Vector2(pos.x * 0.04, pos.z * 0.04)
			st.set_uv(uv)
			st.set_normal(n_normal)
			st.add_vertex(pos)
	
	# ---- Triangulate ----
	for zi in range(zsamp - 1):
		for xi in range(xsamp - 1):
			var i0 = zi * xsamp + xi
			var i1 = i0 + 1
			var i2 = (zi + 1) * xsamp + xi
			var i3 = i2 + 1
			# Wind CCW for front-face normals pointing up/outward
			st.add_index(i0); st.add_index(i2); st.add_index(i1)
			st.add_index(i1); st.add_index(i2); st.add_index(i3)
	
	# ---- Skirt (seal bottom edge, no holes in terrain) ----
	var skip_edge = "east" if is_west else "west"
	_add_terrain_skirt(st, heights, xsamp, zsamp, width, length, center, skip_edge)
	
	st.generate_tangents()
	var mesh = st.commit()
	
	# ---- MeshInstance ----
	var mi = MeshInstance3D.new()
	mi.name = seg_name
	mi.mesh = mesh
	
	# Apply cliff material with triplanar UV
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	if cliff_mat:
		var cm = cliff_mat.duplicate()
		# Triplanar: use UV scale for world-space texture mapping
		if "uv1_scale" in cm:
			cm.uv1_scale = Vector3(0.12, 0.12, 0.12)
		mi.set_surface_override_material(0, cm)
	
	parent.add_child(mi)
	mi.owner = owner
	
	# ---- Physics Collision (ConcavePolygon for exact terrain collision) ----
	var sb = StaticBody3D.new()
	sb.name = seg_name + "_Physics"
	sb.physics_material_override = PhysicsMaterial.new()
	sb.physics_material_override.friction = 0.92
	sb.physics_material_override.rough = true
	parent.add_child(sb)
	sb.owner = owner
	
	var cs = CollisionShape3D.new()
	var cshape = ConcavePolygonShape3D.new()
	cshape.set_faces(mesh.get_faces())
	cs.shape = cshape
	sb.add_child(cs)
	cs.owner = owner
	
	print("  ✓ " + seg_name + " — " + str(xsamp * zsamp) + " vertices, " + str((xsamp-1)*(zsamp-1)*2) + " tris")

# =============================================================================
# ANALYTIC NORMAL CALCULATION (smoother than generate_normals)
# =============================================================================
func _calc_normal(heights: Array[float], xi: int, zi: int, xsamp: int, zsamp: int, 
	dx: float, dz: float) -> Vector3:
	# Get neighboring heights with boundary clamping
	var x_prev = maxi(xi - 1, 0)
	var x_next = mini(xi + 1, xsamp - 1)
	var z_prev = maxi(zi - 1, 0)
	var z_next = mini(zi + 1, zsamp - 1)
	
	var hL = heights[zi * xsamp + x_prev]
	var hR = heights[zi * xsamp + x_next]
	var hD = heights[z_prev * xsamp + xi]
	var hU = heights[z_next * xsamp + xi]
	
	# Gradient-based normal
	var nx = (hL - hR) / (2.0 * dx)
	var nz = (hD - hU) / (2.0 * dz)
	return Vector3(nx, 1.0, nz).normalized()

# =============================================================================
# TERRAIN SKIRT — seals open mesh edges to prevent see-through
# =============================================================================
func _add_terrain_skirt(st: SurfaceTool, heights: Array[float], xsamp: int, zsamp: int,
	width: float, length: float, center: Vector3, skip_edge: String = ""):
	# Drop all border vertices straight down to y = -12
	var base_y = -12.0
	var dx = width / float(xsamp - 1)
	var dz = length / float(zsamp - 1)
	
	# Current vertex count before skirt
	var base_idx = xsamp * zsamp
	
	# Emit bottom vertices for all 4 edges
	# North edge (zi=0)
	for xi in range(xsamp):
		var u = float(xi) / float(xsamp - 1)
		var wx = (u - 0.5) * width + center.x
		var wz = -length * 0.5 + center.z
		st.set_uv(Vector2(u, 0))
		st.set_normal(Vector3(0, 0, -1))
		st.add_vertex(Vector3(wx, base_y, wz))
	
	# South edge (zi=zsamp-1)
	for xi in range(xsamp):
		var u = float(xi) / float(xsamp - 1)
		var wx = (u - 0.5) * width + center.x
		var wz = length * 0.5 + center.z
		st.set_uv(Vector2(u, 1))
		st.set_normal(Vector3(0, 0, 1))
		st.add_vertex(Vector3(wx, base_y, wz))
	
	# West edge (xi=0)
	for zi in range(zsamp):
		var v = float(zi) / float(zsamp - 1)
		var wx = -width * 0.5 + center.x
		var wz = (v - 0.5) * length + center.z
		st.set_uv(Vector2(0, v))
		st.set_normal(Vector3(-1, 0, 0))
		st.add_vertex(Vector3(wx, base_y, wz))
	
	# East edge (xi=xsamp-1)
	for zi in range(zsamp):
		var v = float(zi) / float(zsamp - 1)
		var wx = width * 0.5 + center.x
		var wz = (v - 0.5) * length + center.z
		st.set_uv(Vector2(1, v))
		st.set_normal(Vector3(1, 0, 0))
		st.add_vertex(Vector3(wx, base_y, wz))
	
	var n_idx = base_idx  # north bottom starts at base_idx
	var s_idx = base_idx + xsamp
	var w_idx = base_idx + xsamp * 2
	var e_idx = base_idx + xsamp * 2 + zsamp
	
	# North skirt quads
	for xi in range(xsamp - 1):
		var top_a = 0 * xsamp + xi
		var top_b = 0 * xsamp + xi + 1
		var bot_a = n_idx + xi
		var bot_b = n_idx + xi + 1
		st.add_index(top_a); st.add_index(bot_a); st.add_index(bot_b)
		st.add_index(top_a); st.add_index(bot_b); st.add_index(top_b)
	
	# South skirt quads
	for xi in range(xsamp - 1):
		var top_a = (zsamp - 1) * xsamp + xi
		var top_b = (zsamp - 1) * xsamp + xi + 1
		var bot_a = s_idx + xi
		var bot_b = s_idx + xi + 1
		st.add_index(top_a); st.add_index(bot_b); st.add_index(bot_a)
		st.add_index(top_a); st.add_index(top_b); st.add_index(bot_b)
	
	# West skirt quads (Only if not facing valley)
	if skip_edge != "west":
		for zi in range(zsamp - 1):
			var top_a = zi * xsamp + 0
			var top_b = (zi + 1) * xsamp + 0
			var bot_a = w_idx + zi
			var bot_b = w_idx + zi + 1
			st.add_index(top_a); st.add_index(bot_b); st.add_index(bot_a)
			st.add_index(top_a); st.add_index(top_b); st.add_index(bot_b)
	
	# East skirt quads (Only if not facing valley)
	if skip_edge != "east":
		for zi in range(zsamp - 1):
			var top_a = zi * xsamp + (xsamp - 1)
			var top_b = (zi + 1) * xsamp + (xsamp - 1)
			var bot_a = e_idx + zi
			var bot_b = e_idx + zi + 1
			st.add_index(top_a); st.add_index(bot_a); st.add_index(bot_b)
			st.add_index(top_a); st.add_index(bot_b); st.add_index(top_b)

# =============================================================================
# NORTH MOUNTAIN WALL — Far horizon backdrop (high + dramatic)
# =============================================================================
func _build_north_wall(parent: Node, owner: Node):
	var n1 = FastNoiseLite.new()
	n1.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n1.frequency = 0.0022
	n1.fractal_octaves = 3
	n1.fractal_type = FastNoiseLite.FRACTAL_FBM
	n1.fractal_lacunarity = 2.0
	n1.fractal_gain = 0.35
	n1.seed = 555
	
	var n2 = FastNoiseLite.new()
	n2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n2.frequency = 0.010
	n2.fractal_octaves = 2
	n2.seed = 666
	
	var xsamp = 120
	var zsamp = 40
	var total_w = 520.0
	var total_d = 80.0
	var center = Vector3(0.0, 0.0, -430.0)
	var max_h = 95.0
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var heights: Array[float] = []
	heights.resize(xsamp * zsamp)
	
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var wx = (u - 0.5) * total_w + center.x
			var wz = (v - 0.5) * total_d + center.z
			
			var h1 = (n1.get_noise_2d(wx, wz) + 0.3) * 1.4
			var h2 = n2.get_noise_2d(wx, wz) * 0.1
			var h = clampf(h1 + h2, 0.0, 1.0) * max_h
			
			# Front face (south side, v=1) starts lower for visibility
			var front_ramp = pow(v, 0.7)
			h *= front_ramp
			
			heights[zi * xsamp + xi] = maxf(0.0, h)
	
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var lx = (u - 0.5) * total_w + center.x
			var lz = (v - 0.5) * total_d + center.z
			var h = heights[zi * xsamp + xi]
			var n_norm = _calc_normal(heights, xi, zi, xsamp, zsamp, total_w / float(xsamp-1), total_d / float(zsamp-1))
			st.set_uv(Vector2(u * 8.0, h * 0.04))
			st.set_normal(n_norm)
			st.add_vertex(Vector3(lx, h, lz))
	
	for zi in range(zsamp - 1):
		for xi in range(xsamp - 1):
			var i0 = zi * xsamp + xi
			var i1 = i0 + 1
			var i2 = (zi + 1) * xsamp + xi
			var i3 = i2 + 1
			st.add_index(i0); st.add_index(i2); st.add_index(i1)
			st.add_index(i1); st.add_index(i2); st.add_index(i3)
	
	st.generate_tangents()
	var mesh = st.commit()
	
	var mi = MeshInstance3D.new()
	mi.name = "MountainNorthWall"
	mi.mesh = mesh
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	if cliff_mat:
		var cm = cliff_mat.duplicate()
		mi.set_surface_override_material(0, cm)
	parent.add_child(mi)
	mi.owner = owner
	
	var sb = StaticBody3D.new()
	sb.name = "MountainNorthWall_Physics"
	parent.add_child(sb)
	sb.owner = owner
	
	var cs = CollisionShape3D.new()
	var cshape = ConcavePolygonShape3D.new()
	cshape.set_faces(mesh.get_faces())
	cs.shape = cshape
	sb.add_child(cs)
	cs.owner = owner

# =============================================================================
# SOUTH MOUNTAIN WALL — Behind player start
# =============================================================================
func _build_south_wall(parent: Node, owner: Node):
	var n1 = FastNoiseLite.new()
	n1.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n1.frequency = 0.0025
	n1.fractal_octaves = 3
	n1.fractal_type = FastNoiseLite.FRACTAL_FBM
	n1.fractal_lacunarity = 2.0
	n1.fractal_gain = 0.35
	n1.seed = 777
	
	var xsamp = 100
	var zsamp = 35
	var total_w = 480.0
	var total_d = 60.0
	var center = Vector3(0.0, 0.0, 200.0)
	var max_h = 72.0
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var heights: Array[float] = []
	heights.resize(xsamp * zsamp)
	
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var wx = (u - 0.5) * total_w + center.x
			var wz = (v - 0.5) * total_d + center.z
			var h1 = (n1.get_noise_2d(wx, wz) + 0.3) * 1.3
			var h = clampf(h1, 0.0, 1.0) * max_h
			var back_ramp = pow(1.0 - v, 0.8)
			h *= back_ramp
			heights[zi * xsamp + xi] = maxf(0.0, h)
	
	for zi in range(zsamp):
		for xi in range(xsamp):
			var u = float(xi) / float(xsamp - 1)
			var v = float(zi) / float(zsamp - 1)
			var lx = (u - 0.5) * total_w + center.x
			var lz = (v - 0.5) * total_d + center.z
			var h = heights[zi * xsamp + xi]
			var n_norm = _calc_normal(heights, xi, zi, xsamp, zsamp, total_w / float(xsamp-1), total_d / float(zsamp-1))
			st.set_uv(Vector2(u * 8.0, v * 3.0))
			st.set_normal(n_norm)
			st.add_vertex(Vector3(lx, h, lz))
	
	for zi in range(zsamp - 1):
		for xi in range(xsamp - 1):
			var i0 = zi * xsamp + xi
			var i1 = i0 + 1
			var i2 = (zi + 1) * xsamp + xi
			var i3 = i2 + 1
			st.add_index(i0); st.add_index(i2); st.add_index(i1)
			st.add_index(i1); st.add_index(i2); st.add_index(i3)
	
	st.generate_tangents()
	var mesh = st.commit()
	
	var mi = MeshInstance3D.new()
	mi.name = "MountainSouthWall"
	mi.mesh = mesh
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	if cliff_mat:
		var cm = cliff_mat.duplicate()
		mi.set_surface_override_material(0, cm)
	parent.add_child(mi)
	mi.owner = owner
	
	var sb = StaticBody3D.new()
	sb.name = "MountainSouthWall_Physics"
	parent.add_child(sb)
	sb.owner = owner
	
	var cs = CollisionShape3D.new()
	var cshape = ConcavePolygonShape3D.new()
	cshape.set_faces(mesh.get_faces())
	cs.shape = cshape
	sb.add_child(cs)
	cs.owner = owner

# =============================================================================
# MULTIMESH FOLIAGE & PROPS GENERATOR (Pines, Rocks, Bushes)
# =============================================================================
func _build_foliage_and_props(parent: Node, owner: Node):
	print("Building MultiMesh Foliage & Props (Pines, Rocks, Bushes)...")
	var foliage_group = Node3D.new()
	foliage_group.name = "FoliageAndProps"
	parent.add_child(foliage_group)
	foliage_group.owner = owner

	# Shared noise samplers
	var n_vmacro = FastNoiseLite.new()
	n_vmacro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_vmacro.frequency = 0.004
	n_vmacro.seed = 100

	var n_vdet = FastNoiseLite.new()
	n_vdet.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_vdet.frequency = 0.025
	n_vdet.seed = 200

	var n_forest = FastNoiseLite.new()
	n_forest.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_forest.frequency = 0.018
	n_forest.seed = 333

	var n_mtn_west = FastNoiseLite.new()
	n_mtn_west.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_mtn_west.frequency = 0.0028
	n_mtn_west.fractal_octaves = 5
	n_mtn_west.seed = 42

	var n_mtn_east = FastNoiseLite.new()
	n_mtn_east.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_mtn_east.frequency = 0.0028
	n_mtn_east.fractal_octaves = 5
	n_mtn_east.seed = 73

	var rng = RandomNumberGenerator.new()
	rng.seed = 999

	# -------------------------------------------------------------------------
	# 1. PINE TREES MULTIMESH (~400 instances, composite 2-surface mesh)
	# -------------------------------------------------------------------------
	var tree_mesh = _create_composite_pine_mesh()
	var tree_transforms: Array[Transform3D] = []

	# Grid sampling with forest density mask
	for zi in range(120):
		var wz = -400.0 + (float(zi) / 119.0) * 440.0
		for xi in range(70):
			var u = float(xi) / 69.0
			var side = -1.0 if xi < 35 else 1.0
			var abs_x = 24.0 + (u * 105.0)
			var wx = side * abs_x

			var forest_val = n_forest.get_noise_2d(wx, wz)
			var threshold = 0.05 if abs_x > 75.0 else 0.22
			if forest_val < threshold:
				continue

			var j_wx = wx + rng.randf_range(-3.0, 3.0)
			var j_wz = wz + rng.randf_range(-3.0, 3.0)
			if absf(j_wx) <= 22.0:
				continue

			var t_data = _sample_terrain_analytic(j_wx, j_wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
			if t_data.slope_deg > 36.0:
				continue

			var t = Transform3D()
			var scale_val = rng.randf_range(6.5, 11.0)
			var rot_y = rng.randf_range(0.0, TAU)
			var basis = Basis(Vector3.UP, rot_y).scaled(Vector3.ONE * scale_val)
			t.basis = basis
			t.origin = Vector3(j_wx, t_data.height - 0.2, j_wz)
			tree_transforms.append(t)
			if tree_transforms.size() >= 3000:
				break
		if tree_transforms.size() >= 3000:
			break

	var attempts = 0
	while tree_transforms.size() < 3000 and attempts < 15000:
		attempts += 1
		var side = -1.0 if rng.randf() < 0.5 else 1.0
		var j_wx = side * rng.randf_range(23.5, 115.0)
		var j_wz = rng.randf_range(-400.0, 35.0)
		if absf(j_wx) <= 22.0:
			continue
		var t_data = _sample_terrain_analytic(j_wx, j_wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
		if t_data.slope_deg > 36.0:
			continue
		var t = Transform3D()
		var scale_val = rng.randf_range(6.5, 11.0)
		var rot_y = rng.randf_range(0.0, TAU)
		var basis = Basis(Vector3.UP, rot_y).scaled(Vector3.ONE * scale_val)
		t.basis = basis
		t.origin = Vector3(j_wx, t_data.height - 0.2, j_wz)
		tree_transforms.append(t)

	if tree_transforms.size() > 400:
		tree_transforms = tree_transforms.slice(0, 400)

	_create_multimesh_instance(
		foliage_group, owner, "MultiMesh_PineTrees",
		tree_mesh, tree_transforms, true, 450.0
	)
	print("  ✓ Created MultiMesh_PineTrees with %d instances" % tree_transforms.size())

	# -------------------------------------------------------------------------
	# 2. SCATTERED ROCKS MULTIMESH (~400 instances, cliff PBR triplanar)
	# -------------------------------------------------------------------------
	var rock_mesh = _create_procedural_rock_mesh(888)
	var rock_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	if rock_mat:
		rock_mesh.surface_set_material(0, rock_mat)
	var rock_transforms: Array[Transform3D] = []

	for zi in range(90):
		var wz = -410.0 + (float(zi) / 89.0) * 450.0
		for xi in range(50):
			var side = -1.0 if xi < 25 else 1.0
			var abs_x = 22.5 + (float(xi) / 49.0) * 120.0
			var wx = side * abs_x

			if rng.randf() > 0.28:
				continue

			var j_wx = wx + rng.randf_range(-4.0, 4.0)
			var j_wz = wz + rng.randf_range(-4.0, 4.0)
			if absf(j_wx) <= 22.0:
				continue

			var t_data = _sample_terrain_analytic(j_wx, j_wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
			if t_data.slope_deg > 48.0:
				continue

			var t = Transform3D()
			var base_scale = rng.randf_range(2.0, 5.0)
			var sx = base_scale * rng.randf_range(0.8, 1.4)
			var sy = base_scale * rng.randf_range(0.6, 1.1)
			var sz = base_scale * rng.randf_range(0.8, 1.5)
			var rot_x = rng.randf_range(-0.3, 0.3)
			var rot_y = rng.randf_range(0.0, TAU)
			var basis = Basis.from_euler(Vector3(rot_x, rot_y, 0.0)).scaled(Vector3(sx, sy, sz))
			t.basis = basis
			t.origin = Vector3(j_wx, t_data.height - (sy * 0.25), j_wz)
			rock_transforms.append(t)
			if rock_transforms.size() >= 1000:
				break
		if rock_transforms.size() >= 1000:
			break

	attempts = 0
	while rock_transforms.size() < 1000 and attempts < 15000:
		attempts += 1
		var side = -1.0 if rng.randf() < 0.5 else 1.0
		var j_wx = side * rng.randf_range(23.0, 125.0)
		var j_wz = rng.randf_range(-410.0, 35.0)
		if absf(j_wx) <= 22.0:
			continue
		var t_data = _sample_terrain_analytic(j_wx, j_wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
		if t_data.slope_deg > 48.0:
			continue
		var t = Transform3D()
		var base_scale = rng.randf_range(2.0, 5.0)
		var sx = base_scale * rng.randf_range(0.8, 1.4)
		var sy = base_scale * rng.randf_range(0.6, 1.1)
		var sz = base_scale * rng.randf_range(0.8, 1.5)
		var rot_x = rng.randf_range(-0.3, 0.3)
		var rot_y = rng.randf_range(0.0, TAU)
		var basis = Basis.from_euler(Vector3(rot_x, rot_y, 0.0)).scaled(Vector3(sx, sy, sz))
		t.basis = basis
		t.origin = Vector3(j_wx, t_data.height - (sy * 0.25), j_wz)
		rock_transforms.append(t)

	if rock_transforms.size() > 400:
		rock_transforms = rock_transforms.slice(0, 400)

	_create_multimesh_instance(
		foliage_group, owner, "MultiMesh_Rocks",
		rock_mesh, rock_transforms, true, 300.0
	)
	print("  ✓ Created MultiMesh_Rocks with %d instances" % rock_transforms.size())

	# -------------------------------------------------------------------------
	# 3. BUSHES MULTIMESH (~500 instances, grass PBR, shadows OFF)
	# -------------------------------------------------------------------------
	var bush_mesh = _load_mesh_from_scn("res://assets/nature_kit/scn/bush_detailed.scn")
	if not bush_mesh:
		bush_mesh = _create_procedural_bush_mesh(777)
	var bush_transforms: Array[Transform3D] = []

	for zi in range(110):
		var wz = -395.0 + (float(zi) / 109.0) * 430.0
		for xi in range(60):
			var side = -1.0 if xi < 30 else 1.0
			var abs_x = 23.0 + (float(xi) / 59.0) * 85.0
			var wx = side * abs_x

			if rng.randf() > 0.25:
				continue

			var j_wx = wx + rng.randf_range(-3.5, 3.5)
			var j_wz = wz + rng.randf_range(-3.5, 3.5)
			if absf(j_wx) <= 22.0:
				continue

			var t_data = _sample_terrain_analytic(j_wx, j_wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
			if t_data.slope_deg > 32.0:
				continue

			var t = Transform3D()
			var b_scale = rng.randf_range(0.7, 1.4)
			var rot_y = rng.randf_range(0.0, TAU)
			var basis = Basis(Vector3.UP, rot_y).scaled(Vector3.ONE * b_scale)
			t.basis = basis
			t.origin = Vector3(j_wx, t_data.height - 0.05, j_wz)
			bush_transforms.append(t)
			if bush_transforms.size() >= 2000:
				break
		if bush_transforms.size() >= 2000:
			break

	attempts = 0
	while bush_transforms.size() < 2000 and attempts < 15000:
		attempts += 1
		var side = -1.0 if rng.randf() < 0.5 else 1.0
		var j_wx = side * rng.randf_range(23.0, 85.0)
		var j_wz = rng.randf_range(-395.0, 30.0)
		if absf(j_wx) <= 22.0:
			continue
		var t_data = _sample_terrain_analytic(j_wx, j_wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
		if t_data.slope_deg > 32.0:
			continue
		var t = Transform3D()
		var b_scale = rng.randf_range(0.7, 1.4)
		var rot_y = rng.randf_range(0.0, TAU)
		var basis = Basis(Vector3.UP, rot_y).scaled(Vector3.ONE * b_scale)
		t.basis = basis
		t.origin = Vector3(j_wx, t_data.height - 0.05, j_wz)
		bush_transforms.append(t)

	if bush_transforms.size() > 500:
		bush_transforms = bush_transforms.slice(0, 500)

	_create_multimesh_instance(
		foliage_group, owner, "MultiMesh_Bushes",
		bush_mesh, bush_transforms, false, 220.0
	)
	print("  ✓ Created MultiMesh_Bushes with %d instances" % bush_transforms.size())

func _create_multimesh_instance(parent: Node, owner: Node, node_name: String,
	mesh: Mesh, transforms: Array[Transform3D], cast_shadows: bool, max_dist: float) -> MultiMeshInstance3D:
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	
	var buf = PackedFloat32Array()
	buf.resize(transforms.size() * 12)
	for i in range(transforms.size()):
		var t = transforms[i]
		var idx = i * 12
		buf[idx + 0] = t.basis.x.x
		buf[idx + 1] = t.basis.y.x
		buf[idx + 2] = t.basis.z.x
		buf[idx + 3] = t.origin.x

		buf[idx + 4] = t.basis.x.y
		buf[idx + 5] = t.basis.y.y
		buf[idx + 6] = t.basis.z.y
		buf[idx + 7] = t.origin.y

		buf[idx + 8] = t.basis.x.z
		buf[idx + 9] = t.basis.y.z
		buf[idx + 10] = t.basis.z.z
		buf[idx + 11] = t.origin.z
		mm.set_instance_transform(i, t)
	mm.buffer = buf
		
	var mmi = MultiMeshInstance3D.new()
	mmi.name = node_name
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.visibility_range_end = max_dist
	mmi.visibility_range_end_margin = 25.0
	mmi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	mmi.custom_aabb = AABB(Vector3(-220, -10, -440), Vector3(440, 90, 560))
	parent.add_child(mmi)
	mmi.owner = owner
	return mmi

func _sample_terrain_analytic(wx: float, wz: float, n_vmacro: FastNoiseLite, n_vdet: FastNoiseLite,
	n_mtn_west: FastNoiseLite, n_mtn_east: FastNoiseLite) -> Dictionary:
	var delta = 0.5
	var h0 = _get_terrain_h(wx, wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
	var h_dx_p = _get_terrain_h(wx + delta, wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
	var h_dx_m = _get_terrain_h(wx - delta, wz, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
	var h_dz_p = _get_terrain_h(wx, wz + delta, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
	var h_dz_m = _get_terrain_h(wx, wz - delta, n_vmacro, n_vdet, n_mtn_west, n_mtn_east)
	
	var nx = (h_dx_m - h_dx_p) / (2.0 * delta)
	var nz = (h_dz_m - h_dz_p) / (2.0 * delta)
	var normal = Vector3(nx, 1.0, nz).normalized()
	var slope = rad_to_deg(acos(clampf(normal.y, -1.0, 1.0)))
	
	return {
		"height": h0,
		"normal": normal,
		"slope_deg": slope
	}

func _get_terrain_h(wx: float, wz: float, n_vmacro: FastNoiseLite, n_vdet: FastNoiseLite,
	n_mtn_west: FastNoiseLite, n_mtn_east: FastNoiseLite) -> float:
	var abs_x = absf(wx)
	if abs_x <= 75.0:
		var n1 = n_vmacro.get_noise_2d(wx, wz)
		var n2 = n_vdet.get_noise_2d(wx, wz)
		var h = n1 * 1.8 + n2 * 0.5
		if abs_x < 28.0:
			h = 0.0
		elif abs_x < 42.0:
			var t = (abs_x - 28.0) / 14.0
			h = lerpf(0.0, h, smoothstep(0.0, 1.0, t))
		if abs_x > 58.0:
			h *= clampf((75.0 - abs_x) / 17.0, 0.0, 1.0)
		return h
	else:
		var is_west = (wx < 0.0)
		var center_x = -145.0 if is_west else 145.0
		var u = (wx - center_x) / 140.0 + 0.5
		var valley_factor = (1.0 - u) if is_west else u
		var clamped_vf = clampf(valley_factor, 0.0, 1.0)
		
		var ramp = pow(clamped_vf, 1.45)
		var edge_blend = smoothstep(0.0, 0.08, clamped_vf)
		var n_macro = n_mtn_west if is_west else n_mtn_east
		var h_macro = clampf((n_macro.get_noise_2d(wx, wz) + 0.4) * 1.2, 0.0, 1.0)
		var final_h = ramp * h_macro * 45.0 * edge_blend
		
		var trail_wave = sin(wz * 0.045 + clamped_vf * 3.5)
		if absf(trail_wave) < 0.45 and clamped_vf < 0.85:
			final_h *= 0.50
		return maxf(0.0, final_h)

func _load_mesh_from_scn(scn_path: String) -> Mesh:
	if not ResourceLoader.exists(scn_path):
		return null
	var scn = load(scn_path)
	if not scn:
		return null
	var inst = scn.instantiate()
	var found_mesh: Mesh = null
	for child in inst.get_children():
		if child is MeshInstance3D and child.mesh:
			found_mesh = child.mesh
			break
	inst.free()
	return found_mesh

func _create_composite_pine_mesh() -> Mesh:
	var real_pine = _load_mesh_from_scn("res://assets/nature_kit/scn/tree_pine_tall.scn")
	if real_pine:
		return real_pine
	var am = ArrayMesh.new()
	
	# Surface 0: Trunk
	var st_trunk = SurfaceTool.new()
	st_trunk.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs = 8
	var h_trunk = 3.6
	var r_bot = 0.35
	var r_top = 0.18
	for i in range(segs):
		var th0 = float(i) / float(segs) * TAU
		var th1 = float(i + 1) / float(segs) * TAU
		var p0 = Vector3(cos(th0) * r_bot, 0.0, sin(th0) * r_bot)
		var p1 = Vector3(cos(th1) * r_bot, 0.0, sin(th1) * r_bot)
		var p2 = Vector3(cos(th0) * r_top, h_trunk, sin(th0) * r_top)
		var p3 = Vector3(cos(th1) * r_top, h_trunk, sin(th1) * r_top)
		st_trunk.set_uv(Vector2(float(i)/segs, 0.0)); st_trunk.add_vertex(p0)
		st_trunk.set_uv(Vector2(float(i)/segs, 1.0)); st_trunk.add_vertex(p2)
		st_trunk.set_uv(Vector2(float(i+1)/segs, 0.0)); st_trunk.add_vertex(p1)
		st_trunk.set_uv(Vector2(float(i+1)/segs, 0.0)); st_trunk.add_vertex(p1)
		st_trunk.set_uv(Vector2(float(i)/segs, 1.0)); st_trunk.add_vertex(p2)
		st_trunk.set_uv(Vector2(float(i+1)/segs, 1.0)); st_trunk.add_vertex(p3)
	st_trunk.generate_normals()
	var dirt_mat = load("res://resources/materials/mat_dirt.tres")
	if dirt_mat:
		st_trunk.set_material(dirt_mat)
	st_trunk.commit(am)
	
	# Surface 1: Foliage (3 cones)
	var st_fol = SurfaceTool.new()
	st_fol.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cone_segs = 8
	var tiers = [
		{"base_y": 2.4, "h": 2.5, "r": 2.35},
		{"base_y": 3.8, "h": 2.4, "r": 1.85},
		{"base_y": 5.2, "h": 2.2, "r": 1.30}
	]
	for tier in tiers:
		var by: float = tier["base_y"]
		var ch: float = tier["h"]
		var cr: float = tier["r"]
		var apex = Vector3(0.0, by + ch, 0.0)
		for i in range(cone_segs):
			var th0 = float(i) / float(cone_segs) * TAU
			var th1 = float(i + 1) / float(cone_segs) * TAU
			var b0 = Vector3(cos(th0) * cr, by, sin(th0) * cr)
			var b1 = Vector3(cos(th1) * cr, by, sin(th1) * cr)
			st_fol.set_uv(Vector2(0.5, 1.0)); st_fol.add_vertex(apex)
			st_fol.set_uv(Vector2(0.0, 0.0)); st_fol.add_vertex(b0)
			st_fol.set_uv(Vector2(1.0, 0.0)); st_fol.add_vertex(b1)
	st_fol.generate_normals()
	var pine_mat = StandardMaterial3D.new()
	pine_mat.resource_name = "mat_pine_clean"
	pine_mat.albedo_color = Color(0.12, 0.28, 0.14, 1.0)
	pine_mat.roughness = 0.95
	pine_mat.metallic_specular = 0.0
	pine_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	pine_mat.cull_mode = BaseMaterial3D.CULL_BACK
	st_fol.set_material(pine_mat)
	st_fol.commit(am)
	
	return am

func _create_procedural_rock_mesh(seed_val: int) -> Mesh:
	var real_rock = _load_mesh_from_scn("res://assets/nature_kit/scn/rock_large.scn")
	if real_rock:
		return real_rock
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.5
	noise.seed = seed_val
	
	var rings = 5
	var segments = 7
	var radius = 1.2
	
	var verts: Array[Vector3] = []
	for r in range(rings + 1):
		var phi = PI * float(r) / float(rings)
		for s in range(segments):
			var theta = 2.0 * PI * float(s) / float(segments)
			var nx = sin(phi) * cos(theta)
			var ny = cos(phi)
			var nz = sin(phi) * sin(theta)
			
			var n_val = noise.get_noise_3d(nx * 2.0, ny * 2.0, nz * 2.0)
			var r_disp = radius * (1.0 + n_val * 0.45)
			var py = ny * r_disp
			if py < 0.0:
				py *= 0.5
			var px = nx * r_disp * 1.3
			var pz = nz * r_disp
			verts.append(Vector3(px, py, pz))
	
	for r in range(rings):
		for s in range(segments):
			var next_s = (s + 1) % segments
			var i0 = r * segments + s
			var i1 = r * segments + next_s
			var i2 = (r + 1) * segments + s
			var i3 = (r + 1) * segments + next_s
			
			var uv0 = Vector2(float(s) / segments, float(r) / rings)
			var uv1 = Vector2(float(s + 1) / segments, float(r) / rings)
			var uv2 = Vector2(float(s) / segments, float(r + 1) / rings)
			var uv3 = Vector2(float(s + 1) / segments, float(r + 1) / rings)
			
			if r == 0:
				st.set_uv(uv0); st.add_vertex(verts[i0])
				st.set_uv(uv2); st.add_vertex(verts[i2])
				st.set_uv(uv3); st.add_vertex(verts[i3])
			elif r == rings - 1:
				st.set_uv(uv0); st.add_vertex(verts[i0])
				st.set_uv(uv2); st.add_vertex(verts[i2])
				st.set_uv(uv1); st.add_vertex(verts[i1])
			else:
				st.set_uv(uv0); st.add_vertex(verts[i0])
				st.set_uv(uv2); st.add_vertex(verts[i2])
				st.set_uv(uv1); st.add_vertex(verts[i1])
				
				st.set_uv(uv1); st.add_vertex(verts[i1])
				st.set_uv(uv2); st.add_vertex(verts[i2])
				st.set_uv(uv3); st.add_vertex(verts[i3])
				
	st.generate_normals()
	st.generate_tangents()
	return st.commit()

func _create_procedural_bush_mesh(seed_val: int) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var lobes = [
		{"pos": Vector3(0.0, 0.6, 0.0), "scale": Vector3(1.2, 0.8, 1.2)},
		{"pos": Vector3(0.5, 0.45, 0.3), "scale": Vector3(0.9, 0.7, 0.9)},
		{"pos": Vector3(-0.4, 0.5, -0.2), "scale": Vector3(1.0, 0.75, 1.0)}
	]
	
	var rings = 4
	var segments = 6
	for lobe in lobes:
		var l_pos: Vector3 = lobe["pos"]
		var l_scale: Vector3 = lobe["scale"]
		var l_verts: Array[Vector3] = []
		
		for r in range(rings + 1):
			var phi = PI * float(r) / float(rings)
			for s in range(segments):
				var theta = 2.0 * PI * float(s) / float(segments)
				var px = sin(phi) * cos(theta) * l_scale.x + l_pos.x
				var py = cos(phi) * l_scale.y + l_pos.y
				var pz = sin(phi) * sin(theta) * l_scale.z + l_pos.z
				l_verts.append(Vector3(px, py, pz))
				
		for r in range(rings):
			for s in range(segments):
				var next_s = (s + 1) % segments
				var i0 = r * segments + s
				var i1 = r * segments + next_s
				var i2 = (r + 1) * segments + s
				var i3 = (r + 1) * segments + next_s
				
				st.set_uv(Vector2(float(s)/segments, float(r)/rings))
				st.add_vertex(l_verts[i0])
				st.add_vertex(l_verts[i2])
				st.add_vertex(l_verts[i1])
				
				st.add_vertex(l_verts[i1])
				st.add_vertex(l_verts[i2])
				st.add_vertex(l_verts[i3])
				
	st.generate_normals()
	st.generate_tangents()
	return st.commit()

func _build_dirt_paths(parent: Node, owner: Node):
	var noise_macro = FastNoiseLite.new()
	noise_macro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_macro.frequency = 0.004
	noise_macro.fractal_octaves = 3
	noise_macro.seed = 100
	
	var noise_detail = FastNoiseLite.new()
	noise_detail.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise_detail.frequency = 0.025
	noise_detail.fractal_octaves = 2
	noise_detail.seed = 200

	var n_mtn_west = FastNoiseLite.new()
	n_mtn_west.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_mtn_west.frequency = 0.0028
	n_mtn_west.fractal_octaves = 5
	n_mtn_west.seed = 42

	var n_mtn_east = FastNoiseLite.new()
	n_mtn_east.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n_mtn_east.frequency = 0.0028
	n_mtn_east.fractal_octaves = 5
	n_mtn_east.seed = 73
	
	var dirt_mat = load("res://resources/materials/mat_dirt_pbr.tres")
	if not dirt_mat:
		dirt_mat = load("res://resources/materials/mat_dirt.tres")
	
	# 1. Valley Floor Highway Shoulders
	var xsamp = 8
	var zsamp = 140
	var path_w = 12.0
	var total_l = 440.0
	
	for side in [-1, 1]:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for zi in range(zsamp):
			for xi in range(xsamp):
				var u = float(xi) / float(xsamp - 1)
				var v = float(zi) / float(zsamp - 1)
				var wx = (u - 0.5) * path_w + (side * 22.0)
				var wz = (v - 0.5) * total_l + (-210.0)
				
				var h = _get_terrain_h(wx, wz, noise_macro, noise_detail, n_mtn_west, n_mtn_east)
				h += 0.08 # slightly above grass to prevent z-fighting
				
				st.set_uv(Vector2(u * 2.0, wz * 0.12))
				st.add_vertex(Vector3(wx, h, wz))
		
		for zi in range(zsamp - 1):
			for xi in range(xsamp - 1):
				var i0 = zi * xsamp + xi
				var i1 = i0 + 1
				var i2 = (zi + 1) * xsamp + xi
				var i3 = i2 + 1
				st.add_index(i0); st.add_index(i2); st.add_index(i1)
				st.add_index(i1); st.add_index(i2); st.add_index(i3)
				
		st.generate_normals()
		st.generate_tangents()
		var mesh = st.commit()
		
		var mi = MeshInstance3D.new()
		mi.name = "DirtPath_" + ("East" if side == 1 else "West")
		mi.mesh = mesh
		if dirt_mat:
			mi.set_surface_override_material(0, dirt_mat)
		parent.add_child(mi)
		mi.owner = owner

	# 2. Mountain Trails (Winding dirt tracks leading up the West and East mountains)
	for side in [-1, 1]:
		var st_mtn = SurfaceTool.new()
		st_mtn.begin(Mesh.PRIMITIVE_TRIANGLES)
		var mtn_xsamp = 8
		var mtn_zsamp = 100
		var road_width = 10.0
		
		for zi in range(mtn_zsamp):
			var t_prog = float(zi) / float(mtn_zsamp - 1)
			# Road starts at highway shoulder and winds up the mountain ridge
			var center_z = -110.0 - (t_prog * 220.0)
			var center_x = side * (22.0 + pow(t_prog, 1.25) * 85.0 + sin(t_prog * PI * 3.0) * 9.0)
			
			var tangent_dir = Vector2(side * 85.0 * 1.25 * pow(maxf(0.01, t_prog), 0.25), -220.0).normalized()
			var perp_dir = Vector2(-tangent_dir.y, tangent_dir.x)
			
			for xi in range(mtn_xsamp):
				var u = float(xi) / float(mtn_xsamp - 1)
				var offset_dist = (u - 0.5) * road_width
				var wx = center_x + perp_dir.x * offset_dist
				var wz = center_z + perp_dir.y * offset_dist
				var h = _get_terrain_h(wx, wz, noise_macro, noise_detail, n_mtn_west, n_mtn_east)
				h += 0.08
				
				st_mtn.set_uv(Vector2(u * 2.0, wz * 0.12))
				st_mtn.add_vertex(Vector3(wx, h, wz))
		
		for zi in range(mtn_zsamp - 1):
			for xi in range(mtn_xsamp - 1):
				var i0 = zi * mtn_xsamp + xi
				var i1 = i0 + 1
				var i2 = (zi + 1) * mtn_xsamp + xi
				var i3 = i2 + 1
				st_mtn.add_index(i0); st_mtn.add_index(i2); st_mtn.add_index(i1)
				st_mtn.add_index(i1); st_mtn.add_index(i2); st_mtn.add_index(i3)
				
		st_mtn.generate_normals()
		st_mtn.generate_tangents()
		var mtn_mesh = st_mtn.commit()
		
		var mtn_road_mi = MeshInstance3D.new()
		mtn_road_mi.name = "MountainRoad_" + ("East" if side == 1 else "West")
		mtn_road_mi.mesh = mtn_mesh
		if dirt_mat:
			mtn_road_mi.set_surface_override_material(0, dirt_mat)
		parent.add_child(mtn_road_mi)
		mtn_road_mi.owner = owner

func _build_lake(parent: Node, owner: Node):
	var dirt_mat = load("res://resources/materials/mat_dirt_pbr.tres")
	if not dirt_mat:
		dirt_mat = load("res://resources/materials/mat_dirt.tres")
		
	# Shoreline / Lake Bank Mesh (Relocated to East Valley, away from highway)
	var shore_mi = MeshInstance3D.new()
	shore_mi.name = "JungleLake_Shore"
	var shore_plane = PlaneMesh.new()
	shore_plane.size = Vector2(60.0, 90.0)
	shore_mi.mesh = shore_plane
	shore_mi.position = Vector3(55.0, 0.35, -190.0)
	if dirt_mat:
		shore_mi.set_surface_override_material(0, dirt_mat)
	parent.add_child(shore_mi)
	shore_mi.owner = owner

	# Realistic Animated Water Plane (East Valley Scenic Alpine Lake)
	var lake_mi = MeshInstance3D.new()
	lake_mi.name = "JungleLake"
	var plane = PlaneMesh.new()
	plane.size = Vector2(50.0, 80.0)
	plane.subdivide_width = 16
	plane.subdivide_depth = 16
	lake_mi.mesh = plane
	lake_mi.position = Vector3(55.0, 0.45, -190.0)
	
	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D normalmap1;
uniform sampler2D normalmap2;
uniform vec2 wave_dir1 = vec2(1.0, 0.2);
uniform vec2 wave_dir2 = vec2(-0.3, 1.0);
uniform float time_scale = 0.04;

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
	METALLIC = 0.90;
	ROUGHNESS = 0.10;
	
	vec2 uv1 = UV * 12.0 + wave_dir1 * TIME * time_scale;
	vec2 uv2 = UV * 12.0 + wave_dir2 * TIME * time_scale;
	
	vec3 n1 = texture(normalmap1, uv1).xyz * 2.0 - 1.0;
	vec3 n2 = texture(normalmap2, uv2).xyz * 2.0 - 1.0;
	NORMAL_MAP = normalize(n1 + n2) * 0.5 + 0.5;
}
"""
	mat.shader = shader
	mat.set_shader_parameter("albedo", Color(0.06, 0.38, 0.52, 0.88))
	
	var n1 = NoiseTexture2D.new()
	var fn1 = FastNoiseLite.new()
	fn1.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fn1.seed = 100
	fn1.frequency = 0.05
	n1.noise = fn1
	n1.as_normal_map = true
	n1.bump_strength = 2.0
	
	var n2 = NoiseTexture2D.new()
	var fn2 = FastNoiseLite.new()
	fn2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fn2.seed = 200
	fn2.frequency = 0.04
	n2.noise = fn2
	n2.as_normal_map = true
	n2.bump_strength = 1.5
	
	mat.set_shader_parameter("normalmap1", n1)
	mat.set_shader_parameter("normalmap2", n2)
	
	lake_mi.set_surface_override_material(0, mat)
	parent.add_child(lake_mi)
	lake_mi.owner = owner

func _build_atmosphere(parent: Node, owner: Node):
	# 1. 3D Jungle Fireflies & Pollen Particles
	var insects = CPUParticles3D.new()
	insects.name = "JungleInsects"
	insects.amount = 180
	insects.lifetime = 5.0
	insects.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	insects.emission_box_extents = Vector3(70.0, 6.0, 160.0)
	insects.position = Vector3(0.0, 3.5, -200.0)
	
	var insect_mesh = PlaneMesh.new()
	insect_mesh.size = Vector2(0.12, 0.12)
	var insect_mat = StandardMaterial3D.new()
	insect_mat.albedo_color = Color(0.9, 0.9, 0.5, 0.9)
	insect_mat.emission_enabled = true
	insect_mat.emission = Color(0.9, 0.9, 0.5)
	insect_mat.emission_energy_multiplier = 2.5
	insect_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	insect_mesh.material = insect_mat
	
	insects.mesh = insect_mesh
	insects.direction = Vector3(0.0, 1.0, 0.0)
	insects.gravity = Vector3(0.0, 0.0, 0.0)
	insects.initial_velocity_min = 0.2
	insects.initial_velocity_max = 1.0
	insects.linear_accel_min = -0.5
	insects.linear_accel_max = 0.5
	parent.add_child(insects)
	insects.owner = owner

	# 2. Ambient Audio Player (Jungle Nature Ambience)
	var audio_stream = load("res://audio/ambience/dark/dark_ambiences/ambience-1.wav")
	if audio_stream:
		var audio = AudioStreamPlayer.new()
		audio.name = "AmbientJungleSound"
		audio.stream = audio_stream
		audio.volume_db = -12.0
		audio.autoplay = true
		parent.add_child(audio)
		audio.owner = owner
