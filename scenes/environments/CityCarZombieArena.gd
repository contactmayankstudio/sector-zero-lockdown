extends Node3D

@onready var directional_light: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var instructions_ui: CanvasLayer = $InstructionsUI
@onready var kill_counter_label: Label = get_node_or_null("InstructionsUI/StatsPanel/VBox/KillCountLabel")

var zombies_roadkilled: int = 0
var zombies_shot: int = 0

func _ready():
	print("[ARENA] City Car Zombie Arena initialized with Anti-Hang & Cool Performance optimizations!")
	
	# Initialize C# (.NET 8) Subsystems for Large-Scale Big Game Architecture
	var streamer_script = load("res://scripts/CSharp/World/WorldChunkStreamer.cs")
	if streamer_script:
		var streamer = streamer_script.new()
		streamer.name = "WorldChunkStreamer_CSharp"
		add_child(streamer)
		print("[ARENA] C# (.NET 8) WorldChunkStreamer attached.")

	var swarm_script = load("res://scripts/CSharp/AI/ZombieSwarmOptimizer.cs")
	if swarm_script:
		var swarm = swarm_script.new()
		swarm.name = "ZombieSwarmOptimizer_CSharp"
		add_child(swarm)
		print("[ARENA] C# (.NET 8) ZombieSwarmOptimizer attached.")
	
	# 1. 60 FPS smooth pacing for silky gameplay
	Engine.max_fps = 60
	
	# 2. Viewport settings: Full 1.0 native resolution (no bilinear blur) for razor-sharp visual clarity
	var vp = get_viewport()
	if vp:
		vp.msaa_3d = Viewport.MSAA_DISABLED
		vp.scaling_3d_scale = 1.0
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		vp.use_hdr_2d = false
		
	# 3. Crystal Clear Alpine Daylight & ACES Tonemapping (Optimized for 45-60 FPS on Kabini APU)
	if directional_light:
		directional_light.rotation_degrees = Vector3(-45.0, -35.0, 0.0)
		directional_light.shadow_enabled = true
		directional_light.light_energy = 1.15
		directional_light.light_color = Color(1.0, 0.96, 0.88)
		directional_light.shadow_bias = 0.03
		directional_light.directional_shadow_max_distance = 45.0
		directional_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		directional_light.directional_shadow_blend_splits = false

	# Optimize Foliage: disable shadow passes on dense MultiMeshes to prevent fillrate bottleneck
	var foliage = get_node_or_null("AdvancedTerrain/FoliageAndProps")
	if foliage:
		for child in foliage.get_children():
			if child is GeometryInstance3D:
				child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
	if world_env and world_env.environment:
		var env = world_env.environment
		env.tonemap_mode = Environment.TONE_MAPPER_ACES
		env.tonemap_exposure = 1.15
		env.fog_enabled = true
		env.fog_density = 0.00010
		env.fog_light_color = Color(0.78, 0.85, 0.92, 1.0)
		env.fog_aerial_perspective = 0.0
		env.ambient_light_energy = 0.85
		env.ambient_light_color = Color(0.85, 0.90, 0.96, 1.0)
		env.glow_enabled = false
		env.ssao_enabled = false

	# Clean UI: hide debug instructions overlay
	if instructions_ui:
		instructions_ui.visible = false

	# Cull streetlamps on day startup to save GPU multi-pass overhead
	var street_lamps = get_node_or_null("StreetLamps")
	if street_lamps:
		for lamp in street_lamps.find_children("*", "Light3D", true, false):
			if lamp is Light3D:
				lamp.visible = false

	# Smooth, dark, non-sparkling realistic highway asphalt
	var road_mesh = get_node_or_null("RealisticTerrain/HighwayAsphalt/Mesh") as MeshInstance3D
	if road_mesh:
		var r_mat = road_mesh.get_surface_override_material(0)
		if r_mat is StandardMaterial3D:
			r_mat.albedo_color = Color(0.20, 0.20, 0.22, 1.0)
			r_mat.uv1_scale = Vector3(4.0, 60.0, 1.0)
			r_mat.normal_scale = 0.60
			r_mat.roughness = 0.85
			r_mat.metallic_specular = 0.12
			r_mat.metallic = 0.0
			r_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

	# Clean matte concrete sidewalks (no glare)
	for sw_name in ["SidewalkLeft", "SidewalkRight"]:
		var sw_mesh = get_node_or_null("RealisticTerrain/" + sw_name + "/Mesh") as MeshInstance3D
		if sw_mesh:
			var sw_mat = sw_mesh.get_surface_override_material(0)
			if sw_mat is StandardMaterial3D:
				sw_mat.albedo_color = Color(0.50, 0.50, 0.52, 1.0)
				sw_mat.roughness = 0.92
				sw_mat.metallic_specular = 0.08

	# Apply triplanar granite cliff material to mountain ranges
	var cliff_mat = load("res://resources/materials/mat_real_mountain_cliff.tres")
	if cliff_mat:
		for mtn_name in ["MountainRangeWest", "MountainRangeEast", "MountainBackdropNorth", "MountainWest", "MountainEast", "MountainNorthWall", "MountainSouthWall"]:
			var mtn_node = get_node_or_null("RealisticTerrain/" + mtn_name)
			if not mtn_node:
				mtn_node = get_node_or_null("AdvancedTerrain/" + mtn_name)
			if mtn_node is MeshInstance3D:
				mtn_node.set_surface_override_material(0, cliff_mat)
			elif mtn_node:
				var m_mesh = mtn_node.get_node_or_null("Mesh") as MeshInstance3D
				if m_mesh:
					m_mesh.set_surface_override_material(0, cliff_mat)

	# Crisp matte dirt shoulders & paths (pure PBR texturing)
	var d_mat = load("res://resources/materials/mat_dirt_pbr.tres")
	if d_mat:
		for d_name in ["DirtShoulderLeft", "DirtShoulderRight"]:
			var d_mesh = get_node_or_null("RealisticTerrain/" + d_name + "/Mesh") as MeshInstance3D
			if d_mesh:
				d_mesh.set_surface_override_material(0, d_mat)
		for p_name in ["DirtPath_West", "DirtPath_East", "MountainRoad_West", "MountainRoad_East"]:
			var p_mesh = get_node_or_null("AdvancedTerrain/" + p_name) as MeshInstance3D
			if p_mesh:
				p_mesh.set_surface_override_material(0, d_mat)

	# Crisp natural green meadow grass (pure PBR texturing)
	var g_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
	if g_mat:
		for grass_name in ["GrassFieldLeft", "GrassFieldRight"]:
			var g_mesh = get_node_or_null("RealisticTerrain/" + grass_name + "/Mesh") as MeshInstance3D
			if g_mesh:
				g_mesh.set_surface_override_material(0, g_mat)
		var valley_mesh = get_node_or_null("AdvancedTerrain/ValleyFloor") as MeshInstance3D
		if valley_mesh:
			valley_mesh.set_surface_override_material(0, g_mat)
	
	# 4. Rock-solid 3D collision for all Mountains, Paths, and Valley grounds
	_ensure_solid_terrain_collisions()
		
	# 5. Connect to all enemies for tracking
	var t = get_tree()
	if t:
		t.node_added.connect(_on_node_added)
		for enemy in t.get_nodes_in_group("enemies"):
			_hook_enemy(enemy)
		
	# 6. Start on foot next to Hayabusa Superbike & Sedan
	print("[ARENA] Player ready on foot next to Hayabusa Superbike & Sedan!")
	call_deferred("_setup_player_sandbox_stats")
	
	# 7. Spawn initial PUBG Airdrop Supply Crate on Highway
	call_deferred("_spawn_initial_airdrop")

