extends Node3D

## Zombie Night Highway - Endless Roadkill & Zombie Crushing Arena
## Long PBR Highway with Drivable Cruiser, Zombie Roadkill Spawns & Gore Mechanics.

@onready var highway_asphalt = get_node_or_null("NavigationRegion3D/Ground/HighwayAsphalt") as MeshInstance3D
@onready var shoulder_left = get_node_or_null("NavigationRegion3D/Ground/ShoulderLeft") as MeshInstance3D
@onready var shoulder_right = get_node_or_null("NavigationRegion3D/Ground/ShoulderRight") as MeshInstance3D
@onready var car: DrivableCar = get_node_or_null("DrivableCar") as DrivableCar
@onready var player: Node3D = get_node_or_null("Player") as Node3D

var zombie_scene: PackedScene = preload("res://scenes/zombies/Zombie.tscn")
var barrel_scene: PackedScene = preload("res://scenes/objects/ExplosiveBarrel.tscn")
var active_zombies: Array[Node3D] = []
var active_barrels: Array[Node3D] = []
var max_active_zombies: int = 24
var max_active_barrels: int = 10
var roadkill_count: int = 0
var roadkill_streak: int = 0
var streak_timer: float = 0.0

var hud_layer: CanvasLayer = null
var roadkill_label: Label = null
var streak_label: Label = null
var blood_overlay: ColorRect = null
var combo_popup_label: Label = null

func _ready():
	print("[ZOMBIE HIGHWAY] Initializing Super Long Roadkill Highway Arena (1.5 KM)...")
	
	# Apply 1K PBR Highway Textures with tiled UVs for long road
	_apply_highway_pbr_textures()
	
	# Configure GTA 5 Clear Sky & Radiant Sunlight Atmosphere
	var we = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if we:
		we.environment = load("res://resources/materials/env_gta5_clear_sky.tres")
		
	var sun = get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if sun:
		sun.light_color = Color(1.0, 0.97, 0.92)
		sun.light_energy = 1.45

	# Build Roadkill HUD Overlay
	_build_roadkill_hud()
	
	# Build Super Highway Infrastructure (Reflector Posts, Barricades, Overpass Signs)
	_build_highway_infrastructure()
	
	# Play high-adrenaline highway battle music
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_combat_music"):
		am.play_combat_music()
	
	# Connect C# Subsystems if present
	var streamer_script = load("res://scripts/CSharp/World/WorldChunkStreamer.cs")
	if streamer_script:
		var streamer = streamer_script.new()
		streamer.name = "WorldChunkStreamer_CSharp"
		add_child(streamer)
		
	# Setup Car Tire Sand Dust Particle Trails
	_setup_car_tire_dust()
		
	# Put player into driver's seat immediately
	call_deferred("_start_in_car")
	
	# Spawn initial highway zombie waves & explosive fuel barrels ahead of car
	call_deferred("_spawn_initial_highway_horde")

