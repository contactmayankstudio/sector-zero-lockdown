@tool
extends SceneTree

func _init():
	print("=== Building Grand Theft Auto: Realistic Highway Zombie Arena ===")
	
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
		env_node.environment = env_res
	arena.add_child(env_node)
	env_node.owner = arena
	
	# -------------------------------------------------------------
	# 2. Directional Sun (Golden Sunlight with Optimized Shadows)
	# -------------------------------------------------------------
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.rotation_degrees = Vector3(-40, 140, 0)
	sun.light_color = Color(1.0, 0.97, 0.92)
	sun.light_energy = 1.20
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.directional_shadow_max_distance = 65.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	arena.add_child(sun)
	sun.owner = arena
	
	# -------------------------------------------------------------
	# 3. Ground / Terrain (NavigationRegion3D)
	#    - Center: Asphalt Highway (22m wide)
	#    - Flanks: PBR Dirt Shoulders (Mitti) (8m wide each side)
	#    - Outer: PBR Lush Grass Plains (Ghas) (30m wide each side)
	#    - Total Width: 98m, Length: 360m (Z from +80 to -280)
	# -------------------------------------------------------------
	var nav_region = NavigationRegion3D.new()
	nav_region.name = "NavigationRegion3D"
	arena.add_child(nav_region)
	nav_region.owner = arena
	
	var terrain_root = Node3D.new()
	terrain_root.name = "RealisticTerrain"
	nav_region.add_child(terrain_root)
	terrain_root.owner = arena
	
	var road_length = 360.0
	var z_center = -100.0 # From +80 to -280
	
	# (A) Central Asphalt Highway
	var asphalt_mat = load("res://resources/materials/mat_real_asphalt_pbr.tres")
	var dup_asphalt = asphalt_mat.duplicate() if asphalt_mat else null
	if dup_asphalt:
		dup_asphalt.uv1_scale = Vector3(4.0, 54.0, 1.0)
	_create_ground_segment(terrain_root, arena, "HighwayAsphalt", Vector3(0.0, 0.0, z_center), Vector2(22.0, road_length), dup_asphalt)
	
	# Road Markings: Double solid yellow center divider + white lane dividers
	var y_mat = load("res://resources/materials/mat_road_stripes.tres")
	_create_visual_strip(terrain_root, arena, "CenterYellow_L", Vector3(-0.15, 0.005, z_center), Vector2(0.12, road_length), y_mat)
	_create_visual_strip(terrain_root, arena, "CenterYellow_R", Vector3(0.15, 0.005, z_center), Vector2(0.12, road_length), y_mat)
	
	var w_mat = load("res://resources/materials/mat_road_white_stripes.tres")
	_create_visual_strip(terrain_root, arena, "LaneWhite_L", Vector3(-5.5, 0.005, z_center), Vector2(0.14, road_length), w_mat)
	_create_visual_strip(terrain_root, arena, "LaneWhite_R", Vector3(5.5, 0.005, z_center), Vector2(0.14, road_length), w_mat)

	# (B) Dirt Shoulders (Zamin Mitti)
	var dirt_mat = load("res://resources/materials/mat_dirt.tres")
	var dup_dirt_l = dirt_mat.duplicate() if dirt_mat else null
	if dup_dirt_l:
		dup_dirt_l.uv1_scale = Vector3(2.0, 54.0, 1.0)
	var dup_dirt_r = dup_dirt_l.duplicate() if dup_dirt_l else null
	
	_create_ground_segment(terrain_root, arena, "DirtShoulderLeft", Vector3(-15.0, -0.01, z_center), Vector2(8.0, road_length), dup_dirt_l)
	_create_ground_segment(terrain_root, arena, "DirtShoulderRight", Vector3(15.0, -0.01, z_center), Vector2(8.0, road_length), dup_dirt_r)
	
	# (C) Lush Grass Fields (Ghas Terrain)
	var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
	var dup_grass_l = grass_mat.duplicate() if grass_mat else null
	if dup_grass_l:
		dup_grass_l.uv1_scale = Vector3(6.0, 54.0, 1.0)
	var dup_grass_r = dup_grass_l.duplicate() if dup_grass_l else null
	
	_create_ground_segment(terrain_root, arena, "GrassFieldLeft", Vector3(-34.0, -0.02, z_center), Vector2(30.0, road_length), dup_grass_l)
	_create_ground_segment(terrain_root, arena, "GrassFieldRight", Vector3(34.0, -0.02, z_center), Vector2(30.0, road_length), dup_grass_r)
	
	# -------------------------------------------------------------
	# 4. Highway Boundary Walls
	# -------------------------------------------------------------
	var walls_node = Node3D.new()
	walls_node.name = "BoundaryWalls"
	arena.add_child(walls_node)
	walls_node.owner = arena
	
	var wall_configs = [
		{"pos": Vector3(-49.5, 4.0, z_center), "size": Vector3(1.0, 8.0, road_length)},
		{"pos": Vector3(49.5, 4.0, z_center), "size": Vector3(1.0, 8.0, road_length)},
		{"pos": Vector3(0.0, 4.0, 80.0), "size": Vector3(100.0, 8.0, 1.0)},
		{"pos": Vector3(0.0, 4.0, -280.0), "size": Vector3(100.0, 8.0, 1.0)},
	]
	for idx in range(wall_configs.size()):
		var cfg = wall_configs[idx]
		var sb = StaticBody3D.new()
		sb.name = "Wall_%d" % idx
		walls_node.add_child(sb)
		sb.owner = arena
		var col = CollisionShape3D.new()
		col.name = "Col"
		var box = BoxShape3D.new()
		box.size = cfg.size
		col.shape = box
		col.position = cfg.pos
		sb.add_child(col)
		col.owner = arena
		
	# -------------------------------------------------------------
	# 5. Street Lights along Highway
	# -------------------------------------------------------------
	var lights_node = Node3D.new()
	lights_node.name = "StreetLights"
	arena.add_child(lights_node)
	lights_node.owner = arena
	
	var light_z_coords = [60.0, 20.0, -20.0, -60.0, -100.0, -140.0, -180.0, -220.0, -260.0]
	for z_pos in light_z_coords:
		var light_l = OmniLight3D.new()
		light_l.name = "Light_L_%d" % int(z_pos)
		light_l.position = Vector3(-11.5, 6.0, z_pos)
		light_l.light_color = Color(1.0, 0.90, 0.70)
		light_l.light_energy = 1.3
		light_l.omni_range = 24.0
		lights_node.add_child(light_l)
		light_l.owner = arena
		
		var light_r = OmniLight3D.new()
		light_r.name = "Light_R_%d" % int(z_pos)
		light_r.position = Vector3(11.5, 6.0, z_pos)
		light_r.light_color = Color(1.0, 0.90, 0.70)
		light_r.light_energy = 1.3
		light_r.omni_range = 24.0
		lights_node.add_child(light_r)
		light_r.owner = arena

	# -------------------------------------------------------------
	# 6. City Skyline Buildings on Outer Grass Horizon
	# -------------------------------------------------------------
	var city_props = Node3D.new()
	city_props.name = "CityBuildings"
	arena.add_child(city_props)
	city_props.owner = arena
	
	var city_b8 = load("res://scenes/environments/models/RealCityBuildings8.scn")
	if city_b8:
		var b_left_1 = city_b8.instantiate()
		b_left_1.name = "BuildingsLeft_1"
		b_left_1.position = Vector3(-42.0, 0.0, -40.0)
		city_props.add_child(b_left_1)
		b_left_1.owner = arena
		
		var b_left_2 = city_b8.instantiate()
		b_left_2.name = "BuildingsLeft_2"
		b_left_2.position = Vector3(-42.0, 0.0, -160.0)
		city_props.add_child(b_left_2)
		b_left_2.owner = arena

		var b_right_1 = city_b8.instantiate()
		b_right_1.name = "BuildingsRight_1"
		b_right_1.position = Vector3(42.0, 0.0, -80.0)
		b_right_1.rotation_degrees = Vector3(0, 180, 0)
		city_props.add_child(b_right_1)
		b_right_1.owner = arena

		var b_right_2 = city_b8.instantiate()
		b_right_2.name = "BuildingsRight_2"
		b_right_2.position = Vector3(42.0, 0.0, -200.0)
		b_right_2.rotation_degrees = Vector3(0, 180, 0)
		city_props.add_child(b_right_2)
		b_right_2.owner = arena

	# -------------------------------------------------------------
	# 7. Props: Concrete Barriers, Cones, Barrels
	# -------------------------------------------------------------
	var props_node = Node3D.new()
	props_node.name = "HighwayProps"
	arena.add_child(props_node)
	props_node.owner = arena
	
	var barrier_res = load("res://scenes/environments/props/ConcreteBarrierA.scn")
	if barrier_res:
		var b_pos = [
			Vector3(-9.5, 0, -50.0), Vector3(9.5, 0, -50.0),
			Vector3(-10.0, 0, -120.0), Vector3(10.0, 0, -120.0),
			Vector3(-9.5, 0, -190.0), Vector3(9.5, 0, -190.0)
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
			Vector3(-7.5, 0, -75.0), Vector3(7.5, 0, -75.0),
			Vector3(-8.0, 0, -150.0), Vector3(8.0, 0, -150.0),
			Vector3(-7.0, 0, -225.0), Vector3(7.0, 0, -225.0)
		]
		for i in range(bar_pos.size()):
			var bari = barrel_res.instantiate()
			bari.name = "Barrel_%d" % i
			bari.position = bar_pos[i]
			props_node.add_child(bari)
			bari.owner = arena

	# -------------------------------------------------------------
	# 8. Drivable Realistic GTA Sedan Car
	# -------------------------------------------------------------
	var car_scene = load("res://scenes/vehicles/DrivableCar.tscn")
	var car_inst = car_scene.instantiate()
	car_inst.name = "DrivableCar"
	car_inst.position = Vector3(0.0, 0.45, 0.0)
	arena.add_child(car_inst)
	car_inst.owner = arena
	print("[ARENA] DrivableCar instantiated at (0, 0.45, 0)")

	# -------------------------------------------------------------
	# 9. Player
	# -------------------------------------------------------------
	var player_scene = load("res://scenes/player/Player.tscn")
	var player_inst = player_scene.instantiate()
	player_inst.name = "Player"
	player_inst.position = Vector3(-1.8, 0.1, 0.0)
	player_inst.rotation_degrees = Vector3(0, -90, 0)
	arena.add_child(player_inst)
	player_inst.owner = arena
	print("[ARENA] Player instantiated at (-1.8, 0.1, 0) facing car")

	# -------------------------------------------------------------
	# 10. Zombie Hordes along Highway & Terrain
	# -------------------------------------------------------------
	var zombies_node = Node3D.new()
	zombies_node.name = "Zombies"
	arena.add_child(zombies_node)
	zombies_node.owner = arena
	
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if zombie_scene:
		var horde_spawns = [
			# Near highway cluster (in front of car)
			Vector3(-3.0, 0.1, -25.0), Vector3(0.0, 0.1, -28.0), Vector3(3.0, 0.1, -26.0),
			# Dirt shoulder zombies
			Vector3(-13.0, 0.1, -35.0), Vector3(13.0, 0.1, -38.0),
			# Mid cluster 1
			Vector3(-5.0, 0.1, -60.0), Vector3(-1.5, 0.1, -64.0), Vector3(2.0, 0.1, -62.0), Vector3(5.5, 0.1, -66.0),
			# Grass field lurkers
			Vector3(-22.0, 0.1, -70.0), Vector3(22.0, 0.1, -75.0),
			# Mid cluster 2
			Vector3(-4.0, 0.1, -100.0), Vector3(0.0, 0.1, -105.0), Vector3(4.0, 0.1, -102.0), Vector3(-1.0, 0.1, -110.0),
			# Long range cluster 1
			Vector3(-6.0, 0.1, -145.0), Vector3(-2.0, 0.1, -150.0), Vector3(2.0, 0.1, -148.0), Vector3(6.0, 0.1, -152.0),
			# Long range cluster 2
			Vector3(-5.5, 0.1, -190.0), Vector3(-2.0, 0.1, -195.0), Vector3(2.0, 0.1, -192.0), Vector3(5.5, 0.1, -198.0),
			# Deep highway final horde
			Vector3(-7.0, 0.1, -240.0), Vector3(-3.5, 0.1, -244.0), Vector3(0.0, 0.1, -248.0), Vector3(3.5, 0.1, -242.0), Vector3(7.0, 0.1, -246.0),
			Vector3(-14.0, 0.1, -250.0), Vector3(14.0, 0.1, -252.0)
		]
		for i in range(horde_spawns.size()):
			var zi = zombie_scene.instantiate()
			zi.name = "Zombie_%d" % i
			zi.position = horde_spawns[i]
			zi.rotation_degrees = Vector3(0, 0, 0)
			zombies_node.add_child(zi)
			zi.owner = arena
		print("[ARENA] Spawned %d zombies along the highway and terrain!" % horde_spawns.size())

	# -------------------------------------------------------------
	# 11. ImpactPool
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
	# 12. Audio Ambience
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
	# 13. UI: Instructions & Kill Counter Overlay
	# -------------------------------------------------------------
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "InstructionsUI"
	arena.add_child(ui_layer)
	ui_layer.owner = arena
	
	var panel = PanelContainer.new()
	panel.name = "StatsPanel"
	panel.position = Vector2(30, 20)
	panel.size = Vector2(500, 115)
	ui_layer.add_child(panel)
	panel.owner = arena
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	panel.add_child(vbox)
	vbox.owner = arena
	
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "★ GTA HIGHWAY: REAL SEDAN & ZOMBIE ROADKILL ★"
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
	instr.text = "[W/A/S/D] Drive Sedan | [SPACE] Drift | [F] Enter/Exit Car | [Mouse] Shoot | [ESC] Exit"
	instr.add_theme_font_size_override("font_size", 13)
	instr.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vbox.add_child(instr)
	instr.owner = arena

	# -------------------------------------------------------------
	# 14. Save PackedScene
	# -------------------------------------------------------------
	var packed = PackedScene.new()
	var err = packed.pack(arena)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/environments/CityCarZombieArena.tscn")
		if save_err == OK:
			print("[SUCCESS] Grand Theft Auto Highway Scene Created and Saved!")
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