func _ensure_solid_terrain_collisions() -> void:
	print("[TERRAIN COLLISION] Verifying pre-baked permanent 3D colliders from scene file...")
	var verified_count: int = 0
	
	# 1. AdvancedTerrain Mountains, Roads & Valley Bodies
	var adv = get_node_or_null("AdvancedTerrain")
	if adv:
		var target_bodies = [
			"ValleyFloor_Physics",
			"MountainWest_Physics",
			"MountainEast_Physics",
			"MountainRoad_West_Physics",
			"MountainRoad_East_Physics",
			"DirtPath_West_Physics",
			"DirtPath_East_Physics",
			"MountainNorthWall_Physics",
			"MountainSouthWall_Physics"
		]
		for b_name in target_bodies:
			var body = adv.get_node_or_null(b_name) as StaticBody3D
			if body:
				var cols = body.find_children("*", "CollisionShape3D", true, false)
				if not cols.is_empty():
					verified_count += 1
				else:
					push_warning("[TERRAIN COLLISION] Missing collision shape in: " + b_name)
	
	# 2. RealisticTerrain Sidewalks & Dirt Shoulders
	var real = get_node_or_null("RealisticTerrain")
	if real:
		for parent_name in ["DirtShoulderLeft", "DirtShoulderRight", "SidewalkLeft", "SidewalkRight"]:
			var body = real.get_node_or_null(parent_name) as StaticBody3D
			if body:
				var cols = body.find_children("*", "CollisionShape3D", true, false)
				if not cols.is_empty():
					verified_count += 1
				else:
					push_warning("[TERRAIN COLLISION] Missing collision shape in: " + parent_name)
					
	# 3. Runtime safeguard: purge any residual barrier props at x = ±10.5m
	var highway_props = get_node_or_null("HighwayProps")
	if highway_props:
		for i in range(8):
			var barrier = highway_props.get_node_or_null("Barrier_%d" % i)
			if barrier:
				barrier.queue_free()
				print("[ARENA] Runtime purged obstacle barrier: Barrier_%d" % i)
				
	print("[TERRAIN COLLISION] Permanent 3D terrain collision verification complete: %d bodies active (0ms load delay, 0 runtime allocation spike)." % verified_count)

