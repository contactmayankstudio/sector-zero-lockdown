@tool
extends SceneTree

const SAVE_PATH := "res://scenes/environments/ZombieNightHighway.tscn"

func _init():
	print("=== Building 1.5 KM AAA Desert Zombie Highway (Sunset, Dunes, Wasteland Wrecks & Cliffs) ===")
	var root = Node3D.new()
	root.name = "ZombieNightHighway"
	root.set_script(load("res://scenes/environments/ZombieNightHighway.gd"))
	
	# 1. World Environment (4-5 PM Golden Sunset Sky & Warm Fog)
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = load("res://resources/materials/env_sunset_desert.tres")
	root.add_child(we)
	we.owner = root
	
	# 2. Directional Light (Low Golden Sunset Sun at ~4:30 PM)
	var dl = DirectionalLight3D.new()
	dl.name = "DirectionalLight3D"
	dl.rotation_degrees = Vector3(-14.0, 165.0, 0.0) # Low golden sun casting long dramatic shadows
	dl.light_color = Color(1.0, 0.70, 0.40, 1.0)     # Warm golden sunset light
	dl.light_energy = 1.35
	dl.shadow_enabled = true
	dl.shadow_bias = 0.04
	dl.directional_shadow_max_distance = 55.0
	dl.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	root.add_child(dl)
	dl.owner = root
	
	# 3. Navigation Region & 1,500m Highway Road
	var nav = NavigationRegion3D.new()
	nav.name = "NavigationRegion3D"
	var nav_mesh = NavigationMesh.new()
	var verts = PackedVector3Array([
		Vector3(-8.0, 0.0, -1500.0),
		Vector3(-8.0, 0.0, 20.0),
		Vector3(8.0, 0.0, 20.0),
		Vector3(8.0, 0.0, -1500.0)
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
	
	# Center Asphalt Highway Road Collision Box (15m wide x 1,520m long)
	var ground_col = CollisionShape3D.new()
	ground_col.name = "CollisionShape3D"
	var box_flr = BoxShape3D.new()
	box_flr.size = Vector3(15.0, 0.4, 1520.0)
	ground_col.shape = box_flr
	ground_col.position = Vector3(0.0, -0.2, -740.0)
	ground.add_child(ground_col)
	ground_col.owner = root
	
	# Full-Width Safety Floor (Impenetrable Bedrock Under Highway & Sand Dunes: 95m wide x 1,540m long)
	# Ensures vehicle never falls into void under any circumstances even during high-speed jumps
	var safety_col = CollisionShape3D.new()
	safety_col.name = "SafetyGroundCollision"
	var box_safety = BoxShape3D.new()
	box_safety.size = Vector3(95.0, 1.0, 1540.0)
	safety_col.shape = box_safety
	safety_col.position = Vector3(0.0, -0.6, -740.0)
	ground.add_child(safety_col)
	safety_col.owner = root
	
	# Highway Asphalt Mesh (15m wide x 1,520m long)
	var highway_mat = load("res://resources/materials/mat_real_highway_pbr.tres")
	var highway_mesh = MeshInstance3D.new()
	highway_mesh.name = "HighwayAsphalt"
	var plane_hw = PlaneMesh.new()
	plane_hw.size = Vector2(15.0, 1520.0)
	highway_mesh.mesh = plane_hw
	if highway_mat:
		highway_mesh.set_surface_override_material(0, highway_mat)
	highway_mesh.position = Vector3(0.0, 0.0, -740.0)
	highway_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ground.add_child(highway_mesh)
	highway_mesh.owner = root
	
	# 4. Rolling 3D Sand Dunes (Ret Ke 3D Teele) on Left and Right Shoulders (1.5 KM Long)
	var sand_mat = load("res://resources/materials/mat_real_sand_earth.tres")
	
	# Left Rolling Dunes (X: -7.5 to -45.0, 37.5m wide x 1,530m long)
	var dune_l_mesh = _build_rolling_dune_mesh(-7.5, -45.0, 20.0, -1510.0, 12, 220, sand_mat, true)
	dune_l_mesh.name = "ShoulderLeft"
	dune_l_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ground.add_child(dune_l_mesh)
	dune_l_mesh.owner = root
	
	var col_l = CollisionShape3D.new()
	col_l.name = "ColDunesLeft"
	col_l.shape = dune_l_mesh.mesh.create_trimesh_shape()
	ground.add_child(col_l)
	col_l.owner = root
	
	# Right Rolling Dunes (X: +7.5 to +45.0, 37.5m wide x 1,530m long)
	var dune_r_mesh = _build_rolling_dune_mesh(7.5, 45.0, 20.0, -1510.0, 12, 220, sand_mat, false)
	dune_r_mesh.name = "ShoulderRight"
	dune_r_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ground.add_child(dune_r_mesh)
	dune_r_mesh.owner = root
	
	var col_r = CollisionShape3D.new()
	col_r.name = "ColDunesRight"
	col_r.shape = dune_r_mesh.mesh.create_trimesh_shape()
	ground.add_child(col_r)
	col_r.owner = root
	
	# 5. Props Node
	var props = Node3D.new()
	props.name = "Props"
	root.add_child(props)
	props.owner = root

	# Broken / scenic roadside barriers only at isolated danger zones (leaves 95% open to sand dunes)
	var barrier_res = load("res://assets/roads_kit/glb/road-straight-barrier.glb")
	if barrier_res:
		for crash_z in [-150.0, -380.0, -680.0, -960.0, -1260.0]:
			var b_l = barrier_res.instantiate()
			b_l.name = "BarrierCrashL_%d" % int(abs(crash_z))
			b_l.position = Vector3(-7.8, 0.0, crash_z)
			b_l.scale = Vector3(1.0, 1.2, 1.5)
			b_l.rotation_degrees = Vector3(0, 18, 0)
			props.add_child(b_l)
			b_l.owner = root
			
			var b_r = barrier_res.instantiate()
			b_r.name = "BarrierCrashR_%d" % int(abs(crash_z))
			b_r.position = Vector3(7.8, 0.0, crash_z - 35.0)
			b_r.scale = Vector3(1.0, 1.2, 1.5)
			b_r.rotation_degrees = Vector3(0, -165, 0)
			props.add_child(b_r)
			b_r.owner = root

	# Overhead Highway Signs spanning across highway
	var sign_res = load("res://assets/roads_kit/glb/sign-highway-detailed.glb")
	if sign_res:
		for sign_z in [-80.0, -320.0, -650.0, -980.0, -1320.0]:
			var hw_sign = sign_res.instantiate()
			hw_sign.name = "OverheadSign_%d" % int(abs(sign_z))
			hw_sign.position = Vector3(0.0, 0.0, sign_z)
			hw_sign.scale = Vector3(1.8, 1.8, 1.8)
			props.add_child(hw_sign)
			hw_sign.owner = root

	# Roadside Electricity Poles along western shoulder
	var pole_res = load("res://assets/roads_kit/glb/electricity-pole.glb")
	if pole_res:
		var pole_z = 0.0
		var p_idx = 0
		while pole_z >= -1480.0:
			var pole = pole_res.instantiate()
			pole.name = "PowerPole_%d" % p_idx
			pole.position = Vector3(-8.3, 0.0, pole_z)
			pole.scale = Vector3(1.2, 1.2, 1.2)
			props.add_child(pole)
			pole.owner = root
			pole_z -= 85.0
			p_idx += 1

	# Roadside Abandoned Dumpsters and Construction Debris along shoulders
	var dumpster_res = load("res://assets/roads_kit/glb/dumpster.glb")
	if dumpster_res:
		for d_z in [-160.0, -420.0, -780.0, -1120.0, -1380.0]:
			var d_inst = dumpster_res.instantiate()
			d_inst.name = "Dumpster_%d" % int(abs(d_z))
			d_inst.position = Vector3(8.5, 0.0, d_z)
			d_inst.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
			d_inst.scale = Vector3(1.2, 1.2, 1.2)
			props.add_child(d_inst)
			d_inst.owner = root

	# Desert Scatter Props: Weathered Rock Boulders, Sandstone Cliffs, Dead Trees, and Dry Scrub Bushes
	var rock_tallA_res = load("res://assets/nature_kit/glb/rock_tallA.glb")
	var rock_tallB_res = load("res://assets/nature_kit/glb/rock_tallB.glb")
	var stone_res = load("res://assets/nature_kit/glb/stone_smallC.glb")
	var bush_res = load("res://assets/nature_kit/glb/plant_bushLarge.glb")
	var cliff_res = load("res://assets/nature_kit/glb/cliff_block_rock.glb")
	var tree_res = load("res://assets/nature_kit/glb/tree_plateau_dark.glb")

	var scatter_z = -40.0
	var sc_idx = 0
	while scatter_z >= -1480.0:
		# Left side scatter (X: -14m to -38m)
		var lx = randf_range(-14.0, -38.0)
		var l_dune_y = _get_dune_height(lx, scatter_z)
		_spawn_scatter_prop(lx, l_dune_y, scatter_z, sc_idx, "L", props, root, rock_tallA_res, rock_tallB_res, stone_res, bush_res, cliff_res, tree_res)
		
		# Right side scatter (X: +14m to +38m)
		var rx = randf_range(14.0, 38.0)
		var r_dune_y = _get_dune_height(rx, scatter_z)
		_spawn_scatter_prop(rx, r_dune_y, scatter_z, sc_idx, "R", props, root, rock_tallA_res, rock_tallB_res, stone_res, bush_res, cliff_res, tree_res)

		scatter_z -= randf_range(22.0, 35.0)
		sc_idx += 1

	# Red Explosive Barrels placed down the 1.5 KM highway
	var barrel_z_list = [
		-40.0, -95.0, -180.0, -270.0, -360.0, -470.0, -560.0, -680.0,
		-790.0, -910.0, -1020.0, -1140.0, -1250.0, -1340.0, -1420.0, -1470.0
	]
	for i in range(barrel_z_list.size()):
		var bx = -2.8 if (i % 2 == 0) else 2.8
		_add_packed_prop("res://scenes/objects/ExplosiveBarrel.tscn", Vector3(bx, 0.0, barrel_z_list[i]), Vector3.ZERO, "ExplosiveBarrel_%d" % i, root, root)

	# Atmospheric Enhancer (Sunlight dust particles)
	_add_packed_prop("res://scenes/environments/AtmosphereEnhancer.tscn", Vector3(0, 0, -30), Vector3.ZERO, "AtmosphereEnhancer", root, root)

	# 6. Drivable Car ready at the start of Highway
	var car_scn = load("res://scenes/vehicles/DrivableCar.tscn")
	var car_inst = car_scn.instantiate()
	car_inst.name = "DrivableCar"
	car_inst.position = Vector3(0.0, 0.45, 2.0)
	car_inst.rotation_degrees = Vector3(0, 0, 0)
	root.add_child(car_inst)
	car_inst.owner = root

	# 7. Player Character
	var player_scn = load("res://scenes/player/Player.tscn")
	var player = player_scn.instantiate()
	player.name = "Player"
	player.position = Vector3(0.0, 0.45, 2.0)
	player.add_to_group("player")
	root.add_child(player)
	player.owner = root

	# 8. Impact Pool (Blood & Crash Effects)
	var impact_pool = Node3D.new()
	impact_pool.name = "ImpactPool"
	impact_pool.add_to_group("impact_pool")
	impact_pool.set_script(load("res://scripts/ImpactPool.gd"))
	impact_pool.set("impact_scenes", {
		"blood": load("res://scenes/weapons/BloodEffect.tscn"),
		"metal": load("res://scenes/weapons/ImpactEffect.tscn"),
		"wood": load("res://scenes/weapons/ImpactEffect.tscn"),
		"concrete": load("res://scenes/weapons/ImpactEffect.tscn"),
		"dirt": load("res://scenes/weapons/ImpactEffect.tscn")
	})
	root.add_child(impact_pool)
	impact_pool.owner = root

	# 9. Result UI (Victory / Defeat Dialog)
	var result_ui_scn = load("res://scenes/UI/ResultUI.tscn")
	if result_ui_scn:
		var r_ui = result_ui_scn.instantiate()
		r_ui.name = "ResultUI"
		root.add_child(r_ui)
		r_ui.owner = root

	# 10. Audio Ambience Player
	var ambience = AudioStreamPlayer.new()
	ambience.name = "AmbiencePlayer"
	ambience.process_mode = Node.PROCESS_MODE_ALWAYS
	ambience.stream = load("res://audio/ambience/sfx_horror_drone.tres")
	ambience.volume_db = -4.0
	ambience.autoplay = true
	root.add_child(ambience)
	ambience.owner = root

	# Save packed scene
	var ps = PackedScene.new()
	ps.pack(root)
	var err = ResourceSaver.save(ps, SAVE_PATH)
	if err == OK:
		print("SUCCESS: 1.5 KM AAA Desert Zombie Highway saved to ", SAVE_PATH)
	else:
		print("ERROR: Failed saving Zombie Highway, code: ", err)
	quit(0 if err == OK else 1)

func _get_dune_height(x: float, z: float) -> float:
	var dist_from_road = abs(x) - 7.5
	if dist_from_road <= 0.0:
		return 0.0
	var blend = clampf(dist_from_road / 4.5, 0.0, 1.0)
	
	# Multi-frequency organic desert dunes
	var dune_primary = sin(z * 0.018 + x * 0.04) * 2.2
	var dune_secondary = cos(z * 0.045 + x * 0.12) * 1.1
	var micro_ripple = sin(z * 0.15 + x * 0.25) * 0.35
	var dune_y = (dune_primary + dune_secondary + micro_ripple + 0.8) * blend
	
	# Massive natural desert mountain ridges on outer boundaries (abs(x) > 32m)
	if abs(x) > 32.0:
		var edge_t = (abs(x) - 32.0) / 13.0
		dune_y += edge_t * edge_t * 9.5
		
	return maxf(dune_y, -0.05)

func _build_rolling_dune_mesh(x_start: float, x_end: float, z_start: float, z_end: float, x_steps: int, z_steps: int, mat: Material, is_left: bool) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var dx = (x_end - x_start) / float(x_steps)
	var dz = (z_end - z_start) / float(z_steps)
	
	for zi in range(z_steps + 1):
		var z = z_start + zi * dz
		for xi in range(x_steps + 1):
			var x = x_start + xi * dx
			var y = _get_dune_height(x, z)
			
			var u = x * 0.35
			var v = z * 0.35
			st.set_uv(Vector2(u, v))
			st.add_vertex(Vector3(x, y, z))
			
	for zi in range(z_steps):
		for xi in range(x_steps):
			var i0 = zi * (x_steps + 1) + xi
			var i1 = i0 + 1
			var i2 = (zi + 1) * (x_steps + 1) + xi
			var i3 = i2 + 1
			
			if is_left:
				# Left Dune (x decreases, z decreases): (i0, i2, i1) and (i1, i2, i3) produces UPWARD normal (+Y)
				st.add_index(i0); st.add_index(i2); st.add_index(i1)
				st.add_index(i1); st.add_index(i2); st.add_index(i3)
			else:
				# Right Dune (x increases, z decreases): (i0, i1, i2) and (i1, i3, i2) produces UPWARD normal (+Y)
				st.add_index(i0); st.add_index(i1); st.add_index(i2)
				st.add_index(i1); st.add_index(i3); st.add_index(i2)
				
	st.generate_normals()
	st.generate_tangents()
	var mesh = st.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	if mat:
		mi.set_surface_override_material(0, mat)
	return mi

func _spawn_scatter_prop(x: float, y: float, z: float, idx: int, side: String, parent: Node, root_node: Node, rock_tallA: PackedScene, rock_tallB: PackedScene, stone: PackedScene, bush: PackedScene, cliff: PackedScene, dead_tree: PackedScene):
	var roll = randf()
	var scn: PackedScene = null
	var scale_vec = Vector3.ONE
	
	if abs(x) > 26.0 and roll < 0.30 and cliff:
		scn = cliff
		scale_vec = Vector3.ONE * randf_range(2.0, 3.5)
	elif roll < 0.25 and dead_tree:
		scn = dead_tree
		scale_vec = Vector3.ONE * randf_range(1.1, 1.7)
	elif roll < 0.55 and bush:
		scn = bush
		scale_vec = Vector3.ONE * randf_range(1.3, 2.2)
	elif roll < 0.80 and (rock_tallA or rock_tallB):
		scn = rock_tallA if randf() > 0.5 else rock_tallB
		scale_vec = Vector3.ONE * randf_range(1.0, 1.8)
	elif stone:
		scn = stone
		scale_vec = Vector3.ONE * randf_range(1.0, 1.6)
		
	if scn:
		var inst = scn.instantiate()
		inst.name = "Scatter_%s_%d" % [side, idx]
		inst.position = Vector3(x, y, z)
		inst.scale = scale_vec
		inst.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
		parent.add_child(inst)
		inst.owner = root_node

func _add_packed_prop(path: String, pos: Vector3, rot_deg: Vector3, node_name: String, parent: Node, owner_node: Node) -> Node:
	if not ResourceLoader.exists(path):
		print("Warning: Prop path does not exist: ", path)
		return null
	var scn = load(path)
	if not scn:
		return null
	var inst = scn.instantiate()
	inst.name = node_name
	inst.position = pos
	inst.rotation_degrees = rot_deg
	parent.add_child(inst)
	inst.owner = owner_node
	return inst
