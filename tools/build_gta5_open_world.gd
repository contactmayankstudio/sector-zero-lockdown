@tool
extends SceneTree

func _init():
	print("=== Building GTA 5 Realistic City Highway & Mountain Valley ===")
	
	var arena = Node3D.new()
	arena.name = "CityCarZombieArena"
	arena.set_script(load("res://scenes/environments/CityCarZombieArena.gd"))
	
	# -------------------------------------------------------------
	# 1. World Environment & Sky
	# -------------------------------------------------------------
	var env_node = WorldEnvironment.new()
	env_node.name = "WorldEnvironment"
	var env_res = load("res://resources/materials/env_apocalyptic_hdri.tres")
	if env_res:
		var dup_env = env_res.duplicate()
		dup_env.glow_bloom = 0.0
		env_node.environment = dup_env
	arena.add_child(env_node)
	env_node.owner = arena
	
	# -------------------------------------------------------------
	# 2. Directional Sun (Golden Sunlight with Optimized Shadows)
	# -------------------------------------------------------------
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.rotation_degrees = Vector3(-38, 145, 0)
	sun.light_color = Color(1.0, 0.97, 0.92)
	sun.light_energy = 1.20
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.directional_shadow_max_distance = 80.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	arena.add_child(sun)
	sun.owner = arena

	# -------------------------------------------------------------
	# 2b. Atmospheric Dynamic Weather Controller (GTA 5 Weather System)
	# -------------------------------------------------------------
	var weather_scene = load("res://scenes/environments/WeatherController.tscn")
	if weather_scene:
		var weather_inst = weather_scene.instantiate()
		weather_inst.name = "WeatherController"
		arena.add_child(weather_inst)
		weather_inst.owner = arena
		print("[ARENA] WeatherController instantiated successfully!")
	
	# -------------------------------------------------------------
	# 3. Ground / Terrain Root
	#    - Highway: 22m wide (X = -11 to +11)
	#    - Concrete Sidewalks/Curbs: 2.5m wide each (X = -13.5 to -11 & +11 to +13.5)
	#    - Dirt Shoulders (Mitti): 8.5m wide each (X = -22 to -13.5 & +13.5 to +22)
	#    - Lush Grass Plains (Ghas): 55m wide each (X = -77 to -22 & +22 to +77)
	#    - Mountain Ranges (Pahad): Left (X = -77 to -230), Right (X = +77 to +230)
	#    - Total Length: 520m (Z from +100 to -420, center Z = -160)
	# -------------------------------------------------------------
	var terrain_root = Node3D.new()
	terrain_root.name = "RealisticTerrain"
	arena.add_child(terrain_root)
	terrain_root.owner = arena
	
	var road_len = 520.0
	var z_cen = -160.0
	
	# (A) Central Asphalt Highway
	var asphalt_mat = load("res://resources/materials/mat_real_asphalt_pbr.tres")
	var dup_asphalt = asphalt_mat.duplicate() if asphalt_mat else null
	if dup_asphalt:
		dup_asphalt.uv1_scale = Vector3(4.0, 78.0, 1.0)
	_create_ground_segment(terrain_root, arena, "HighwayAsphalt", Vector3(0.0, 0.0, z_cen), Vector2(22.0, road_len), dup_asphalt)
	
	# Double Yellow Center Lines & White Lane Dividers
	var y_mat = load("res://resources/materials/mat_road_stripes.tres")
	var dup_y = y_mat.duplicate() if y_mat else null
	if dup_y:
		dup_y.roughness = 0.85
		dup_y.metallic_specular = 0.10
	_create_visual_strip(terrain_root, arena, "CenterYellow_L", Vector3(-0.15, 0.005, z_cen), Vector2(0.12, road_len), dup_y)
	_create_visual_strip(terrain_root, arena, "CenterYellow_R", Vector3(0.15, 0.005, z_cen), Vector2(0.12, road_len), dup_y)
	
	var w_mat = load("res://resources/materials/mat_road_white_stripes.tres")
	var dup_w = w_mat.duplicate() if w_mat else null
	if dup_w:
		dup_w.roughness = 0.85
		dup_w.metallic_specular = 0.10
	_create_visual_strip(terrain_root, arena, "LaneWhite_L", Vector3(-5.5, 0.005, z_cen), Vector2(0.14, road_len), dup_w)
	_create_visual_strip(terrain_root, arena, "LaneWhite_R", Vector3(5.5, 0.005, z_cen), Vector2(0.14, road_len), dup_w)

	# (B) Concrete Sidewalks & Curbs (GTA 5 Footpath)
	var sidewalk_mat = load("res://resources/materials/mat_city_sidewalk.tres")
	var dup_sw_l = sidewalk_mat.duplicate() if sidewalk_mat else null
	if dup_sw_l:
		dup_sw_l.uv1_scale = Vector3(2.0, 78.0, 1.0)
	var dup_sw_r = dup_sw_l.duplicate() if dup_sw_l else null
	_create_ground_segment(terrain_root, arena, "SidewalkLeft", Vector3(-12.25, 0.12, z_cen), Vector2(2.5, road_len), dup_sw_l)
	_create_ground_segment(terrain_root, arena, "SidewalkRight", Vector3(12.25, 0.12, z_cen), Vector2(2.5, road_len), dup_sw_r)

	# (C) Dirt Shoulders (Zamin Mitti)
	var dirt_mat = load("res://resources/materials/mat_dirt.tres")
	var dup_dirt_l = dirt_mat.duplicate() if dirt_mat else null
	if dup_dirt_l:
		dup_dirt_l.uv1_scale = Vector3(2.0, 78.0, 1.0)
	var dup_dirt_r = dup_dirt_l.duplicate() if dup_dirt_l else null
	_create_ground_segment(terrain_root, arena, "DirtShoulderLeft", Vector3(-17.75, 0.0, z_cen), Vector2(8.5, road_len), dup_dirt_l)
	_create_ground_segment(terrain_root, arena, "DirtShoulderRight", Vector3(17.75, 0.0, z_cen), Vector2(8.5, road_len), dup_dirt_r)

	# (D) Lush Grass Fields (Ghas / Hariyali)
	var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
	var dup_grass_l = grass_mat.duplicate() if grass_mat else null
	if dup_grass_l:
		dup_grass_l.uv1_scale = Vector3(8.0, 78.0, 1.0)
	var dup_grass_r = dup_grass_l.duplicate() if dup_grass_l else null
	_create_ground_segment(terrain_root, arena, "GrassFieldLeft", Vector3(-49.5, -0.02, z_cen), Vector2(55.0, road_len), dup_grass_l)
	_create_ground_segment(terrain_root, arena, "GrassFieldRight", Vector3(49.5, -0.02, z_cen), Vector2(55.0, road_len), dup_grass_r)

	# (E) Procedural 3D Mountains (Pahad Ranges)
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	# West Mountain Range (Left side)
	_create_procedural_mountain(terrain_root, arena, "MountainRangeWest", Vector3(-153.5, 0.0, z_cen), 153.0, road_len, 52.0, 0.007, true, cliff_mat)
	# East Mountain Range (Right side)
	_create_procedural_mountain(terrain_root, arena, "MountainRangeEast", Vector3(153.5, 0.0, z_cen), 153.0, road_len, 52.0, 0.007, false, cliff_mat)
	# North Mountain Wall (Far Horizon)
	_create_north_mountain_backdrop(terrain_root, arena, "MountainBackdropNorth", Vector3(0.0, 0.0, -420.0), 460.0, 120.0, 68.0, cliff_mat)

	# (F) Evergreen Pine Trees (Hariyali) scattered across grass & foothills
	var trees_node = Node3D.new()
	trees_node.name = "VegetationTrees"
	arena.add_child(trees_node)
	trees_node.owner = arena
	
	var tree_z_coords = [80.0, 40.0, 0.0, -40.0, -80.0, -120.0, -160.0, -200.0, -240.0, -280.0, -320.0, -360.0]
	for z_val in tree_z_coords:
		# Left side trees
		_add_pine_tree(trees_node, arena, Vector3(-25.0 - (fposmod(z_val * 3.7, 18.0)), 0.0, z_val + 5.0), 1.0 + (fposmod(z_val, 0.4)))
		_add_pine_tree(trees_node, arena, Vector3(-55.0 - (fposmod(z_val * 2.3, 15.0)), 1.5, z_val - 12.0), 1.25)
		# Right side trees
		_add_pine_tree(trees_node, arena, Vector3(25.0 + (fposmod(z_val * 4.1, 18.0)), 0.0, z_val - 8.0), 1.0 + (fposmod(z_val, 0.35)))
		_add_pine_tree(trees_node, arena, Vector3(55.0 + (fposmod(z_val * 1.9, 15.0)), 1.5, z_val + 14.0), 1.3)

	# -------------------------------------------------------------
	# 4. 3D Street Lamps along Sidewalk Curbs
	# -------------------------------------------------------------
	var lamps_node = Node3D.new()
	lamps_node.name = "StreetLamps"
	arena.add_child(lamps_node)
	lamps_node.owner = arena
	
	var lamp_obj = load("res://models/environment/industrial/street_lamp.obj")
	var lamp_z_coords = [80.0, 30.0, -20.0, -70.0, -120.0, -170.0, -220.0, -270.0, -320.0, -370.0]
	for z_pos in lamp_z_coords:
		# Left lamp
		var lamp_l = Node3D.new()
		lamp_l.name = "Lamp_L_%d" % int(z_pos)
		lamp_l.position = Vector3(-13.2, 0.12, z_pos)
		lamp_l.rotation_degrees = Vector3(0, 90, 0)
		lamps_node.add_child(lamp_l)
		lamp_l.owner = arena
		if lamp_obj:
			var mi_l = MeshInstance3D.new()
			mi_l.mesh = lamp_obj
			mi_l.scale = Vector3(0.8, 0.8, 0.8)
			lamp_l.add_child(mi_l)
			mi_l.owner = arena
		var light_l = OmniLight3D.new()
		light_l.position = Vector3(0.0, 5.5, 0.0)
		light_l.light_color = Color(1.0, 0.90, 0.72)
		light_l.light_energy = 1.4
		light_l.omni_range = 28.0
		lamp_l.add_child(light_l)
		light_l.owner = arena
		
		# Right lamp
		var lamp_r = Node3D.new()
		lamp_r.name = "Lamp_R_%d" % int(z_pos)
		lamp_r.position = Vector3(13.2, 0.12, z_pos)
		lamp_r.rotation_degrees = Vector3(0, -90, 0)
		lamps_node.add_child(lamp_r)
		lamp_r.owner = arena
		if lamp_obj:
			var mi_r = MeshInstance3D.new()
			mi_r.mesh = lamp_obj
			mi_r.scale = Vector3(0.8, 0.8, 0.8)
			lamp_r.add_child(mi_r)
			mi_r.owner = arena
		var light_r = OmniLight3D.new()
		light_r.position = Vector3(0.0, 5.5, 0.0)
		light_r.light_color = Color(1.0, 0.90, 0.72)
		light_r.light_energy = 1.4
		light_r.omni_range = 28.0
		lamp_r.add_child(light_r)
		light_r.owner = arena

	# -------------------------------------------------------------
	# 5. City Skyscrapers along Highway
	# -------------------------------------------------------------
	var city_props = Node3D.new()
	city_props.name = "CityBuildings"
	arena.add_child(city_props)
	city_props.owner = arena
	
	var city_b8 = load("res://scenes/environments/models/RealCityBuildings8.scn")
	if city_b8:
		var building_positions = [
			{"pos": Vector3(-72.0, 0.0, -30.0), "rot": 0.0},
			{"pos": Vector3(-72.0, 0.0, -150.0), "rot": 0.0},
			{"pos": Vector3(-72.0, 0.0, -270.0), "rot": 0.0},
			{"pos": Vector3(72.0, 0.0, -80.0), "rot": 180.0},
			{"pos": Vector3(72.0, 0.0, -200.0), "rot": 180.0},
			{"pos": Vector3(72.0, 0.0, -320.0), "rot": 180.0},
		]
		for i in range(building_positions.size()):
			var bp = building_positions[i]
			var bi = city_b8.instantiate()
			bi.name = "Building_%d" % i
			bi.position = bp.pos
			bi.rotation_degrees = Vector3(0, bp.rot, 0)
			city_props.add_child(bi)
			bi.owner = arena

	# -------------------------------------------------------------
	# 6. Props: Roadside Barriers, Barrels
	# -------------------------------------------------------------
	var props_node = Node3D.new()
	props_node.name = "HighwayProps"
	arena.add_child(props_node)
	props_node.owner = arena
	
	var barrier_res = load("res://scenes/environments/props/ConcreteBarrierA.scn")
	if barrier_res:
		var b_pos = [
			Vector3(-10.5, 0, -40.0), Vector3(10.5, 0, -40.0),
			Vector3(-10.5, 0, -110.0), Vector3(10.5, 0, -110.0),
			Vector3(-10.5, 0, -180.0), Vector3(10.5, 0, -180.0),
			Vector3(-10.5, 0, -260.0), Vector3(10.5, 0, -260.0)
		]
		for i in range(b_pos.size()):
			var bi = barrier_res.instantiate()
			bi.name = "Barrier_%d" % i
			bi.position = b_pos[i]
			props_node.add_child(bi)
			bi.owner = arena

	var barrel_res = load("res://scenes/objects/ExplosiveBarrel.tscn")
	if barrel_res:
		var bar_pos = [
			Vector3(-8.5, 0, -70.0), Vector3(8.5, 0, -70.0),
			Vector3(-9.0, 0, -145.0), Vector3(9.0, 0, -145.0),
			Vector3(-8.0, 0, -220.0), Vector3(8.0, 0, -220.0),
			Vector3(-8.5, 0, -300.0), Vector3(8.5, 0, -300.0)
		]
		for i in range(bar_pos.size()):
			var bari = barrel_res.instantiate()
			bari.name = "Barrel_%d" % i
			bari.position = bar_pos[i]
			props_node.add_child(bari)
			bari.owner = arena

	# -------------------------------------------------------------
	# 7. Drivable Realistic Superbike (Hayabusa 1300R - Primary Vehicle)
	# -------------------------------------------------------------
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	if bike_scene:
		var bike_inst = bike_scene.instantiate()
		bike_inst.name = "DrivableBike"
		bike_inst.position = Vector3(0.0, 0.05, 0.0)
		arena.add_child(bike_inst)
		bike_inst.owner = arena
		print("[ARENA] DrivableBike instantiated at highway center (0, 0.05, 0)")

	# -------------------------------------------------------------
	# 7b. Drivable Realistic GTA Sedan Car (Parked along left shoulder)
	# -------------------------------------------------------------
	var car_scene = load("res://scenes/vehicles/DrivableCar.tscn")
	var car_inst = car_scene.instantiate()
	car_inst.name = "DrivableCar"
	car_inst.position = Vector3(-8.5, 0.45, -25.0)
	arena.add_child(car_inst)
	car_inst.owner = arena
	print("[ARENA] DrivableCar parked along left shoulder at (-8.5, 0.45, -25)")

	# -------------------------------------------------------------
	# 8. Player (Unlimited Free Roam Unlocked!)
	# -------------------------------------------------------------
	var player_scene = load("res://scenes/player/Player.tscn")
	var player_inst = player_scene.instantiate()
	player_inst.name = "Player"
	player_inst.position = Vector3(-1.8, 0.1, 0.0)
	player_inst.rotation_degrees = Vector3(0, -90, 0)
	player_inst.set("move_limit", 0.0) # Unlimited open world free roam!
	arena.add_child(player_inst)
	player_inst.owner = arena
	print("[ARENA] Player instantiated with move_limit = 0.0 (Unlimited Free Roam)!")

	# -------------------------------------------------------------
	# 9. Zombie Hordes across Highway, Sidewalks, Grass & Mountains
	# -------------------------------------------------------------
	var zombies_node = Node3D.new()
	zombies_node.name = "Zombies"
	arena.add_child(zombies_node)
	zombies_node.owner = arena
	
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if zombie_scene:
		var horde_spawns = [
			# Highway near cluster
			Vector3(-3.0, 0.1, -25.0), Vector3(0.0, 0.1, -28.0), Vector3(3.0, 0.1, -26.0),
			# Sidewalk walkers
			Vector3(-12.0, 0.2, -35.0), Vector3(12.0, 0.2, -38.0),
			# Dirt shoulder zombies
			Vector3(-17.0, 0.1, -55.0), Vector3(17.0, 0.1, -58.0),
			# Highway mid wave 1
			Vector3(-5.0, 0.1, -85.0), Vector3(-1.5, 0.1, -88.0), Vector3(2.0, 0.1, -86.0), Vector3(5.5, 0.1, -90.0),
			# Grass field lurkers
			Vector3(-32.0, 0.1, -110.0), Vector3(32.0, 0.1, -115.0),
			# Mountain foothills zombies
			Vector3(-68.0, 3.5, -135.0), Vector3(68.0, 3.5, -140.0),
			# Highway mid wave 2
			Vector3(-4.0, 0.1, -160.0), Vector3(0.0, 0.1, -165.0), Vector3(4.0, 0.1, -162.0), Vector3(-1.0, 0.1, -170.0),
			# Long range highway wave
			Vector3(-6.0, 0.1, -220.0), Vector3(-2.0, 0.1, -225.0), Vector3(2.0, 0.1, -222.0), Vector3(6.0, 0.1, -228.0),
			# Far highway & mountain pass cluster
			Vector3(-5.5, 0.1, -290.0), Vector3(0.0, 0.1, -295.0), Vector3(5.5, 0.1, -292.0),
			# Deep final horde
			Vector3(-7.0, 0.1, -350.0), Vector3(-3.5, 0.1, -355.0), Vector3(0.0, 0.1, -358.0), Vector3(3.5, 0.1, -352.0), Vector3(7.0, 0.1, -356.0),
			Vector3(-18.0, 0.1, -360.0), Vector3(18.0, 0.1, -362.0)
		]
		for i in range(horde_spawns.size()):
			var zi = zombie_scene.instantiate()
			zi.name = "Zombie_%d" % i
			zi.position = horde_spawns[i]
			zi.rotation_degrees = Vector3(0, 0, 0)
			zombies_node.add_child(zi)
			zi.owner = arena
		print("[ARENA] Spawned %d zombies across highway, grass, and mountains!" % horde_spawns.size())

	# -------------------------------------------------------------
	# 10. ImpactPool
	# -------------------------------------------------------------
	var impact_pool = Node3D.new()
	impact_pool.name = "ImpactPool"
	impact_pool.add_to_group("impact_pool")
	impact_pool.set_script(load("res://scripts/ImpactPool.gd"))
	var b_eff = load("res://scenes/weapons/BloodEffect.tscn")
	var c_eff = load("res://scenes/weapons/ImpactEffect.tscn")
	impact_pool.set("impact_scenes", {
		"blood": b_eff,
		"concrete": c_eff
	})
	arena.add_child(impact_pool)
	impact_pool.owner = arena

	# -------------------------------------------------------------
	# 11. Audio Ambience
	# -------------------------------------------------------------
	var amb = AudioStreamPlayer.new()
	amb.name = "AmbiencePlayer"
	var amb_stream = load("res://audio/ambience/sfx_ambience_airport.wav")
	if amb_stream:
		amb.stream = amb_stream
	amb.volume_db = -5.0
	amb.autoplay = true
	arena.add_child(amb)
	amb.owner = arena

	# -------------------------------------------------------------
	# 12. UI: Instructions & Kill Counter Overlay
	# -------------------------------------------------------------
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "InstructionsUI"
	arena.add_child(ui_layer)
	ui_layer.owner = arena
	
	var panel = PanelContainer.new()
	panel.name = "StatsPanel"
	panel.position = Vector2(30, 20)
	panel.size = Vector2(520, 120)
	ui_layer.add_child(panel)
	panel.owner = arena
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	panel.add_child(vbox)
	vbox.owner = arena
	
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "★ GTA 5 OPEN VALLEY: HIGHWAY, MOUNTAINS & ROADKILL ★"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(title)
	title.owner = arena
	
	var kill_lbl = Label.new()
	kill_lbl.name = "KillCountLabel"
	kill_lbl.text = "ROADKILL SMASHES: 0"
	kill_lbl.add_theme_font_size_override("font_size", 22)
	kill_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	vbox.add_child(kill_lbl)
	kill_lbl.owner = arena

	var instr = Label.new()
	instr.name = "InstrLabel"
	instr.text = "[W/A/S/D] Drive/Walk | [SHIFT] Sprint | [SPACE] Drift | [F] Ride Bike / Car | [T] Weather | [ESC] Exit"
	instr.add_theme_font_size_override("font_size", 13)
	instr.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vbox.add_child(instr)
	instr.owner = arena

	# -------------------------------------------------------------
	# 13. Save PackedScene
	# -------------------------------------------------------------
	var packed = PackedScene.new()
	var err = packed.pack(arena)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/environments/CityCarZombieArena.tscn")
		if save_err == OK:
			print("[SUCCESS] GTA 5 Open World Highway & Mountain Valley Scene Created and Saved!")
		else:
			print("[ERROR] Failed to save scene: ", save_err)
	else:
		print("[ERROR] Failed to pack scene: ", err)
		
	quit(0)

