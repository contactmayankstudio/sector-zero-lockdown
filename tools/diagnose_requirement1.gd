@tool
extends SceneTree

func _init():
	print("================================================================================")
	print("          REQUIREMENT 1: VISUAL CLARITY & ENVIRONMENT SHADING DIAGNOSTICS      ")
	print("================================================================================")
	
	var arena_scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not arena_scn:
		printerr("FAILED to load CityCarZombieArena.tscn")
		quit(1)
		return
		
	var arena = arena_scn.instantiate()
	root.add_child(arena)
	
	print("\n>>> 1. MOUNTAINS & CLIFFS INVESTIGATION <<<")
	var mtn_names = ["MountainRangeWest", "MountainRangeEast", "MountainBackdropNorth"]
	for mname in mtn_names:
		var node = arena.find_child(mname, true, false) as MeshInstance3D
		if not node:
			print("Mountain node NOT FOUND: ", mname)
			continue
		print("Node: ", mname, " (Class: ", node.get_class(), ")")
		print("  Transform: pos=", node.position, " rot=", node.rotation, " scale=", node.scale)
		print("  Global pos=", node.global_position)
		var mesh = node.mesh as ArrayMesh
		if mesh:
			print("  Mesh surfaces: ", mesh.get_surface_count())
			for s in range(mesh.get_surface_count()):
				var aabb = mesh.get_aabb()
				print("  AABB: ", aabb)
				var arrays = mesh.surface_get_arrays(s)
				var verts = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
				var norms = arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
				var indices = arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
				var uvs = arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
				print("  Surface ", s, ": verts=", verts.size(), " indices=", indices.size(), " normals=", norms.size())
				
				# Sample normal directions
				if norms.size() > 0:
					var up_count = 0
					var down_count = 0
					var avg_norm = Vector3.ZERO
					for n in norms:
						avg_norm += n
						if n.y > 0.0: up_count += 1
						elif n.y < 0.0: down_count += 1
					avg_norm /= norms.size()
					print("  Normals: up_y=", up_count, " down_y=", down_count, " avg_norm=", avg_norm)
				
				# Check triangle winding
				if indices.size() >= 3:
					var p0 = verts[indices[0]]
					var p1 = verts[indices[1]]
					var p2 = verts[indices[2]]
					var calc_n = (p1 - p0).cross(p2 - p0).normalized()
					print("  First tri winding normal: ", calc_n, " vs stored normal: ", norms[indices[0]] if norms.size() > 0 else "none")

		# Check materials
		var mat = node.get_surface_override_material(0)
		if not mat: mat = node.material_override
		print("  Material: ", mat.resource_name if mat else "None", " (Class: ", mat.get_class() if mat else "None", ")")
		if mat is StandardMaterial3D:
			print("    cull_mode: ", mat.cull_mode, " (0=BACK, 1=FRONT, 2=DISABLED)")
			print("    shading_mode: ", mat.shading_mode)
			print("    albedo_color: ", mat.albedo_color)
			print("    albedo_texture: ", mat.albedo_texture.resource_path if mat.albedo_texture else "None")
			print("    roughness: ", mat.roughness, " texture: ", mat.roughness_texture.resource_path if mat.roughness_texture else "None")
			print("    normal_enabled: ", mat.normal_enabled, " scale: ", mat.normal_scale, " texture: ", mat.normal_texture.resource_path if mat.normal_texture else "None")
			print("    uv1_triplanar: ", mat.uv1_triplanar, " sharpness: ", mat.uv1_triplanar_sharpness, " scale: ", mat.uv1_scale)
			print("    texture_filter: ", mat.texture_filter)

	print("\n>>> 2. ROAD, SIDEWALKS, GRASS, DIRT INVESTIGATION <<<")
	var ground_parts = [
		"RealisticTerrain/HighwayAsphalt/Mesh",
		"RealisticTerrain/CenterYellow_L",
		"RealisticTerrain/LaneWhite_L",
		"RealisticTerrain/SidewalkLeft/Mesh",
		"RealisticTerrain/DirtShoulderLeft/Mesh",
		"RealisticTerrain/GrassFieldLeft/Mesh"
	]
	for gp in ground_parts:
		var node = arena.get_node_or_null(gp) as MeshInstance3D
		if not node:
			print("Ground node NOT FOUND: ", gp)
			continue
		print("Ground Node: ", node.name, " (Path: ", gp, ")")
		var mat = node.get_surface_override_material(0)
		if not mat: mat = node.material_override
		print("  Material: ", mat.resource_name if mat else "None")
		if mat is StandardMaterial3D:
			print("    albedo_color: ", mat.albedo_color)
			print("    albedo_texture: ", mat.albedo_texture.resource_path if mat.albedo_texture else "None")
			print("    roughness: ", mat.roughness, " chan=", mat.roughness_texture_channel)
			print("    roughness_texture: ", mat.roughness_texture.resource_path if mat.roughness_texture else "None")
			print("    metallic: ", mat.metallic, " specular: ", mat.metallic_specular)
			print("    normal_enabled: ", mat.normal_enabled, " normal_scale: ", mat.normal_scale)
			print("    normal_texture: ", mat.normal_texture.resource_path if mat.normal_texture else "None")
			print("    uv1_scale: ", mat.uv1_scale, " triplanar: ", mat.uv1_triplanar)
			print("    texture_filter: ", mat.texture_filter)

	print("\n>>> 3. PINE TREE FOLIAGE INVESTIGATION <<<")
	var veg = arena.get_node_or_null("VegetationTrees")
	if veg:
		print("VegetationTrees count: ", veg.get_child_count())
		if veg.get_child_count() > 0:
			var tree0 = veg.get_child(0)
			print("Tree sample: ", tree0.name, " children: ", tree0.get_child_count())
			for c in tree0.get_children():
				if c is MeshInstance3D:
					print("  Child: ", c.name, " Mesh: ", c.mesh.get_class() if c.mesh else "None")
					var mat = c.material_override
					if not mat: mat = c.get_surface_override_material(0)
					if mat is StandardMaterial3D:
						print("    Mat: ", mat.resource_name, " albedo=", mat.albedo_color, " cull_mode=", mat.cull_mode, " roughness=", mat.roughness, " specular=", mat.metallic_specular)
						print("    transparency=", mat.transparency, " alpha_scissor_threshold=", mat.alpha_scissor_threshold)
	else:
		print("VegetationTrees NOT FOUND")

	print("\n>>> 4. ENVIRONMENT, LIGHTING & WEATHER CONTROLLER <<<")
	var we = arena.find_child("WorldEnvironment", true, false) as WorldEnvironment
	if we and we.environment:
		var env = we.environment
		print("WorldEnvironment:")
		print("  background_mode: ", env.background_mode, " (1=COLOR, 2=SKY)")
		print("  ambient_light_source: ", env.ambient_light_source, " energy: ", env.ambient_light_energy, " color: ", env.ambient_light_color)
		print("  tonemap_mode: ", env.tonemap_mode, " exposure: ", env.tonemap_exposure, " white: ", env.tonemap_white)
		print("  glow_enabled: ", env.glow_enabled, " intensity: ", env.glow_intensity, " bloom: ", env.glow_bloom)
		print("  fog_enabled: ", env.fog_enabled, " density: ", env.fog_density, " color: ", env.fog_light_color, " aerial_persp: ", env.fog_aerial_perspective)
		if env.sky and env.sky.sky_material:
			print("  Sky material: ", env.sky.sky_material.get_class())
			if env.sky.sky_material is ProceduralSkyMaterial:
				var sm = env.sky.sky_material as ProceduralSkyMaterial
				print("    sky_top: ", sm.sky_top_color, " sky_horiz: ", sm.sky_horizon_color)
				print("    ground_bottom: ", sm.ground_bottom_color, " ground_horiz: ", sm.ground_horizon_color)

	var dir_light = arena.find_child("DirectionalLight3D", true, false) as DirectionalLight3D
	if dir_light:
		print("DirectionalLight3D:")
		print("  color: ", dir_light.light_color, " energy: ", dir_light.light_energy)
		print("  shadow_enabled: ", dir_light.shadow_enabled, " mode: ", dir_light.directional_shadow_mode, " max_dist: ", dir_light.directional_shadow_max_distance)

	var wc = arena.find_child("WeatherController", true, false)
	if wc:
		print("WeatherController:")
		print("  current_preset: ", wc.current_preset)
		print("  manage_procedural_sky: ", wc.manage_procedural_sky)

	quit(0)