func _build_roadkill_hud():
	hud_layer = CanvasLayer.new()
	hud_layer.name = "RoadkillHUD"
	hud_layer.layer = 10
	add_child(hud_layer)
	
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(container)
	
	# Windshield Blood Splatter Flash (Full Screen Vignette)
	blood_overlay = ColorRect.new()
	blood_overlay.name = "BloodSplatterOverlay"
	blood_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	blood_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blood_overlay.color = Color(0.7, 0.04, 0.04, 0.0)
	container.add_child(blood_overlay)
	
	# Big Floating Combo Popup (Center Screen)
	combo_popup_label = Label.new()
	combo_popup_label.name = "ComboPopupLabel"
	combo_popup_label.set_anchors_preset(Control.PRESET_CENTER)
	combo_popup_label.offset_left = -300.0
	combo_popup_label.offset_top = -120.0
	combo_popup_label.offset_right = 300.0
	combo_popup_label.offset_bottom = -40.0
	combo_popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combo_popup_label.add_theme_font_size_override("font_size", 36)
	combo_popup_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1, 0.0))
	container.add_child(combo_popup_label)
	
	# Roadkill Counter (Top Center)
	var panel = PanelContainer.new()
	container.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -220.0
	panel.offset_top = 18.0
	panel.offset_right = 220.0
	panel.offset_bottom = 82.0
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	roadkill_label = Label.new()
	roadkill_label.text = "💀 ZOMBIES CRUSHED: 0"
	roadkill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	roadkill_label.add_theme_font_size_override("font_size", 22)
	roadkill_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	vbox.add_child(roadkill_label)
	
	streak_label = Label.new()
	streak_label.text = "SPEED DOWN HIGHWAY & CRUSH ZOMBIES!"
	streak_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	streak_label.add_theme_font_size_override("font_size", 14)
	streak_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(streak_label)

	# --- MOBILE TOUCH CONTROLS ---
	# Top Right: Menu Button
	var menu_btn = Button.new()
	menu_btn.text = "🏠 MAIN MENU"
	menu_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	menu_btn.offset_left = -160.0
	menu_btn.offset_top = 18.0
	menu_btn.offset_right = -20.0
	menu_btn.offset_bottom = 68.0
	menu_btn.add_theme_font_size_override("font_size", 16)
	menu_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
	)
	container.add_child(menu_btn)

	# Top Left: Flip / Rescue Car Button
	var flip_btn = Button.new()
	flip_btn.text = "🔄 RESCUE CAR [R]"
	flip_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	flip_btn.offset_left = 20.0
	flip_btn.offset_top = 18.0
	flip_btn.offset_right = 180.0
	flip_btn.offset_bottom = 68.0
	flip_btn.add_theme_font_size_override("font_size", 15)
	flip_btn.pressed.connect(func():
		if car and is_instance_valid(car):
			car.rotation_degrees = Vector3(0, car.rotation_degrees.y, 0)
			car.global_position.y += 1.0
			car.linear_velocity = Vector3.ZERO
			car.angular_velocity = Vector3.ZERO
	)
	container.add_child(flip_btn)

	# Bottom Left: Steering Touch Controls (Left / Right)
	var steer_left_btn = Button.new()
	steer_left_btn.text = "◀"
	steer_left_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	steer_left_btn.offset_left = 25.0
	steer_left_btn.offset_top = -145.0
	steer_left_btn.offset_right = 140.0
	steer_left_btn.offset_bottom = -25.0
	steer_left_btn.add_theme_font_size_override("font_size", 42)
	steer_left_btn.button_down.connect(func():
		if car and is_instance_valid(car):
			car.touch_steer = 1.0
	)
	steer_left_btn.button_up.connect(func():
		if car and is_instance_valid(car) and car.touch_steer == 1.0:
			car.touch_steer = 0.0
	)
	container.add_child(steer_left_btn)

	var steer_right_btn = Button.new()
	steer_right_btn.text = "▶"
	steer_right_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	steer_right_btn.offset_left = 155.0
	steer_right_btn.offset_top = -145.0
	steer_right_btn.offset_right = 270.0
	steer_right_btn.offset_bottom = -25.0
	steer_right_btn.add_theme_font_size_override("font_size", 42)
	steer_right_btn.button_down.connect(func():
		if car and is_instance_valid(car):
			car.touch_steer = -1.0
	)
	steer_right_btn.button_up.connect(func():
		if car and is_instance_valid(car) and car.touch_steer == -1.0:
			car.touch_steer = 0.0
	)
	container.add_child(steer_right_btn)

	# Bottom Right: Driving Controls (Brake, Gas, Nitro)
	var brake_btn = Button.new()
	brake_btn.text = "🛑\nBRAKE"
	brake_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	brake_btn.offset_left = -285.0
	steer_left_btn.offset_top = -145.0
	brake_btn.offset_top = -145.0
	brake_btn.offset_right = -160.0
	brake_btn.offset_bottom = -25.0
	brake_btn.add_theme_font_size_override("font_size", 18)
	brake_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	brake_btn.button_down.connect(func():
		if car and is_instance_valid(car):
			car.touch_throttle = -0.7
	)
	brake_btn.button_up.connect(func():
		if car and is_instance_valid(car) and car.touch_throttle < 0.0:
			car.touch_throttle = 0.0
	)
	container.add_child(brake_btn)

	var gas_btn = Button.new()
	gas_btn.text = "🚀\nGAS"
	gas_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	gas_btn.offset_left = -145.0
	gas_btn.offset_top = -175.0
	gas_btn.offset_right = -25.0
	gas_btn.offset_bottom = -25.0
	gas_btn.add_theme_font_size_override("font_size", 22)
	gas_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	gas_btn.button_down.connect(func():
		if car and is_instance_valid(car):
			car.touch_throttle = 1.0
	)
	gas_btn.button_up.connect(func():
		if car and is_instance_valid(car) and car.touch_throttle > 0.0:
			car.touch_throttle = 0.0
	)
	container.add_child(gas_btn)

	var nitro_btn = Button.new()
	nitro_btn.text = "⚡ NITRO"
	nitro_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	nitro_btn.offset_left = -145.0
	nitro_btn.offset_top = -255.0
	nitro_btn.offset_right = -25.0
	nitro_btn.offset_bottom = -190.0
	nitro_btn.add_theme_font_size_override("font_size", 18)
	nitro_btn.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0))
	nitro_btn.button_down.connect(func():
		if car and is_instance_valid(car):
			car.touch_boost = true
	)
	nitro_btn.button_up.connect(func():
		if car and is_instance_valid(car):
			car.touch_boost = false
	)
	container.add_child(nitro_btn)