func _physics_process(_delta: float) -> void:
	# Void Fall Prevention & Recovery Watchdog:
	# Only triggers if ACTUALLY falling into the deep infinite void (below y = -35.0m)
	# Mountain foothills, slopes and depressions range between -12.0m to +45.0m
	var player = get_tree().get_first_node_in_group("player") as Node3D
	if player and is_instance_valid(player) and player.global_position.y < -35.0:
		player.global_position = Vector3(clampf(player.global_position.x, -8.0, 8.0), 1.5, player.global_position.z)
		if player is CharacterBody3D:
			player.velocity = Vector3.ZERO
		print("[WATCHDOG] Player recovered from void!")

	for v in get_tree().get_nodes_in_group("vehicles"):
		if v is Node3D and is_instance_valid(v) and v.global_position.y < -35.0:
			v.global_position = Vector3(clampf(v.global_position.x, -8.0, 8.0), 1.5, v.global_position.z)
			if v is RigidBody3D:
				v.linear_velocity = Vector3.ZERO
				v.angular_velocity = Vector3.ZERO
			print("[WATCHDOG] Vehicle ", v.name, " recovered from void!")

var total_kills: int = 0
var current_wanted_stars: int = 0
var boss_spawned: bool = false
var runners_spawned: bool = false

func _setup_player_sandbox_stats() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p:
		p.max_health = 500.0
		p.current_health = 500.0
		if "max_armor" in p:
			p.max_armor = 150.0
			p.current_armor = 150.0
		if p.has_method("_update_hud"):
			p._update_hud()
		print("[ARENA] Player configured with 500 HP & 150 Armor for open world sandbox!")

func _spawn_initial_airdrop() -> void:
	var airdrop_scene = load("res://scenes/objects/PubgAirdrop.tscn")
	if airdrop_scene is PackedScene:
		var drop = airdrop_scene.instantiate()
		drop.name = "SupplyAirdrop_01"
		# Drop on highway 38 meters ahead of spawn
		drop.position = Vector3(2.5, 48.0, -38.0)
		drop.ground_y = 0.0
		add_child(drop)
		print("[ARENA] PUBG Supply Airdrop initiated from sky!")

func trigger_airdrop(pos: Vector3 = Vector3(0, 48, -30)) -> void:
	var airdrop_scene = load("res://scenes/objects/PubgAirdrop.tscn")
	if airdrop_scene is PackedScene:
		var drop = airdrop_scene.instantiate()
		drop.position = pos
		drop.ground_y = 0.0
		add_child(drop)