func _create_ground_segment(parent: Node, arena_owner: Node, seg_name: String, pos: Vector3, size: Vector2, mat: Material):
	var sb = StaticBody3D.new()
	sb.name = seg_name
	parent.add_child(sb)
	sb.owner = arena_owner
	
	var col = CollisionShape3D.new()
	col.name = "Col"
	var box = BoxShape3D.new()
	box.size = Vector3(size.x, 0.4, size.y)
	col.shape = box
	col.position = pos + Vector3(0.0, -0.2, 0.0)
	sb.add_child(col)
	col.owner = arena_owner
	
	var mi = MeshInstance3D.new()
	mi.name = "Mesh"
	var plane = PlaneMesh.new()
	plane.size = size
	mi.mesh = plane
	mi.position = pos
	if mat:
		mi.set_surface_override_material(0, mat)
	sb.add_child(mi)
	mi.owner = arena_owner

func _create_visual_strip(parent: Node, arena_owner: Node, strip_name: String, pos: Vector3, size: Vector2, mat: Material):
	var mi = MeshInstance3D.new()
	mi.name = strip_name
	var plane = PlaneMesh.new()
	plane.size = size
	mi.mesh = plane
	mi.position = pos
	if mat:
		mi.set_surface_override_material(0, mat)
	parent.add_child(mi)
	mi.owner = arena_owner