func _start_in_car():
	if car and is_instance_valid(car) and player and is_instance_valid(player):
		car.global_position = Vector3(0.0, 0.45, 0.0)
		player.global_position = Vector3(0.0, 0.45, 0.0)
		car.enter_vehicle(player)
		print("[ZOMBIE HIGHWAY] Player seated in driver's seat. Gas pedal READY!")

func _setup_car_tire_dust():
	if not car:
		return
	for offset_x in [-0.85, 0.85]:
		var emitter = CPUParticles3D.new()
		emitter.name = "TireDust_" + ("L" if offset_x < 0 else "R")
		emitter.position = Vector3(offset_x, 0.05, 1.4)
		emitter.emitting = true
		emitter.amount = 14
		emitter.lifetime = 0.50
		emitter.explosiveness = 0.0
		emitter.randomness = 0.3
		emitter.direction = Vector3(0, 0.35, 1.0)
		emitter.spread = 22.0
		emitter.gravity = Vector3(0, 1.0, 0)
		emitter.initial_velocity_min = 2.0
		emitter.initial_velocity_max = 4.5
		emitter.scale_amount_min = 0.15
		emitter.scale_amount_max = 0.40
		
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.92, 0.68, 0.38, 0.25)
		
		var quad = QuadMesh.new()
		quad.size = Vector2(0.35, 0.35)
		quad.material = mat
		emitter.mesh = quad
		car.add_child(emitter)

