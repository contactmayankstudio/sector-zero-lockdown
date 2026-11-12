@tool
extends SceneTree

func _init():
	print("--- Building CityCarZombieArena.tscn ---")
	
	var arena = Node3D.new()
	arena.name = "CityCarZombieArena"
	arena.set_script(load("res://scenes/environments/CityCarZombieArena.gd"))
	
	# 1. World Environment
	var env_node = WorldEnvironment.new()
	env_node.name = "WorldEnvironment"
	var env_res = load("res://resources/materials/env_apocalyptic_hdri.tres")
	if env_res:
		env_node.environment = env_res
	arena.add_child(env_node)
	env_node.owner = arena
	
	# 2. Sunlight (DirectionalLight3D)
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.rotation_degrees = Vector3(-45, 135, 0)
	sun.light_color = Color(1.0, 0.97, 0.92)
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	arena.add_child(sun)
	sun.owner = arena
	
	# 3. Ground Navigation & Highway
	var nav_region = NavigationRegion3D.new()
	nav_region.name = "NavigationRegion3D"
	arena.add_child(nav_region)
	nav_region.owner = arena
	
	var ground = StaticBody3D.new()
	ground.name = "HighwayGround"
	nav_region.add_child(ground)
	ground.owner = arena
	
	var ground_col = CollisionShape3D.new()
	ground_col.name = "GroundCollision"
	var ground_box = BoxShape3D.new()
	ground_box.size = Vector3(50.0, 0.4, 320.0)
	ground_col.shape = ground_box
	ground_col.position = Vector3(0.0, -0.2, -80.0)
	ground.add_child(ground_col)
	ground_col.owner = arena
	
	var ground_mesh_inst = MeshInstance3D.new()
	ground_mesh_inst.name = "HighwayMesh"
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(50.0, 320.0)
	ground_mesh_inst.mesh = plane_mesh
	ground_mesh_inst.position = Vector3(0.0, 0.0, -80.0)
	
	# PBR Asphalt Material override with sharp tiling
	var base_asphalt = load("res://resources/materials/mat_real_asphalt_pbr.tres")
	if base_asphalt:
		var road_mat = base_asphalt.duplicate()
		road_mat.uv1_scale = Vector3(8.0, 48.0, 1.0)
		ground_mesh_inst.set_surface_override_material(0, road_mat)
	ground.add_child(ground_mesh_inst)
	ground_mesh_inst.owner = arena
	
	# 4. Invisible Highway Boundary Walls (Left, Right, Front, Back)
	var walls_node = Node3D.new()
	walls_node.name = "BoundaryWalls"
	arena.add_child(walls_node)
	walls_node.owner = arena
	
	var wall_configs = [
		{"pos": Vector3(-25.5, 4.0, -80.0), "size": Vector3(1.0, 8.0, 320.0)},
		{"pos": Vector3(25.5, 4.0, -80.0), "size": Vector3(1.0, 8.0, 320.0)},
		{"pos": Vector3(0.0, 4.0, 75.0), "size": Vector3(52.0, 8.0, 1.0)},
		{"pos": Vector3(0.0, 4.0, -235.0), "size": Vector3(52.0, 8.0, 1.0)},
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
		
	# 5. Street Lights along Highway
	var lights_node = Node3D.new()
	lights_node.name = "StreetLights"
	arena.add_child(lights_node)
	lights_node.owner = arena
	
	var light_z_coords = [40.0, 0.0, -40.0, -80.0, -120.0, -160.0, -200.0]
	for z_pos in light_z_coords:
		var light_l = OmniLight3D.new()
		light_l.name = "Light_L_%d" % int(z_pos)
		light_l.position = Vector3(-12.0, 6.0, z_pos)
		light_l.light_color = Color(1.0, 0.88, 0.65)
		light_l.light_energy = 1.2
		light_l.omni_range = 22.0
		lights_node.add_child(light_l)
		light_l.owner = arena
		
		var light_r = OmniLight3D.new()
		light_r.name = "Light_R_%d" % int(z_pos)
		light_r.position = Vector3(12.0, 6.0, z_pos)
		light_r.light_color = Color(1.0, 0.88, 0.65)
		light_r.light_energy = 1.2
		light_r.omni_range = 22.0
		lights_node.add_child(light_r)
		light_r.owner = arena

	# 6. City Buildings along sides
	var city_props = Node3D.new()
	city_props.name = "CityBuildings"
	arena.add_child(city_props)
	city_props.owner = arena
	
	var city_b8 = load("res://scenes/environments/models/RealCityBuildings8.scn")
	if city_b8:
		var b_left_1 = city_b8.instantiate()
		b_left_1.name = "BuildingsLeft_1"
		b_left_1.position = Vector3(-35.0, 0.0, -30.0)
		city_props.add_child(b_left_1)
		b_left_1.owner = arena
		
		var b_left_2 = city_b8.instantiate()
		b_left_2.name = "BuildingsLeft_2"
		b_left_2.position = Vector3(-35.0, 0.0, -130.0)
		city_props.add_child(b_left_2)
		b_left_2.owner = arena

		var b_right_1 = city_b8.instantiate()
		b_right_1.name = "BuildingsRight_1"
		b_right_1.position = Vector3(35.0, 0.0, -60.0)
		b_right_1.rotation_degrees = Vector3(0, 180, 0)
		city_props.add_child(b_right_1)
		b_right_1.owner = arena

		var b_right_2 = city_b8.instantiate()
		b_right_2.name = "BuildingsRight_2"
		b_right_2.position = Vector3(35.0, 0.0, -160.0)
		b_right_2.rotation_degrees = Vector3(0, 180, 0)
		city_props.add_child(b_right_2)
		b_right_2.owner = arena

	# 7. Props: Barriers, Cones, Explosive Barrels
	var props_node = Node3D.new()
	props_node.name = "HighwayProps"
	arena.add_child(props_node)
	props_node.owner = arena
	
	var barrier_res = load("res://scenes/environments/props/ConcreteBarrierA.scn")
	if barrier_res:
		var b_pos = [
			Vector3(-6.0, 0, -50.0), Vector3(6.0, 0, -50.0),
			Vector3(-8.0, 0, -110.0), Vector3(8.0, 0, -110.0),
			Vector3(-5.0, 0, -170.0), Vector3(5.0, 0, -170.0)
		]
		for i in range(b_pos.size()):
			var bi = barrier_res.instantiate()
			bi.name = "Barrier_%d" % i
			bi.position = b_pos[i]
			props_node.add_child(bi)
			bi.owner = arena

	var cone_res = load("res://scenes/environments/props/TrafficCone.scn")
	if cone_res:
		var c_pos = [
			Vector3(-2.0, 0, -45.0), Vector3(2.0, 0, -45.0),
			Vector3(-3.0, 0, -105.0), Vector3(3.0, 0, -105.0)
		]
		for i in range(c_pos.size()):
			var ci = cone_res.instantiate()
			ci.name = "Cone_%d" % i
			ci.position = c_pos[i]
			props_node.add_child(ci)
			ci.owner = arena

	var barrel_res = load("res://scenes/objects/ExplosiveBarrel.tscn")
	if barrel_res:
		var bar_pos = [
			Vector3(-7.5, 0, -75.0), Vector3(7.5, 0, -75.0),
			Vector3(-8.0, 0, -145.0), Vector3(8.0, 0, -145.0)
		]
		for i in range(bar_pos.size()):
			var bari = barrel_res.instantiate()
			bari.name = "Barrel_%d" % i
			bari.position = bar_pos[i]
			props_node.add_child(bari)
			bari.owner = arena

	# 8. Drivable Car
	var car_scene = load("res://scenes/vehicles/DrivableCar.tscn")
	if car_scene:
		var car_inst = car_scene.instantiate()
		car_inst.name = "DrivableCar"
		car_inst.position = Vector3(0.0, 0.45, 0.0)
		arena.add_child(car_inst)
		car_inst.owner = arena
		print("[ARENA] DrivableCar instantiated at (0, 0.45, 0)")

	# 9. Player
	var player_scene = load("res://scenes/player/Player.tscn")
	if player_scene:
		var player_inst = player_scene.instantiate()
		player_inst.name = "Player"
		player_inst.position = Vector3(-1.9, 0.1, 0.0)
		player_inst.rotation_degrees = Vector3(0, 90, 0)
		arena.add_child(player_inst)
		player_inst.owner = arena
		print("[ARENA] Player instantiated at (-1.9, 0.1, 0)")

	# 10. Zombie Hordes along the Highway
	var zombies_node = Node3D.new()
	zombies_node.name = "Zombies"
	arena.add_child(zombies_node)
	zombies_node.owner = arena
	
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if zombie_scene:
		var horde_spawns = [
			# Near cluster
			Vector3(-3.0, 0.1, -25.0), Vector3(0.0, 0.1, -28.0), Vector3(3.0, 0.1, -26.0),
			# Mid cluster 1
			Vector3(-5.0, 0.1, -55.0), Vector3(-1.5, 0.1, -58.0), Vector3(2.0, 0.1, -56.0), Vector3(5.5, 0.1, -60.0),
			# Mid cluster 2
			Vector3(-4.0, 0.1, -90.0), Vector3(0.0, 0.1, -92.0), Vector3(4.0, 0.1, -88.0), Vector3(-1.0, 0.1, -96.0), Vector3(2.5, 0.1, -94.0),
			# Long range cluster 1
			Vector3(-6.0, 0.1, -130.0), Vector3(-2.0, 0.1, -135.0), Vector3(1.5, 0.1, -132.0), Vector3(5.0, 0.1, -134.0), Vector3(0.0, 0.1, -140.0),
			# Long range cluster 2
			Vector3(-5.5, 0.1, -170.0), Vector3(-2.0, 0.1, -172.0), Vector3(2.0, 0.1, -168.0), Vector3(6.0, 0.1, -174.0), Vector3(0.0, 0.1, -178.0),
			# End horde
			Vector3(-7.0, 0.1, -210.0), Vector3(-3.5, 0.1, -212.0), Vector3(0.0, 0.1, -215.0), Vector3(3.5, 0.1, -211.0), Vector3(7.0, 0.1, -214.0),
			Vector3(-2.0, 0.1, -220.0), Vector3(2.0, 0.1, -222.0)
		]
		for i in range(horde_spawns.size()):
			var zi = zombie_scene.instantiate()
			zi.name = "Zombie_%d" % i
			zi.position = horde_spawns[i]
			# Face toward the player / car (+Z)
			zi.rotation_degrees = Vector3(0, 0, 0)
			zombies_node.add_child(zi)
			zi.owner = arena
		print("[ARENA] Spawned %d zombies along the highway!" % horde_spawns.size())

	# 11. ImpactPool
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

	# 12. Audio Ambience
	var amb = AudioStreamPlayer.new()
	amb.name = "AmbiencePlayer"
	var amb_stream = load("res://audio/ambience/sfx_ambience_airport.wav")
	if amb_stream:
		amb.stream = amb_stream
	amb.volume_db = -5.0
	amb.autoplay = true
	arena.add_child(amb)
	amb.owner = arena

	# 13. UI: Instructions & Kill Counter Overlay
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "InstructionsUI"
	arena.add_child(ui_layer)
	ui_layer.owner = arena
	
	var panel = PanelContainer.new()
	panel.name = "StatsPanel"
	panel.position = Vector2(30, 20)
	panel.size = Vector2(460, 110)
	ui_layer.add_child(panel)
	panel.owner = arena
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	panel.add_child(vbox)
	vbox.owner = arena
	
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "★ GTA CITY HIGHWAY: DRIVE & SMASH ZOMBIES ★"
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
	instr.text = "[W/A/S/D] Drive | [SPACE] Drift | [F] Enter/Exit Car | [Mouse] Shoot | [ESC] Exit"
	instr.add_theme_font_size_override("font_size", 13)
	instr.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vbox.add_child(instr)
	instr.owner = arena

	# Save PackedScene
	var packed = PackedScene.new()
	var err = packed.pack(arena)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/environments/CityCarZombieArena.tscn")
		if save_err == OK:
			print("[SUCCESS] CityCarZombieArena.tscn created successfully!")
		else:
			print("[ERROR] Failed to save scene: ", save_err)
	else:
		print("[ERROR] Failed to pack scene: ", err)
		
	quit(0)