func _create_procedural_mountain(parent: Node, arena_owner: Node, seg_name: String, center_pos: Vector3, width: float, length: float, height_scale: float, freq: float, is_west: bool, mat: Material):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = freq
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var x_samples = 26
	var z_samples = 42
	
	var grid_verts: Array[Vector3] = []
	for z_i in range(z_samples):
		for x_i in range(x_samples):
			var u = float(x_i) / float(x_samples - 1)
			var v = float(z_i) / float(z_samples - 1)
			var x = (u - 0.5) * width
			var z = (v - 0.5) * length
			
			# Height envelope: smooth drivable foothills near valley, rising to rugged peaks
			var dist_factor = (1.0 - u) if is_west else u
			var ramp = pow(clampf(dist_factor, 0.0, 1.0), 1.35)
			var n = noise.get_noise_2d(center_pos.x + x, center_pos.z + z)
			var h = max(0.0, (n + 0.32) * height_scale * ramp)
			var pos = Vector3(x, h, z) + center_pos
			grid_verts.append(pos)
			
			st.set_uv(Vector2(u * 14.0, v * 38.0))
			st.set_normal(Vector3.UP)
			st.add_vertex(pos)
			
	for z_i in range(z_samples - 1):
		for x_i in range(x_samples - 1):
			var i0 = z_i * x_samples + x_i
			var i1 = i0 + 1
			var i2 = (z_i + 1) * x_samples + x_i
			var i3 = i2 + 1
			
			st.add_index(i0)
			st.add_index(i1)
			st.add_index(i2)
			
			st.add_index(i1)
			st.add_index(i3)
			st.add_index(i2)

	# Boundary skirt polygons extending from perimeter vertices down to y = -5.0m to seal open mesh boundaries
	var perimeter: Array[int] = []
	var outward_dirs: Array[Vector3] = []
	
	# North edge (z_i = 0): x_i goes (x_samples - 1) down to 1
	for x_i in range(x_samples - 1, 0, -1):
		perimeter.append(0 * x_samples + x_i)
		outward_dirs.append(Vector3(0, 0, -1))
	# West edge (x_i = 0): z_i goes 0 to (z_samples - 2)
	for z_i in range(z_samples - 1):
		perimeter.append(z_i * x_samples + 0)
		outward_dirs.append(Vector3(-1, 0, 0))
	# South edge (z_i = z_samples - 1): x_i goes 0 to (x_samples - 2)
	for x_i in range(x_samples - 1):
		perimeter.append((z_samples - 1) * x_samples + x_i)
		outward_dirs.append(Vector3(0, 0, 1))
	# East edge (x_i = x_samples - 1): z_i goes (z_samples - 1) down to 1
	for z_i in range(z_samples - 1, 0, -1):
		perimeter.append(z_i * x_samples + (x_samples - 1))
		outward_dirs.append(Vector3(1, 0, 0))

	var n_p = perimeter.size()
	var bot_start_idx = x_samples * z_samples
	for k in range(n_p):
		var top_v = grid_verts[perimeter[k]]
		var out_dir = outward_dirs[k]
		st.set_uv(Vector2(0, 0))
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(top_v.x + out_dir.x * 0.5, -5.0, top_v.z + out_dir.z * 0.5))

	for k in range(n_p):
		var next_k = (k + 1) % n_p
		var top_a = perimeter[k]
		var top_b = perimeter[next_k]
		var bot_a = bot_start_idx + k
		var bot_b = bot_start_idx + next_k
		
		st.add_index(top_a)
		st.add_index(bot_b)
		st.add_index(bot_a)
		
		st.add_index(top_a)
		st.add_index(top_b)
		st.add_index(bot_b)
			
	st.generate_normals()
	var mesh = st.commit()
	
	var mi = MeshInstance3D.new()
	mi.name = seg_name
	mi.mesh = mesh
	if mat:
		mi.set_surface_override_material(0, mat)
	parent.add_child(mi)
	mi.owner = arena_owner
	
	var sb = StaticBody3D.new()
	sb.name = seg_name + "_Physics"
	mi.add_child(sb)
	sb.owner = arena_owner
	var col = CollisionShape3D.new()
	col.name = "Col"
	col.shape = mesh.create_trimesh_shape()
	sb.add_child(col)
	col.owner = arena_owner