func _apply_highway_pbr_textures():
	if not highway_asphalt:
		return
	
	var col_path = ProjectSettings.globalize_path("res://textures/pbr/highway/Road007_1K-JPG_Color.jpg")
	var nor_path = ProjectSettings.globalize_path("res://textures/pbr/highway/Road007_1K-JPG_NormalGL.jpg")
	var rgh_path = ProjectSettings.globalize_path("res://textures/pbr/highway/Road007_1K-JPG_Roughness.jpg")
	
	if FileAccess.file_exists(col_path):
		var img_col = Image.load_from_file(col_path)
		var tex_col = ImageTexture.create_from_image(img_col)
		
		var mat = StandardMaterial3D.new()
		mat.resource_name = "mat_highway_road007"
		mat.albedo_texture = tex_col
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		# 1,500m highway -> 150 texture repeats along Z
		mat.uv1_scale = Vector3(1.0, 150.0, 1.0)
		mat.roughness = 0.82
		
		if FileAccess.file_exists(nor_path):
			var img_nor = Image.load_from_file(nor_path)
			mat.normal_enabled = true
			mat.normal_scale = 1.0
			mat.normal_texture = ImageTexture.create_from_image(img_nor)
			
		if FileAccess.file_exists(rgh_path):
			var img_rgh = Image.load_from_file(rgh_path)
			mat.roughness_texture = ImageTexture.create_from_image(img_rgh)
			mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
			
		if highway_asphalt:
			highway_asphalt.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			highway_asphalt.set_surface_override_material(0, mat)
		print("[ZOMBIE HIGHWAY] Applied Road007 High-Graphics PBR Highway Textures (1.5 KM scale)!")

	# Apply Ground037 Authentic Photorealistic GTA 5 Earth, Mitti & Ghaas (Soil & Grass)
	var mitti_col_path = ProjectSettings.globalize_path("res://textures/pbr/gta5_ground/Ground037_1K-JPG_Color.jpg")
	var mitti_nor_path = ProjectSettings.globalize_path("res://textures/pbr/gta5_ground/Ground037_1K-JPG_NormalGL.jpg")
	var mitti_rgh_path = ProjectSettings.globalize_path("res://textures/pbr/gta5_ground/Ground037_1K-JPG_Roughness.jpg")
	var mitti_ao_path = ProjectSettings.globalize_path("res://textures/pbr/gta5_ground/Ground037_1K-JPG_AmbientOcclusion.jpg")
	
	if FileAccess.file_exists(mitti_col_path):
		var img_mitti_col = Image.load_from_file(mitti_col_path)
		var tex_mitti_col = ImageTexture.create_from_image(img_mitti_col)
		
		var mitti_mat = StandardMaterial3D.new()
		mitti_mat.resource_name = "mat_gta5_mitti_ghaas_pbr"
		mitti_mat.albedo_texture = tex_mitti_col
		mitti_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		mitti_mat.uv1_scale = Vector3(4.5, 120.0, 4.5) # Crisp authentic roadside soil and grass
		mitti_mat.roughness = 0.88
		mitti_mat.metallic_specular = 0.05
		
		if FileAccess.file_exists(mitti_nor_path):
			var img_mitti_nor = Image.load_from_file(mitti_nor_path)
			mitti_mat.normal_enabled = true
			mitti_mat.normal_scale = 1.35
			mitti_mat.normal_texture = ImageTexture.create_from_image(img_mitti_nor)
			
		if FileAccess.file_exists(mitti_rgh_path):
			var img_mitti_rgh = Image.load_from_file(mitti_rgh_path)
			mitti_mat.roughness_texture = ImageTexture.create_from_image(img_mitti_rgh)
			mitti_mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
			
		if FileAccess.file_exists(mitti_ao_path):
			var img_mitti_ao = Image.load_from_file(mitti_ao_path)
			mitti_mat.ao_enabled = true
			mitti_mat.ao_light_affect = 0.45
			mitti_mat.ao_texture = ImageTexture.create_from_image(img_mitti_ao)
			
		if shoulder_left:
			shoulder_left.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			shoulder_left.set_surface_override_material(0, mitti_mat)
		if shoulder_right:
			shoulder_right.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			shoulder_right.set_surface_override_material(0, mitti_mat)
		print("[ZOMBIE HIGHWAY] Applied Ground037 Authentic GTA 5 Soil + Grass (Mitti + Ghaas) to both road shoulders!")