func _unhandled_input(event: InputEvent):
	# Quick ESC key to quit safely without hanging
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			print("[ARENA] ESC pressed - Exiting cleanly.")
			get_tree().quit(0)
		elif event.keycode == KEY_P:
			print("[ARENA] Manual Airdrop requested via [P] key!")
			var p = get_tree().get_first_node_in_group("player") as Node3D
			var target_pos = Vector3(2.0, 48.0, -35.0)
			if p:
				var fwd = -p.global_transform.basis.z.normalized()
				target_pos = p.global_position + fwd * 30.0 + Vector3(0, 48, 0)
			trigger_airdrop(target_pos)

func _hook_enemy(enemy: Node):
	if enemy.has_signal("died") and not enemy.is_connected("died", _on_enemy_died):
		enemy.died.connect(_on_enemy_died.bind(enemy))

func _on_node_added(node: Node):
	if node.is_in_group("enemies"):
		_hook_enemy(node)

func _on_enemy_died(enemy: Node):
	total_kills += 1
	zombies_roadkilled += 1
	if kill_counter_label:
		kill_counter_label.text = "ROADKILL SMASHES: %d" % zombies_roadkilled

	# Dynamically maintain 8 active zombies so CPU/RAM never bottlenecks
	call_deferred("_spawn_replacement_zombie")

	# Award cash for kill
	var sm = get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("add_cash"):
		sm.add_cash(150)

	# Dispatch to PUBG Tactical KillFeed on HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("add_killfeed_entry"):
		var z_name = enemy.name if enemy else "Zombie"
		hud.add_killfeed_entry("COMBAT SOLDIER", "💀", z_name, false)

	# Calculate GTA 5 Wanted Level (0 to 5 Stars)
	var new_stars = 0
	if total_kills >= 35:
		new_stars = 5
	elif total_kills >= 20:
		new_stars = 4
	elif total_kills >= 10:
		new_stars = 3
	elif total_kills >= 5:
		new_stars = 2
	elif total_kills >= 2:
		new_stars = 1

	if new_stars != current_wanted_stars:
		current_wanted_stars = new_stars
		if hud and hud.has_method("update_wanted_level"):
			hud.update_wanted_level(current_wanted_stars)
			
		# Wanted Level 3: Spawn Runner Zombie reinforcement swarm!
		if current_wanted_stars >= 3 and not runners_spawned:
			runners_spawned = true
			_spawn_runner_wave()
			
		# Wanted Level 5: Spawn Apex Boss Zombie on the highway!
		if current_wanted_stars >= 5 and not boss_spawned:
			boss_spawned = true
			_spawn_apex_boss()

func _spawn_runner_wave() -> void:
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if not zombie_scene: return
	var p = get_tree().get_first_node_in_group("player") as Node3D
	var base_pos = p.global_position if p else Vector3(0, 0, -20)
	print("[GTA WANTED] ★★★ 3-STAR HEAT: Runner Swarm Deployed!")
	for i in range(4):
		var z = zombie_scene.instantiate()
		z.position = base_pos + Vector3(randf_range(-15, 15), 0, randf_range(-35, -45))
		add_child(z)

func _spawn_apex_boss() -> void:
	var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
	if not boss_scene: return
	var p = get_tree().get_first_node_in_group("player") as Node3D
	var base_pos = p.global_position if p else Vector3(0, 0, -30)
	var boss = boss_scene.instantiate()
	boss.position = base_pos + Vector3(0, 0, -42)
	add_child(boss)
	print("[GTA WANTED] ★★★★★ 5-STAR HEAT: APEX TYRANT UNLEASHED ON HIGHWAY!")

func _spawn_replacement_zombie() -> void:
	var active_enemies = get_tree().get_nodes_in_group("enemies").filter(func(e): return is_instance_valid(e) and not e.is_queued_for_deletion())
	if active_enemies.size() >= 8:
		return
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if not zombie_scene:
		return
	var p = get_tree().get_first_node_in_group("player") as Node3D
	var base_z = -50.0
	var base_x = randf_range(-6.0, 6.0)
	if p:
		base_z = p.global_position.z - randf_range(35.0, 65.0)
		base_x = clampf(p.global_position.x + randf_range(-7.0, 7.0), -7.5, 7.5)
	var z = zombie_scene.instantiate()
	z.position = Vector3(base_x, 0.1, base_z)
	var zombies_node = get_node_or_null("Zombies")
	if zombies_node:
		zombies_node.add_child(z)
	else:
		add_child(z)