func _create_north_mountain_backdrop(parent: Node, arena_owner: Node, seg_name: String, center_pos: Vector3, width: float, depth: float, height_scale: float, mat: Material):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.008
	noise.fractal_octaves = 4
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var x_samples = 36
	var z_samples = 18
	
	var grid_verts: Array[Vector3] = []
	for z_i in range(z_samples):
		for x_i in range(x_samples):
			var u = float(x_i) / float(x_samples - 1)
			var v = float(z_i) / float(z_samples - 1)
			var x = (u - 0.5) * width
			var z = (v - 0.5) * depth
			
			var dist_factor = v # Peaks rise toward the deep horizon
			var ramp = pow(clampf(dist_factor, 0.0, 1.0), 1.25)
			var n = noise.get_noise_2d(x, z)
			var h = max(0.0, (n + 0.35) * height_scale * ramp)
			var pos = Vector3(x, h, z) + center_pos
			grid_verts.append(pos)
			
			st.set_uv(Vector2(u * 28.0, v * 12.0))
			st.set_normal(Vector3.UP)
			st.add_vertex(pos)
			
	for z_i in range(z_samples - 1):
		for x_i in range(x_samples - 1):
			var i0 = z_i * x_samples + x_i
			var i1 = i0 + 1
			var i2 = (z_i + 1) * x_samples + x_i
			var i3 = i2 + 1
			
			st.add_index(i0)
			st.add_index(i1)
			st.add_index(i2)
			
			st.add_index(i1)
			st.add_index(i3)
			st.add_index(i2)

	# Boundary skirt polygons extending from perimeter vertices down to y = -5.0m
	var perimeter: Array[int] = []
	var outward_dirs: Array[Vector3] = []
	
	# North edge (z_i = 0): x_i goes (x_samples - 1) down to 1
	for x_i in range(x_samples - 1, 0, -1):
		perimeter.append(0 * x_samples + x_i)
		outward_dirs.append(Vector3(0, 0, -1))
	# West edge (x_i = 0): z_i goes 0 to (z_samples - 2)
	for z_i in range(z_samples - 1):
		perimeter.append(z_i * x_samples + 0)
		outward_dirs.append(Vector3(-1, 0, 0))
	# South edge (z_i = z_samples - 1): x_i goes 0 to (x_samples - 2)
	for x_i in range(x_samples - 1):
		perimeter.append((z_samples - 1) * x_samples + x_i)
		outward_dirs.append(Vector3(0, 0, 1))
	# East edge (x_i = x_samples - 1): z_i goes (z_samples - 1) down to 1
	for z_i in range(z_samples - 1, 0, -1):
		perimeter.append(z_i * x_samples + (x_samples - 1))
		outward_dirs.append(Vector3(1, 0, 0))

	var n_p = perimeter.size()
	var bot_start_idx = x_samples * z_samples
	for k in range(n_p):
		var top_v = grid_verts[perimeter[k]]
		var out_dir = outward_dirs[k]
		st.set_uv(Vector2(0, 0))
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(top_v.x + out_dir.x * 0.5, -5.0, top_v.z + out_dir.z * 0.5))

	for k in range(n_p):
		var next_k = (k + 1) % n_p
		var top_a = perimeter[k]
		var top_b = perimeter[next_k]
		var bot_a = bot_start_idx + k
		var bot_b = bot_start_idx + next_k
		
		st.add_index(top_a)
		st.add_index(bot_b)
		st.add_index(bot_a)
		
		st.add_index(top_a)
		st.add_index(top_b)
		st.add_index(bot_b)
			
	st.generate_normals()
	var mesh = st.commit()
	
	var mi = MeshInstance3D.new()
	mi.name = seg_name
	mi.mesh = mesh
	if mat:
		mi.set_surface_override_material(0, mat)
	parent.add_child(mi)
	mi.owner = arena_owner