func _build_highway_infrastructure():
	var infra_parent = Node3D.new()
	infra_parent.name = "HighwayInfrastructure"
	add_child(infra_parent)
	
	# Reusable Post Mesh & Materials for Speed Parallax
	var post_mesh = CylinderMesh.new()
	post_mesh.top_radius = 0.06
	post_mesh.bottom_radius = 0.06
	post_mesh.height = 1.1
	
	var post_mat = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.18, 0.18, 0.20)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.25
	post_mesh.material = post_mat
	
	var reflector_mat = StandardMaterial3D.new()
	reflector_mat.albedo_color = Color(1.0, 0.75, 0.1)
	reflector_mat.emission_enabled = true
	reflector_mat.emission = Color(1.0, 0.7, 0.1)
	reflector_mat.emission_energy_multiplier = 3.5
	
	var reflector_mesh = CylinderMesh.new()
	reflector_mesh.top_radius = 0.065
	reflector_mesh.bottom_radius = 0.065
	reflector_mesh.height = 0.16
	reflector_mesh.material = reflector_mat
	
	# Ultra-Optimized MultiMesh: 280 posts rendered in just 2 Draw Calls (60 FPS Butter Smooth!)
	var post_positions: Array[Vector3] = []
	for z_pos in range(20, -1490, -22):
		for side_x in [-7.5, 7.5]:
			post_positions.append(Vector3(side_x, 0.55, float(z_pos)))
			
	var post_mm = MultiMeshInstance3D.new()
	var mm_posts = MultiMesh.new()
	mm_posts.transform_format = MultiMesh.TRANSFORM_3D
	mm_posts.mesh = post_mesh
	mm_posts.instance_count = post_positions.size()
	
	var ref_mm = MultiMeshInstance3D.new()
	var mm_refs = MultiMesh.new()
	mm_refs.transform_format = MultiMesh.TRANSFORM_3D
	mm_refs.mesh = reflector_mesh
	mm_refs.instance_count = post_positions.size()
	
	for i in range(post_positions.size()):
		var p = post_positions[i]
		mm_posts.set_instance_transform(i, Transform3D(Basis(), p))
		mm_refs.set_instance_transform(i, Transform3D(Basis(), p + Vector3(0.0, 0.38, 0.0)))
		
	post_mm.multimesh = mm_posts
	ref_mm.multimesh = mm_refs
	infra_parent.add_child(post_mm)
	infra_parent.add_child(ref_mm)
			
	# Spawn Highway Overpass Signs & Wrecked Vehicles at milestones
	var sign_scene = load("res://assets/roads_kit/glb/sign-highway-detailed.glb")
	var barrier_scene = load("res://scenes/environments/props/ConcreteBarrierA.scn")
	var police_car_scene = load("res://scenes/environments/props/PoliceCarProp.scn")
	
	for z_mile in [-160.0, -420.0, -780.0, -1140.0]:
		if sign_scene:
			var s = sign_scene.instantiate()
			s.position = Vector3(0.0, 0.0, z_mile)
			s.rotation_degrees = Vector3(0, 180, 0)
			infra_parent.add_child(s)
			
		if police_car_scene:
			var pc = police_car_scene.instantiate()
			pc.position = Vector3(8.5, 0.0, z_mile + randf_range(15.0, 25.0))
			pc.rotation_degrees = Vector3(0, randf_range(-35.0, 35.0), 0)
			infra_parent.add_child(pc)
			
		if barrier_scene:
			for bx in [-6.5, -4.5]:
				var bar = barrier_scene.instantiate()
				bar.position = Vector3(bx, 0.0, z_mile + randf_range(-10.0, 10.0))
				infra_parent.add_child(bar)
	print("[ZOMBIE HIGHWAY] Built high-speed reflector posts, road barriers, and highway signs!")

func _spawn_initial_highway_horde():
	# Spawn initial spread along the highway from Z = -35 to Z = -280
	for z_dist in [35.0, 65.0, 105.0, 150.0, 200.0, 260.0]:
		_spawn_highway_cluster(-z_dist)
		if randf() < 0.6:
			_spawn_highway_barrel(-z_dist + randf_range(-8.0, 8.0))

func _spawn_highway_barrel(center_z: float):
	if active_barrels.size() >= max_active_barrels or not barrel_scene:
		return
	var lanes = [-4.0, -1.8, 1.8, 4.0]
	var lane_x = lanes[randi() % lanes.size()]
	var barrel = barrel_scene.instantiate()
	barrel.name = "HighwayBarrel_%d" % randi()
	barrel.position = Vector3(lane_x, 0.55, center_z)
	add_child(barrel)
	active_barrels.append(barrel)

func _get_dune_y(x: float, z: float) -> float:
	var dist_from_road = abs(x) - 7.5
	if dist_from_road <= 0.0:
		return 0.0
	var blend = clampf(dist_from_road / 4.5, 0.0, 1.0)
	var dune_primary = sin(z * 0.018 + x * 0.04) * 2.2
	var dune_secondary = cos(z * 0.045 + x * 0.12) * 1.1
	var micro_ripple = sin(z * 0.15 + x * 0.25) * 0.35
	var dune_y = (dune_primary + dune_secondary + micro_ripple + 0.8) * blend
	return maxf(dune_y, 0.0)

