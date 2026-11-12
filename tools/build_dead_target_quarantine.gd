@tool
extends SceneTree

const SAVE_PATH := "res://scenes/environments/DeadTargetQuarantine.tscn"

func _init():
	print("=== Building Dead Target Quarantine Defense Arena with Real PBR Textures ===")
	var root = Node3D.new()
	root.name = "DeadTargetQuarantine"
	root.set_script(load("res://scenes/environments/DeadTargetQuarantine.gd"))
	
	# 1. World Environment
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = load("res://resources/materials/env_dead_target.tres")
	root.add_child(we)
	we.owner = root
	
	# 2. Directional Light (Moody moonlight)
	var dl = DirectionalLight3D.new()
	dl.name = "DirectionalLight3D"
	dl.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
	dl.light_color = Color(0.68, 0.78, 0.92, 1.0)
	dl.light_energy = 0.55
	dl.shadow_enabled = true
	dl.shadow_bias = 0.04
	root.add_child(dl)
	dl.owner = root
	
	# 3. Navigation Region & Ground Floor
	var nav = NavigationRegion3D.new()
	nav.name = "NavigationRegion3D"
	var nav_mesh = NavigationMesh.new()
	var verts = PackedVector3Array([
		Vector3(-7.5, 0.0, -36.0),
		Vector3(-7.5, 0.0, 6.0),
		Vector3(7.5, 0.0, 6.0),
		Vector3(7.5, 0.0, -36.0)
	])
	var polys = [PackedInt32Array([0, 1, 2]), PackedInt32Array([0, 2, 3])]
	nav_mesh.vertices = verts
	nav_mesh.polygons = polys
	nav.navigation_mesh = nav_mesh
	root.add_child(nav)
	nav.owner = root
	
	var ground = StaticBody3D.new()
	ground.name = "Ground"
	nav.add_child(ground)
	ground.owner = root
	
	var ground_col = CollisionShape3D.new()
	ground_col.name = "CollisionShape3D"
	var box_flr = BoxShape3D.new()
	box_flr.size = Vector3(16.0, 0.2, 44.0)
	ground_col.shape = box_flr
	ground_col.position = Vector3(0.0, -0.1, -15.0)
	ground.add_child(ground_col)
	ground_col.owner = root
	
	# Load Real Ground Materials ("mitti" & "khash darti")
	var mud_mat = load("res://resources/materials/mat_real_mud_ground.tres")
	var grass_mat = load("res://resources/materials/mat_real_grass_earth.tres")

	# Center Ground: Real Mud & Soil ("mitti")
	var ground_mesh = MeshInstance3D.new()
	ground_mesh.name = "GroundMudCenter"
	var plane_flr = PlaneMesh.new()
	plane_flr.size = Vector2(11.0, 44.0)
	ground_mesh.mesh = plane_flr
	if mud_mat:
		ground_mesh.set_surface_override_material(0, mud_mat)
	ground_mesh.position = Vector3(0.0, 0.0, -15.0)
	ground.add_child(ground_mesh)
	ground_mesh.owner = root

	# Left Verge Ground: Real Grass & Earth ("khash darti")
	var grass_mesh_l = MeshInstance3D.new()
	grass_mesh_l.name = "GroundGrassLeft"
	var plane_grass_l = PlaneMesh.new()
	plane_grass_l.size = Vector2(2.5, 44.0)
	grass_mesh_l.mesh = plane_grass_l
	if grass_mat:
		grass_mesh_l.set_surface_override_material(0, grass_mat)
	grass_mesh_l.position = Vector3(-6.25, 0.005, -15.0)
	ground.add_child(grass_mesh_l)
	grass_mesh_l.owner = root

	# Right Verge Ground: Real Grass & Earth ("khash darti")
	var grass_mesh_r = MeshInstance3D.new()
	grass_mesh_r.name = "GroundGrassRight"
	var plane_grass_r = PlaneMesh.new()
	plane_grass_r.size = Vector2(2.5, 44.0)
	grass_mesh_r.mesh = plane_grass_r
	if grass_mat:
		grass_mesh_r.set_surface_override_material(0, grass_mat)
	grass_mesh_r.position = Vector3(6.25, 0.005, -15.0)
	ground.add_child(grass_mesh_r)
	grass_mesh_r.owner = root

	# 4. Props Node
	var props = Node3D.new()
	props.name = "Props"
	root.add_child(props)
	props.owner = root

	# Surrounding Warehouse Walls with Real High-Graphics Materials
	var broken_brick_mat = load("res://resources/materials/mat_real_broken_brick_wall.tres")
	var concrete_block_mat = load("res://resources/materials/mat_real_concrete_block_wall.tres")

	# Wall Left: Real High-Graphics Broken Brick Wall with exposed red bricks & mortar
	var wall_l = _create_wall(Vector3(1.0, 7.0, 44.0), Vector3(-7.5, 3.5, -15.0), broken_brick_mat, "WallLeft", props, root)
	# Wall Right: Real High-Graphics Weathered Concrete Block Bunker Wall
	var wall_r = _create_wall(Vector3(1.0, 7.0, 44.0), Vector3(7.5, 3.5, -15.0), concrete_block_mat, "WallRight", props, root)
	# Wall Back (Quarantine Gate behind player): Concrete Bunker Wall
	var wall_b = _create_wall(Vector3(16.0, 7.0, 1.0), Vector3(0.0, 3.5, 6.0), concrete_block_mat, "WallBack", props, root)
	# Wall Front (Distant Gate): Broken Brick Wall
	var wall_f = _create_wall(Vector3(16.0, 7.0, 1.0), Vector3(0.0, 3.5, -36.0), broken_brick_mat, "WallFront", props, root)

	# Defense Barricade in front of player (z = -2.2)
	_add_packed_prop("res://scenes/environments/props/ConcreteBarrierA.scn", Vector3(-3.2, 0.0, -2.4), Vector3(0, 0, 0), "BarrierLeft", props, root)
	_add_packed_prop("res://scenes/environments/props/ConcreteBarrierA.scn", Vector3(3.2, 0.0, -2.4), Vector3(0, 0, 0), "BarrierRight", props, root)
	_add_packed_prop("res://scenes/environments/props/ConcreteBarrierB.scn", Vector3(-1.1, 0.0, -2.0), Vector3(0, 10, 0), "BarrierCenterLeft", props, root)
	_add_packed_prop("res://scenes/environments/props/ConcreteBarrierB.scn", Vector3(1.1, 0.0, -2.0), Vector3(0, -10, 0), "BarrierCenterRight", props, root)
	
	_add_packed_prop("res://scenes/environments/props/RoadSignClosed.scn", Vector3(-4.8, 0.0, -2.2), Vector3(0, 15, 0), "RoadSignClosed", props, root)
	_add_packed_prop("res://scenes/environments/props/RoadSignWorks.scn", Vector3(4.8, 0.0, -2.2), Vector3(0, -15, 0), "RoadSignWorks", props, root)

	_add_packed_prop("res://scenes/environments/props/TrafficCone.scn", Vector3(-2.2, 0.0, -1.8), Vector3(0, 0, 0), "Cone1", props, root)
	_add_packed_prop("res://scenes/environments/props/TrafficCone.scn", Vector3(2.2, 0.0, -1.8), Vector3(0, 0, 0), "Cone2", props, root)

	# Abandoned Police Cruiser on Left with Headlights & Flashing Beacon
	_add_packed_prop("res://scenes/environments/props/PoliceCarProp.scn", Vector3(-5.2, 0.0, -0.6), Vector3(0, 24, 0), "PoliceCar", props, root)
	
	var police_lights = Node3D.new()
	police_lights.name = "PoliceLights"
	police_lights.position = Vector3(-5.2, 0.0, -0.6)
	police_lights.rotation_degrees = Vector3(0, 24, 0)
	props.add_child(police_lights)
	police_lights.owner = root

	# Forward headlights beam cutting through fog
	var headlight = SpotLight3D.new()
	headlight.name = "Headlights"
	headlight.light_color = Color(1.0, 0.95, 0.85)
	headlight.light_energy = 2.8
	headlight.spot_range = 32.0
	headlight.spot_angle = 38.0
	headlight.position = Vector3(0.0, 0.8, -2.2)
	headlight.rotation_degrees = Vector3(-5.0, 180.0, 0.0)
	headlight.shadow_enabled = false
	police_lights.add_child(headlight)
	headlight.owner = root

	# Red and blue roof emergency flashers
	var flasher_red = OmniLight3D.new()
	flasher_red.name = "RedFlasher"
	flasher_red.light_color = Color(1.0, 0.1, 0.1)
	flasher_red.light_energy = 2.5
	flasher_red.omni_range = 8.0
	flasher_red.position = Vector3(-0.4, 1.45, 0.1)
	police_lights.add_child(flasher_red)
	flasher_red.owner = root

	var flasher_blue = OmniLight3D.new()
	flasher_blue.name = "BlueFlasher"
	flasher_blue.light_color = Color(0.1, 0.35, 1.0)
	flasher_blue.light_energy = 2.5
	flasher_blue.omni_range = 8.0
	flasher_blue.position = Vector3(0.4, 1.45, 0.1)
	police_lights.add_child(flasher_blue)
	flasher_blue.owner = root

	# Mid-Street Obstacle (forcing zombie funnel)
	_add_packed_prop("res://scenes/environments/props/ConcreteBarrierA.scn", Vector3(2.8, 0.0, -14.0), Vector3(0, 35, 0), "BarrierMid", props, root)

	# Streetlamps
	var lamp1 = Node3D.new()
	lamp1.name = "Streetlamp1"
	lamp1.position = Vector3(-6.5, 0.0, -11.0)
	props.add_child(lamp1)
	lamp1.owner = root
	
	var lamp_light1 = OmniLight3D.new()
	lamp_light1.name = "Light"
	lamp_light1.light_color = Color(1.0, 0.82, 0.55, 1.0) # Sodium amber
	lamp_light1.light_energy = 2.0
	lamp_light1.omni_range = 14.0
	lamp_light1.position = Vector3(0.0, 4.5, 0.0)
	lamp1.add_child(lamp_light1)
	lamp_light1.owner = root

	var lamp2 = Node3D.new()
	lamp2.name = "Streetlamp2"
	lamp2.position = Vector3(6.5, 0.0, -22.0)
	props.add_child(lamp2)
	lamp2.owner = root

	var lamp_light2 = OmniLight3D.new()
	lamp_light2.name = "Light"
	lamp_light2.light_color = Color(0.70, 0.85, 1.0, 1.0) # Cold mercury vapor
	lamp_light2.light_energy = 1.8
	lamp_light2.omni_range = 15.0
	lamp_light2.position = Vector3(0.0, 4.5, 0.0)
	lamp2.add_child(lamp_light2)
	lamp_light2.owner = root

	# 4 Red Explosive Barrels placed down the killzone
	_add_packed_prop("res://scenes/objects/ExplosiveBarrel.tscn", Vector3(-2.8, 0.0, -8.5), Vector3.ZERO, "ExplosiveBarrel1", root, root)
	_add_packed_prop("res://scenes/objects/ExplosiveBarrel.tscn", Vector3(3.4, 0.0, -13.0), Vector3.ZERO, "ExplosiveBarrel2", root, root)
	_add_packed_prop("res://scenes/objects/ExplosiveBarrel.tscn", Vector3(-1.8, 0.0, -19.0), Vector3.ZERO, "ExplosiveBarrel3", root, root)
	_add_packed_prop("res://scenes/objects/ExplosiveBarrel.tscn", Vector3(2.5, 0.0, -26.0), Vector3.ZERO, "ExplosiveBarrel4", root, root)

	# 5. Atmosphere Enhancer
	_add_packed_prop("res://scenes/environments/AtmosphereEnhancer.tscn", Vector3(0, 0, -10), Vector3.ZERO, "AtmosphereEnhancer", root, root)

	# 6. Player Stance
	var player_scn = load("res://scenes/player/Player.tscn")
	var player = player_scn.instantiate()
	player.name = "Player"
	player.position = Vector3(0.0, 0.1, 0.0)
	root.add_child(player)
	player.owner = root

	# 7. Zombie Spawner (GameManager.gd)
	var spawner = Node3D.new()
	spawner.name = "ZombieSpawner"
	spawner.set_script(load("res://scripts/GameManager.gd"))
	spawner.set("zombie_scene", load("res://scenes/zombies/Zombie.tscn"))
	spawner.set("wave_delay", 4.5)
	root.add_child(spawner)
	spawner.owner = root
	
	var spawn_pts: Array[Node3D] = []
	var spawn_coords = [
		{"name": "SpawnFrontCenter", "pos": Vector3(0.0, 0.1, -9.0)},
		{"name": "SpawnFrontLeft", "pos": Vector3(-2.2, 0.1, -9.5)},
		{"name": "SpawnFrontRight", "pos": Vector3(2.2, 0.1, -9.5)},
		{"name": "SpawnMidLeft", "pos": Vector3(-3.5, 0.1, -16.0)},
		{"name": "SpawnMidRight", "pos": Vector3(3.5, 0.1, -16.0)},
		{"name": "SpawnFarCenter", "pos": Vector3(0.0, 0.1, -26.0)},
		{"name": "SpawnFarLeft", "pos": Vector3(-4.0, 0.1, -25.0)},
		{"name": "SpawnFarRight", "pos": Vector3(4.0, 0.1, -25.0)},
	]
	for sc in spawn_coords:
		var sp = Node3D.new()
		sp.name = sc["name"]
		sp.position = sc["pos"]
		spawner.add_child(sp)
		sp.owner = root
		spawn_pts.append(sp)

	spawner.set("spawn_points", spawn_pts)

	# 8. Impact Pool
	var impact_pool = Node3D.new()
	impact_pool.name = "ImpactPool"
	impact_pool.add_to_group("impact_pool")
	impact_pool.set_script(load("res://scripts/ImpactPool.gd"))
	impact_pool.set("impact_scenes", {
		"blood": load("res://scenes/weapons/BloodEffect.tscn"),
		"concrete": load("res://scenes/weapons/ImpactEffect.tscn")
	})
	root.add_child(impact_pool)
	impact_pool.owner = root

	# 9. Result UI
	var result_ui_scn = load("res://scenes/UI/ResultUI.tscn")
	var result_ui = result_ui_scn.instantiate()
	result_ui.name = "ResultUI"
	root.add_child(result_ui)
	result_ui.owner = root

	# 10. Ambient Horror Audio Player
	var ambience = AudioStreamPlayer.new()
	ambience.name = "AmbiencePlayer"
	ambience.process_mode = Node.PROCESS_MODE_ALWAYS
	var audio_stream = load("res://audio/ambience/sfx_horror_drone.tres")
	if not audio_stream:
		audio_stream = load("res://audio/ambience/sfx_ambience_metro.wav")
	ambience.stream = audio_stream
	ambience.volume_db = -4.0
	ambience.autoplay = true
	root.add_child(ambience)
	ambience.owner = root

	# Save Packed Scene
	var packed = PackedScene.new()
	var pack_res = packed.pack(root)
	if pack_res == OK:
		var save_err = ResourceSaver.save(packed, SAVE_PATH)
		print("✓ Dead Target Quarantine saved successfully with real PBR materials to: ", SAVE_PATH, " [Status: ", save_err, "]")
	else:
		printerr("Failed to pack scene! Error: ", pack_res)
	
	root.free()
	quit(0)