func _add_pine_tree(parent: Node, arena_owner: Node, pos: Vector3, scale_mult: float):
	var tree = Node3D.new()
	tree.name = "PineTree_%d_%d" % [int(pos.x), int(pos.z)]
	tree.position = pos
	tree.scale = Vector3(scale_mult, scale_mult, scale_mult)
	parent.add_child(tree)
	tree.owner = arena_owner
	
	# Brown trunk
	var trunk = MeshInstance3D.new()
	trunk.name = "Trunk"
	var t_mesh = CylinderMesh.new()
	t_mesh.top_radius = 0.20
	t_mesh.bottom_radius = 0.35
	t_mesh.height = 3.2
	trunk.mesh = t_mesh
	trunk.position = Vector3(0, 1.6, 0)
	var dirt_mat = load("res://resources/materials/mat_dirt.tres")
	if dirt_mat:
		trunk.material_override = dirt_mat
	tree.add_child(trunk)
	trunk.owner = arena_owner
	
	# Green pine foliage (clean shading, no white rim glare)
	var pine_mat = StandardMaterial3D.new()
	pine_mat.resource_name = "mat_pine_clean"
	pine_mat.albedo_color = Color(0.12, 0.28, 0.14, 1.0)
	pine_mat.roughness = 1.0
	pine_mat.metallic_specular = 0.0
	pine_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	pine_mat.cull_mode = BaseMaterial3D.CULL_BACK
	for i in range(3):
		var fol = MeshInstance3D.new()
		fol.name = "Foliage_%d" % i
		var c_mesh = CylinderMesh.new()
		c_mesh.top_radius = 0.05
		c_mesh.bottom_radius = 2.3 - (i * 0.45)
		c_mesh.height = 2.4
		c_mesh.cap_bottom = false
		fol.mesh = c_mesh
		fol.position = Vector3(0, 2.8 + (i * 1.4), 0)
		fol.material_override = pine_mat
		tree.add_child(fol)
		fol.owner = arena_owner