func _spawn_highway_cluster(center_z: float):
	if active_zombies.size() >= max_active_zombies:
		return
		
	var archetypes = ["normal", "fast", "realistic", "heavy"]
	# Road lanes and desert sand dunes lanes
	var lanes = [-13.0, -9.0, -5.0, -2.5, 0.0, 2.5, 5.0, 9.0, 13.0]
	lanes.shuffle()
	
	var count = randi_range(3, 5)
	for i in range(count):
		if active_zombies.size() >= max_active_zombies:
			break
		var lane_x = lanes[i % lanes.size()] + randf_range(-0.4, 0.4)
		var spawn_z = center_z + randf_range(-5.0, 5.0)
		var arch = archetypes[randi() % archetypes.size()]
		var spawn_y = _get_dune_y(lane_x, spawn_z) + 0.05
		
		var z_inst = zombie_scene.instantiate()
		z_inst.name = "HighwayZombie_%d" % randi()
		z_inst.set("archetype", arch)
		z_inst.position = Vector3(lane_x, spawn_y, spawn_z)
		# Face towards incoming car (+Z)
		z_inst.rotation_degrees = Vector3(0, 0, 0)
		add_child(z_inst)
		active_zombies.append(z_inst)
		
		if z_inst.has_signal("died"):
			z_inst.died.connect(_on_zombie_died.bind(z_inst))

func _process(delta: float):
	# Streak timer
	if roadkill_streak > 0:
		streak_timer -= delta
		if streak_timer <= 0.0:
			roadkill_streak = 0
			if streak_label:
				streak_label.text = "SPEED DOWN THE HIGHWAY & RUN OVER ZOMBIES!"
				streak_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))

	# Clean dead or despawned zombies from active list
	for i in range(active_zombies.size() - 1, -1, -1):
		var z = active_zombies[i]
		if not is_instance_valid(z) or z.is_dead:
			active_zombies.remove_at(i)
			continue
		
		# If zombie is far behind the car (>25m behind), respawn it ahead of car
		if car and is_instance_valid(car):
			var dist_behind = z.global_position.z - car.global_position.z
			if dist_behind > 25.0:
				z.queue_free()
				active_zombies.remove_at(i)

	# Clean passed barrels
	for i in range(active_barrels.size() - 1, -1, -1):
		var b = active_barrels[i]
		if not is_instance_valid(b) or ("is_exploded" in b and b.is_exploded):
			active_barrels.remove_at(i)
			continue
		if car and is_instance_valid(car):
			if b.global_position.z - car.global_position.z > 30.0:
				b.queue_free()
				active_barrels.remove_at(i)

	# Dynamic Spawner ahead of car
	if car and is_instance_valid(car):
		var car_z = car.global_position.z
		# Maintain zombies 30m to 85m ahead of car
		if active_zombies.size() < max_active_zombies:
			var target_z = car_z - randf_range(35.0, 80.0)
			if target_z > -1480.0:
				_spawn_highway_cluster(target_z)
				
		# Maintain explosive fuel barrels
		if active_barrels.size() < max_active_barrels:
			var target_bz = car_z - randf_range(45.0, 95.0)
			if target_bz > -1480.0 and randf() < 0.4:
				_spawn_highway_barrel(target_bz)

		# Endless Highway Loop Safeguard: If car reaches end of 1.5 KM highway, wrap seamlessly
		if car_z < -1480.0:
			car.global_position = Vector3(car.global_position.x, 0.4, 0.0)
			print("[ZOMBIE HIGHWAY] Reached end of 1.5 KM highway! Looping back to start for endless crushing!")
			_spawn_initial_highway_horde()

		# Vehicle Fall Rescue Safeguard:
		if car.global_position.y < -1.8:
			car.linear_velocity = Vector3.ZERO
			car.angular_velocity = Vector3.ZERO
			car.global_position = Vector3(clampf(car.global_position.x, -5.0, 5.0), 0.5, car.global_position.z)
			car.rotation_degrees = Vector3(0, 0, 0)
			print("[ZOMBIE HIGHWAY] Vehicle rescued back onto highway!")