func _create_wall(size: Vector3, pos: Vector3, mat: Material, w_name: String, parent_node: Node, scene_owner: Node) -> StaticBody3D:
	var sb = StaticBody3D.new()
	sb.name = w_name
	sb.position = pos
	parent_node.add_child(sb)
	sb.owner = scene_owner
	
	var col = CollisionShape3D.new()
	col.name = "Col"
	var box = BoxShape3D.new()
	box.size = size
	col.shape = box
	sb.add_child(col)
	col.owner = scene_owner
	
	var mi = MeshInstance3D.new()
	mi.name = "Mesh"
	var bm = BoxMesh.new()
	bm.size = size
	if mat:
		bm.material = mat
	mi.mesh = bm
	sb.add_child(mi)
	mi.owner = scene_owner
	return sb

func _add_packed_prop(scn_path: String, pos: Vector3, rot_deg: Vector3, p_name: String, parent_node: Node, scene_owner: Node) -> Node:
	if not FileAccess.file_exists(scn_path):
		print("Prop file not found: ", scn_path)
		return null
	var scn = load(scn_path)
	if not scn:
		return null
	var inst = scn.instantiate()
	inst.name = p_name
	inst.position = pos
	inst.rotation_degrees = rot_deg
	parent_node.add_child(inst)
	inst.owner = scene_owner
	return inst