func _on_zombie_died(_z: Node3D):
	pass

func _show_combo_popup(text: String, col: Color):
	if not combo_popup_label:
		return
	combo_popup_label.text = text
	combo_popup_label.add_theme_color_override("font_color", col)
	combo_popup_label.scale = Vector2(1.3, 1.3)
	combo_popup_label.pivot_offset = combo_popup_label.size * 0.5
	
	var tw = create_tween()
	tw.tween_property(combo_popup_label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(combo_popup_label, "modulate:a", 1.0, 0.1)
	tw.tween_interval(0.6)
	tw.tween_property(combo_popup_label, "modulate:a", 0.0, 0.35)

func _on_zombie_roadkilled(_target: Node, speed_kmh: float):
	roadkill_count += 1
	roadkill_streak += 1
	streak_timer = 4.0
	
	# Windshield Blood Splatter Flash (Full Screen Vignette)
	if blood_overlay:
		var blood_alpha = clampf(speed_kmh / 120.0, 0.35, 0.75)
		blood_overlay.color = Color(0.75, 0.02, 0.02, blood_alpha)
		var blood_tw = create_tween()
		blood_tw.tween_property(blood_overlay, "color:a", 0.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Immediately disable corpse collisions so multiple roadkilled bodies don't cause physics drag
	if _target and is_instance_valid(_target):
		for col in _target.find_children("*", "CollisionShape3D", true, false):
			col.set_deferred("disabled", true)
		var tw = _target.create_tween()
		tw.tween_interval(1.2)
		tw.tween_callback(_target.queue_free)
	
	if roadkill_label:
		roadkill_label.text = "💀 ZOMBIES CRUSHED: %d" % roadkill_count
		
	var streak_text = "ROADKILL!"
	var text_color = Color(1.0, 0.4, 0.4)
	if roadkill_streak >= 5:
		streak_text = "⚡ MASSACRE x%d! (+%d KM/H)" % [roadkill_streak, int(speed_kmh)]
		text_color = Color(1.0, 0.1, 0.1)
		_show_combo_popup("⚡ MASSACRE x%d!\n+$750" % roadkill_streak, Color(1.0, 0.2, 0.2))
	elif roadkill_streak >= 3:
		streak_text = "🔥 CRUSH SPREE x%d!" % roadkill_streak
		text_color = Color(1.0, 0.6, 0.1)
		_show_combo_popup("🔥 SPREE x%d!\n+$450" % roadkill_streak, Color(1.0, 0.6, 0.1))
	elif roadkill_streak >= 2:
		streak_text = "💥 DOUBLE ROADKILL!"
		text_color = Color(1.0, 0.9, 0.2)
		_show_combo_popup("💥 DOUBLE CRUSH!\n+$300", Color(1.0, 0.9, 0.2))
	else:
		streak_text = "💀 ROADKILL! (+%d KM/H)" % int(speed_kmh)
		_show_combo_popup("💀 ROADKILL!\n+$150", Color(0.9, 1.0, 0.3))
		
	if streak_label:
		streak_label.text = streak_text
		streak_label.add_theme_color_override("font_color", text_color)

	# Camera screen shake proportional to speed
	if car and is_instance_valid(car):
		var cam = car.get_node_or_null("ChaseCamera") as Camera3D
		if cam:
			var shake_amount = clampf(speed_kmh / 250.0, 0.12, 0.30)
			cam.h_offset = randf_range(-shake_amount, shake_amount)
			cam.v_offset = randf_range(-shake_amount * 0.7, shake_amount * 0.7)
			var tw = create_tween()
			tw.tween_property(cam, "h_offset", 0.0, 0.18)
			tw.parallel().tween_property(cam, "v_offset", 0.0, 0.18)

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit(0)
		elif event.keycode == KEY_R:
			if car and is_instance_valid(car):
				car.rotation_degrees = Vector3(0, car.rotation_degrees.y, 0)
				car.global_position.y += 1.0
				car.linear_velocity = Vector3.ZERO
				car.angular_velocity = Vector3.ZERO
				print("[ZOMBIE HIGHWAY] Vehicle flipped upright with [R] key!")
