class_name WeatherController
extends Node3D

## Dynamic Atmospheric Weather & Lighting Controller
## Designed for GTA 5 open-world style atmospheric presets on Godot 4.
## Optimized for low-end hardware (AMD Kabini APU, gl_compatibility renderer, 45 FPS lock).

enum WeatherPreset {
	SUNNY_DAY,
	GOLDEN_SUNSET,
	CYBERPUNK_NIGHT,
	STORMY_RAIN
}

signal weather_changed(new_preset: WeatherPreset, preset_name: String)

@export_group("Weather Settings")
@export var current_preset: WeatherPreset = WeatherPreset.SUNNY_DAY
@export var transition_duration: float = 1.5
@export var enable_keyboard_switcher: bool = true
@export var cycle_key: Key = KEY_T
@export var badge_display_duration: float = 3.0

@export_group("Scene Node Bindings")
@export var directional_light: DirectionalLight3D
@export var world_environment: WorldEnvironment
@export var street_lamps_container: Node3D
@export var target_camera_or_player: Node3D
@export var rain_emitter: CPUParticles3D
@export var road_materials: Array[StandardMaterial3D] = []
@export var auto_discover_nodes: bool = true

@export_group("Rain Emitter Configuration")
@export var rain_particles_amount: int = 1200
@export var rain_box_size: Vector3 = Vector3(40.0, 4.0, 40.0) # 40x40m around player
@export var rain_height_offset: float = 14.0

@export_group("Sky Configuration")
@export var manage_procedural_sky: bool = true

# Internal runtime state
var _active_weather_tween: Tween = null
var _active_badge_tween: Tween = null
var _environment: Environment = null
var _cached_street_lights: Array[Light3D] = []
var _cached_road_materials: Array[StandardMaterial3D] = []
var _original_road_roughness: Dictionary = {} # Material -> float

# UI Badge Nodes
var _badge_layer: CanvasLayer = null
var _badge_panel: PanelContainer = null
var _badge_icon_label: Label = null
var _badge_title_label: Label = null
var _badge_subtitle_label: Label = null
var _badge_stylebox: StyleBoxFlat = null

# Preset definitions dictionary
const PRESETS = {
	WeatherPreset.SUNNY_DAY: {
		"name": "SUNNY DAY",
		"icon": "☀️",
		"subtitle": "Warm Daylight • Clear Visibility • 45° Altitude",
		"badge_accent": Color(1.0, 0.85, 0.25, 1.0),
		# DirectionalLight3D: bright warm sunlight, balanced natural energy
		"sun_color": Color(1.0, 0.96, 0.88, 1.0),
		"sun_energy": 1.15,
		"sun_rotation": Vector3(-45.0, -35.0, 0.0),
		# Environment Fog: crystal clear alpine daylight (zero washed-out haze)
		"fog_enabled": true,
		"fog_density": 0.00010,
		"fog_light_color": Color(0.78, 0.85, 0.92, 1.0),
		"fog_aerial_perspective": 0.0,
		"ambient_energy": 0.85,
		"ambient_color": Color(0.85, 0.90, 0.96, 1.0),
		# Sky
		"sky_top_color": Color(0.28, 0.52, 0.85, 1.0),
		"sky_horizon_color": Color(0.70, 0.80, 0.92, 1.0),
		"ground_bottom_color": Color(0.20, 0.22, 0.25, 1.0),
		"ground_horizon_color": Color(0.55, 0.65, 0.75, 1.0),
		"sky_energy_multiplier": 1.0,
		# Rain: OFF
		"rain_active": false,
		# Streetlamps: OFF
		"street_lamp_energy": 0.0,
		"street_lamp_color": Color(1.0, 0.90, 0.72, 1.0),
		# Road: matte realistic dry asphalt (no glitter/sparkles)
		"road_roughness": 0.85,
		"road_specular": 0.12,
		"road_metallic": 0.0,
		"glow_bloom": 0.0
	},
	WeatherPreset.GOLDEN_SUNSET: {
		"name": "GOLDEN SUNSET",
		"icon": "🌇",
		"subtitle": "Amber Dusk • Long Dramatic Shadows • Low Sun Angle",
		"badge_accent": Color(1.0, 0.55, 0.18, 1.0),
		# DirectionalLight3D: deep amber-orange glow, energy = 1.48, low sun angle
		"sun_color": Color(1.0, 0.66, 0.35, 1.0),
		"sun_energy": 1.48,
		"sun_rotation": Vector3(-16.0, -78.0, 0.0),
		# Environment Fog: amber dusk mist, clear mountain ridges
		"fog_enabled": true,
		"fog_density": 0.0008,
		"fog_light_color": Color(1.0, 0.55, 0.22, 1.0),
		"fog_aerial_perspective": 0.20,
		"ambient_energy": 0.90,
		"ambient_color": Color(0.85, 0.55, 0.35, 1.0),
		# Sky
		"sky_top_color": Color(0.32, 0.20, 0.45, 1.0),
		"sky_horizon_color": Color(0.98, 0.52, 0.18, 1.0),
		"ground_bottom_color": Color(0.18, 0.12, 0.14, 1.0),
		"ground_horizon_color": Color(0.55, 0.32, 0.20, 1.0),
		"sky_energy_multiplier": 1.35,
		# Rain: OFF
		"rain_active": false,
		# Streetlamps: dusk warm glow starting to power up
		"street_lamp_energy": 0.45,
		"street_lamp_color": Color(1.0, 0.82, 0.55, 1.0),
		# Road: dry asphalt
		"road_roughness": 0.44,
		"road_specular": 0.60,
		"road_metallic": 0.03,
		"glow_bloom": 0.20
	},
	WeatherPreset.CYBERPUNK_NIGHT: {
		"name": "CYBERPUNK NIGHT",
		"icon": "🌙",
		"subtitle": "Cool Moonlight • Highway Streetlamps Active • Clear Night",
		"badge_accent": Color(0.2, 0.85, 1.0, 1.0),
		# DirectionalLight3D: cool moonlight, energy = 0.25
		"sun_color": Color(0.2, 0.25, 0.45, 1.0),
		"sun_energy": 0.25,
		"sun_rotation": Vector3(-60.0, 45.0, 0.0),
		# Environment Fog: dark navy night mist, clear mountain skyline
		"fog_enabled": true,
		"fog_density": 0.0006,
		"fog_light_color": Color(0.08, 0.12, 0.22, 1.0),
		"fog_aerial_perspective": 0.15,
		"ambient_energy": 0.35,
		"ambient_color": Color(0.15, 0.20, 0.35, 1.0),
		# Sky
		"sky_top_color": Color(0.04, 0.05, 0.10, 1.0),
		"sky_horizon_color": Color(0.10, 0.14, 0.25, 1.0),
		"ground_bottom_color": Color(0.02, 0.03, 0.05, 1.0),
		"ground_horizon_color": Color(0.06, 0.08, 0.14, 1.0),
		"sky_energy_multiplier": 0.38,
		# Rain: OFF
		"rain_active": false,
		# Streetlamps: turn on / boost emissive glow
		"street_lamp_energy": 2.6,
		"street_lamp_color": Color(1.0, 0.88, 0.65, 1.0),
		# Road: dry asphalt
		"road_roughness": 0.44,
		"road_specular": 0.60,
		"road_metallic": 0.03,
		"glow_bloom": 0.25
	},
	WeatherPreset.STORMY_RAIN: {
		"name": "STORMY RAIN",
		"icon": "⛈",
		"subtitle": "Heavy Downpour • Wet Reflective Roads • Dramatic Clouds",
		"badge_accent": Color(0.55, 0.75, 0.95, 1.0),
		# DirectionalLight3D: overcast cool gray, energy = 0.5
		"sun_color": Color(0.5, 0.55, 0.6, 1.0),
		"sun_energy": 0.5,
		"sun_rotation": Vector3(-70.0, 15.0, 0.0),
		# Environment Fog: storm atmosphere, mountain silhouettes visible
		"fog_enabled": true,
		"fog_density": 0.0018,
		"fog_light_color": Color(0.35, 0.38, 0.44, 1.0),
		"fog_aerial_perspective": 0.30,
		"ambient_energy": 0.60,
		"ambient_color": Color(0.40, 0.45, 0.52, 1.0),
		# Sky
		"sky_top_color": Color(0.22, 0.25, 0.28, 1.0),
		"sky_horizon_color": Color(0.38, 0.42, 0.46, 1.0),
		"ground_bottom_color": Color(0.12, 0.14, 0.16, 1.0),
		"ground_horizon_color": Color(0.25, 0.28, 0.30, 1.0),
		"sky_energy_multiplier": 0.60,
		# Rain: ON!
		"rain_active": true,
		# Streetlamps: ON (pierce through the rain & mist)
		"street_lamp_energy": 1.6,
		"street_lamp_color": Color(1.0, 0.92, 0.75, 1.0),
		# Road: lowered roughness, high specular shine
		"road_roughness": 0.18,
		"road_specular": 0.85,
		"road_metallic": 0.05,
		"glow_bloom": 0.15
	}
}

func _ready() -> void:
	if auto_discover_nodes:
		_auto_discover_scene_elements()
	
	_setup_environment()
	_setup_rain_emitter()
	_setup_road_materials()
	_build_gta_ui_badge()
	
	# Apply initial preset instantly without tween
	apply_weather_preset(current_preset, 0.0, false)

func _process(_delta: float) -> void:
	if not is_inside_tree():
		return
	# Keep rain emitter centered over active camera or player
	if rain_emitter and is_instance_valid(rain_emitter) and rain_emitter.is_inside_tree():
		var target_pos = _get_target_position()
		rain_emitter.global_position = Vector3(
			target_pos.x,
			target_pos.y + rain_height_offset,
			target_pos.z
		)

func _unhandled_input(event: InputEvent) -> void:
	if not enable_keyboard_switcher:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == cycle_key or event.physical_keycode == cycle_key:
			cycle_weather()

## Cycles sequentially through the 4 presets in real-time
func cycle_weather() -> void:
	var next_preset = (int(current_preset) + 1) % 4 as WeatherPreset
	apply_weather_preset(next_preset, transition_duration, true)

## Applies a preset smoothly over the specified duration (default 1.5s)
func apply_weather_preset(preset: WeatherPreset, duration: float = 1.5, show_badge: bool = true) -> void:
	current_preset = preset
	var cfg = PRESETS.get(preset, PRESETS[WeatherPreset.SUNNY_DAY])
	
	print("[WEATHER] Switching to: %s (Duration: %.1fs)" % [cfg.name, duration])
	
	if show_badge:
		_show_gta_badge(cfg)
	
	# Kill any existing tween to avoid conflicts during rapid cycling
	if _active_weather_tween and _active_weather_tween.is_valid():
		_active_weather_tween.kill()
	
	if duration <= 0.0:
		_apply_preset_instant(cfg)
	else:
		_apply_preset_tweened(cfg, duration)
	
	weather_changed.emit(preset, cfg.name)

func _apply_preset_instant(cfg: Dictionary) -> void:
	# Directional Light
	if directional_light and is_instance_valid(directional_light):
		directional_light.light_color = cfg.sun_color
		directional_light.light_energy = cfg.sun_energy
		directional_light.rotation_degrees = cfg.sun_rotation
		directional_light.shadow_enabled = true
		directional_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		directional_light.directional_shadow_max_distance = 45.0
		directional_light.directional_shadow_blend_splits = false
	
	# World Environment Fog & Ambient
	if _environment and is_instance_valid(_environment):
		_environment.fog_enabled = cfg.fog_enabled
		_environment.fog_mode = Environment.FOG_MODE_EXPONENTIAL
		_environment.fog_density = cfg.fog_density
		_environment.fog_light_color = cfg.fog_light_color
		_environment.fog_aerial_perspective = cfg.fog_aerial_perspective
		_environment.ambient_light_energy = cfg.ambient_energy
		_environment.ambient_light_color = cfg.ambient_color
		_environment.glow_bloom = cfg.get("glow_bloom", 0.0)
		
		_apply_sky_instant(cfg)
	
	# Rain
	if rain_emitter and is_instance_valid(rain_emitter):
		if rain_emitter.is_inside_tree():
			rain_emitter.emitting = cfg.rain_active
	
	# Streetlamps
	for lamp in _cached_street_lights:
		if is_instance_valid(lamp):
			lamp.light_energy = cfg.street_lamp_energy
			lamp.light_color = cfg.street_lamp_color
			lamp.visible = (cfg.street_lamp_energy > 0.05)
	
	# Road Materials
	for mat in _cached_road_materials:
		if is_instance_valid(mat):
			mat.roughness = cfg.road_roughness
			mat.metallic_specular = cfg.road_specular
			mat.metallic = cfg.road_metallic

func _apply_preset_tweened(cfg: Dictionary, duration: float) -> void:
	_active_weather_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 1. Directional Light
	if directional_light and is_instance_valid(directional_light):
		_active_weather_tween.tween_property(directional_light, "light_color", cfg.sun_color, duration)
		_active_weather_tween.tween_property(directional_light, "light_energy", cfg.sun_energy, duration)
		_active_weather_tween.tween_property(directional_light, "rotation_degrees", cfg.sun_rotation, duration)
	
	# 2. Environment Fog & Ambient
	if _environment and is_instance_valid(_environment):
		_environment.fog_enabled = cfg.fog_enabled
		_environment.fog_mode = Environment.FOG_MODE_EXPONENTIAL
		_active_weather_tween.tween_property(_environment, "fog_density", cfg.fog_density, duration)
		_active_weather_tween.tween_property(_environment, "fog_light_color", cfg.fog_light_color, duration)
		_active_weather_tween.tween_property(_environment, "fog_aerial_perspective", cfg.fog_aerial_perspective, duration)
		_active_weather_tween.tween_property(_environment, "ambient_light_energy", cfg.ambient_energy, duration)
		_active_weather_tween.tween_property(_environment, "ambient_light_color", cfg.ambient_color, duration)
		_active_weather_tween.tween_property(_environment, "glow_bloom", cfg.get("glow_bloom", 0.0), duration)
		
		# Sky tween
		if _environment.sky and _environment.sky.sky_material:
			var sky_mat = _environment.sky.sky_material
			if sky_mat is ProceduralSkyMaterial:
				_active_weather_tween.tween_property(sky_mat, "sky_top_color", cfg.sky_top_color, duration)
				_active_weather_tween.tween_property(sky_mat, "sky_horizon_color", cfg.sky_horizon_color, duration)
				_active_weather_tween.tween_property(sky_mat, "ground_bottom_color", cfg.ground_bottom_color, duration)
				_active_weather_tween.tween_property(sky_mat, "ground_horizon_color", cfg.ground_horizon_color, duration)
			elif sky_mat is PanoramaSkyMaterial:
				_active_weather_tween.tween_property(sky_mat, "energy_multiplier", cfg.sky_energy_multiplier, duration)
	
	# 3. Rain Emitter
	if rain_emitter and is_instance_valid(rain_emitter):
		if rain_emitter.is_inside_tree():
			if cfg.rain_active:
				rain_emitter.emitting = true
			else:
				# Stop emitting, allowing raindrops in air to finish falling
				rain_emitter.emitting = false
	
	# 4. Streetlamps
	var lamps_active = cfg.street_lamp_energy > 0.05
	for lamp in _cached_street_lights:
		if is_instance_valid(lamp):
			if lamps_active:
				lamp.visible = true
			_active_weather_tween.tween_property(lamp, "light_energy", cfg.street_lamp_energy, duration)
			_active_weather_tween.tween_property(lamp, "light_color", cfg.street_lamp_color, duration)
			if not lamps_active:
				_active_weather_tween.tween_callback(func(): if is_instance_valid(lamp): lamp.visible = false)
	
	# 5. Road Materials (Wetness / Specular shine)
	for mat in _cached_road_materials:
		if is_instance_valid(mat):
			_active_weather_tween.tween_property(mat, "roughness", cfg.road_roughness, duration)
			_active_weather_tween.tween_property(mat, "metallic_specular", cfg.road_specular, duration)
			_active_weather_tween.tween_property(mat, "metallic", cfg.road_metallic, duration)

func _apply_sky_instant(cfg: Dictionary) -> void:
	if not _environment.sky or not _environment.sky.sky_material:
		return
	var sky_mat = _environment.sky.sky_material
	if sky_mat is ProceduralSkyMaterial:
		sky_mat.sky_top_color = cfg.sky_top_color
		sky_mat.sky_horizon_color = cfg.sky_horizon_color
		sky_mat.ground_bottom_color = cfg.ground_bottom_color
		sky_mat.ground_horizon_color = cfg.ground_horizon_color
	elif sky_mat is PanoramaSkyMaterial:
		sky_mat.energy_multiplier = cfg.sky_energy_multiplier

# Auto-discovery of scene nodes
func _auto_discover_scene_elements() -> void:
	var root: Node = null
	if is_inside_tree() and get_tree():
		root = get_tree().current_scene
	if not root:
		root = get_parent() if get_parent() else self
	
	# 1. DirectionalLight3D
	if not directional_light:
		directional_light = _find_first_node_of_type(root, "DirectionalLight3D") as DirectionalLight3D
		if directional_light:
			print("[WEATHER] Discovered DirectionalLight3D: ", directional_light.name)
	
	# 2. WorldEnvironment
	if not world_environment:
		world_environment = _find_first_node_of_type(root, "WorldEnvironment") as WorldEnvironment
		if world_environment:
			print("[WEATHER] Discovered WorldEnvironment: ", world_environment.name)
	
	# 3. Streetlamps container
	if not street_lamps_container:
		street_lamps_container = root.find_child("StreetLamps", true, false)
		if not street_lamps_container:
			street_lamps_container = root.find_child("StreetLights", true, false)
	
	# Cache all street lamp lights
	_cached_street_lights.clear()
	if street_lamps_container:
		for child in street_lamps_container.find_children("*", "Light3D", true, false):
			if child is Light3D:
				_cached_street_lights.append(child)
	else:
		# Search anywhere in scene for street lights
		for node in root.find_children("StreetLight*", "Light3D", true, false):
			if node is Light3D:
				_cached_street_lights.append(node)
	
	print("[WEATHER] Cached %d streetlamp lights." % _cached_street_lights.size())

func _setup_environment() -> void:
	if world_environment and world_environment.environment:
		# Duplicate environment instance to prevent modifying disk resource during runtime
		_environment = world_environment.environment.duplicate()
		world_environment.environment = _environment
	elif not world_environment:
		world_environment = WorldEnvironment.new()
		world_environment.name = "DynamicWorldEnvironment"
		add_child(world_environment)
		_environment = Environment.new()
		world_environment.environment = _environment
	else:
		_environment = Environment.new()
		world_environment.environment = _environment
	
	# Setup ProceduralSky if configured or if no sky exists
	if manage_procedural_sky:
		if not _environment.sky:
			var sky = Sky.new()
			var sky_mat = ProceduralSkyMaterial.new()
			sky.sky_material = sky_mat
			_environment.sky = sky
			_environment.background_mode = Environment.BG_SKY
		elif _environment.sky.sky_material is ProceduralSkyMaterial:
			# Already procedural, duplicate so it's local
			var sky = _environment.sky.duplicate()
			sky.sky_material = _environment.sky.sky_material.duplicate()
			_environment.sky = sky

	# Pro Real AAA Cinematic Post-Processing (ACES Filmic Tonemapping & Subtle Bloom)
	_environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	_environment.tonemap_exposure = 1.14
	_environment.tonemap_white = 1.0
	_environment.glow_enabled = true
	_environment.glow_intensity = 0.50
	_environment.glow_bloom = 0.20
	_environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	_environment.glow_hdr_threshold = 0.95
	_environment.adjustment_enabled = true
	_environment.adjustment_contrast = 1.10
	_environment.adjustment_saturation = 1.16
	_environment.adjustment_brightness = 1.02

func _setup_rain_emitter() -> void:
	if not rain_emitter:
		rain_emitter = find_child("RainParticles", true, false) as CPUParticles3D
	
	if not rain_emitter:
		rain_emitter = CPUParticles3D.new()
		rain_emitter.name = "RainParticles"
		add_child(rain_emitter)
	
	# Configure particle emitter according to Kabini APU 45 FPS guidelines
	rain_emitter.emitting = false
	rain_emitter.amount = rain_particles_amount
	rain_emitter.lifetime = 0.85
	rain_emitter.preprocess = 0.4
	rain_emitter.speed_scale = 1.0
	
	# 40x40m box around player/camera (half extents = 20, 2, 20)
	rain_emitter.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain_emitter.emission_box_extents = Vector3(rain_box_size.x * 0.5, rain_box_size.y * 0.5, rain_box_size.z * 0.5)
	
	# Velocity and angle
	rain_emitter.direction = Vector3(0.08, -1.0, 0.04).normalized()
	rain_emitter.spread = 4.0
	rain_emitter.initial_velocity_min = 28.0
	rain_emitter.initial_velocity_max = 35.0
	rain_emitter.gravity = Vector3(0.0, -9.8, 0.0)
	
	# Lightweight unshaded BoxMesh for 100% reliable 3D rendering with 0 billboard overhead
	var rain_mat = StandardMaterial3D.new()
	rain_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rain_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	rain_mat.albedo_color = Color(0.75, 0.85, 0.98, 0.50)
	
	var rain_box = BoxMesh.new()
	rain_box.size = Vector3(0.025, 0.50, 0.025)
	rain_box.material = rain_mat
	rain_emitter.mesh = rain_box
	
	print("[WEATHER] CPUParticles3D Rain Emitter initialized (40x40m volume, %d particles)." % rain_particles_amount)

func _setup_road_materials() -> void:
	_cached_road_materials.clear()
	_original_road_roughness.clear()
	
	# 1. Add explicitly assigned materials
	for mat in road_materials:
		if mat and not mat in _cached_road_materials:
			_cached_road_materials.append(mat)
	
	# 2. Auto-discover road materials in scene
	var root: Node = null
	if is_inside_tree() and get_tree():
		root = get_tree().current_scene
	if not root:
		root = get_parent() if get_parent() else self
	
	var meshes = root.find_children("*", "MeshInstance3D", true, false)
	for mesh in meshes:
		var mi = mesh as MeshInstance3D
		var m_name = mi.name.to_lower()
		var is_road = "road" in m_name or "asphalt" in m_name or "highway" in m_name or "street" in m_name
		
		# Inspect material override
		if mi.material_override and mi.material_override is StandardMaterial3D:
			var mat = mi.material_override as StandardMaterial3D
			if is_road or "asphalt" in mat.resource_name.to_lower() or "road" in mat.resource_name.to_lower():
				if not mat in _cached_road_materials:
					# Duplicate locally so we don't modify disk resource
					var local_mat = mat.duplicate()
					mi.material_override = local_mat
					_cached_road_materials.append(local_mat)
		
		# Inspect surface overrides
		for s in range(mi.get_surface_override_material_count()):
			var smat = mi.get_surface_override_material(s)
			if smat and smat is StandardMaterial3D:
				var std_mat = smat as StandardMaterial3D
				if is_road or "asphalt" in std_mat.resource_name.to_lower() or "road" in std_mat.resource_name.to_lower():
					if not std_mat in _cached_road_materials:
						var local_mat = std_mat.duplicate()
						mi.set_surface_override_material(s, local_mat)
						_cached_road_materials.append(local_mat)
	
	for mat in _cached_road_materials:
		_original_road_roughness[mat] = mat.roughness
	
	print("[WEATHER] Cached %d road materials for dynamic wetness & specular reflections." % _cached_road_materials.size())

func _get_target_position() -> Vector3:
	if target_camera_or_player and is_instance_valid(target_camera_or_player):
		return target_camera_or_player.global_position if target_camera_or_player.is_inside_tree() else target_camera_or_player.position
	
	if is_inside_tree() and get_viewport():
		var cam = get_viewport().get_camera_3d()
		if cam and is_instance_valid(cam):
			return cam.global_position
	
	if is_inside_tree() and get_tree():
		var player = get_tree().get_first_node_in_group("player")
		if player and is_instance_valid(player) and player is Node3D:
			return (player as Node3D).global_position
	
	return global_position if is_inside_tree() else position

func _find_first_node_of_type(node: Node, type_str: String) -> Node:
	if node.is_class(type_str):
		return node
	for child in node.get_children():
		var found = _find_first_node_of_type(child, type_str)
		if found:
			return found
	return null

## Build GTA 5 style on-screen notification badge
func _build_gta_ui_badge() -> void:
	_badge_layer = CanvasLayer.new()
	_badge_layer.name = "WeatherBadgeCanvas"
	_badge_layer.layer = 105
	add_child(_badge_layer)
	
	# Root Anchor Control
	var root_ctrl = Control.new()
	root_ctrl.name = "BadgeContainer"
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_layer.add_child(root_ctrl)
	
	# Center Top Positioner
	var center_box = CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center_box.offset_top = 28.0
	center_box.offset_bottom = 100.0
	center_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(center_box)
	
	# Sleek GTA Notification Panel
	_badge_panel = PanelContainer.new()
	_badge_panel.name = "GTAWeatherPanel"
	_badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_panel.visible = false
	
	_badge_stylebox = StyleBoxFlat.new()
	_badge_stylebox.bg_color = Color(0.04, 0.05, 0.07, 0.88)
	_badge_stylebox.corner_radius_top_left = 6
	_badge_stylebox.corner_radius_top_right = 6
	_badge_stylebox.corner_radius_bottom_left = 6
	_badge_stylebox.corner_radius_bottom_right = 6
	_badge_stylebox.border_width_left = 6 # GTA accent stripe
	_badge_stylebox.border_color = Color(1.0, 0.85, 0.25, 1.0)
	_badge_stylebox.content_margin_left = 18.0
	_badge_stylebox.content_margin_right = 26.0
	_badge_stylebox.content_margin_top = 10.0
	_badge_stylebox.content_margin_bottom = 10.0
	_badge_stylebox.shadow_color = Color(0, 0, 0, 0.55)
	_badge_stylebox.shadow_size = 8
	_badge_stylebox.shadow_offset = Vector2(0, 3)
	
	_badge_panel.add_theme_stylebox_override("panel", _badge_stylebox)
	center_box.add_child(_badge_panel)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge_panel.add_child(hbox)
	
	# Weather Icon
	_badge_icon_label = Label.new()
	_badge_icon_label.text = "☀️"
	_badge_icon_label.add_theme_font_size_override("font_size", 26)
	_badge_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(_badge_icon_label)
	
	# Text Box
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(vbox)
	
	_badge_title_label = Label.new()
	_badge_title_label.text = "WEATHER: SUNNY DAY"
	_badge_title_label.add_theme_font_size_override("font_size", 16)
	_badge_title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	vbox.add_child(_badge_title_label)
	
	_badge_subtitle_label = Label.new()
	_badge_subtitle_label.text = "Warm Daylight • Clear Visibility • [T] Cycle"
	_badge_subtitle_label.add_theme_font_size_override("font_size", 11)
	_badge_subtitle_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.88, 0.85))
	vbox.add_child(_badge_subtitle_label)

	# Mobile On-Screen Touch Weather Button
	var mob_btn = Button.new()
	mob_btn.name = "MobileWeatherBtn"
	mob_btn.text = "⛅ WEATHER [T]"
	mob_btn.position = Vector2(25, 140)
	mob_btn.custom_minimum_size = Vector2(145, 44)
	mob_btn.pressed.connect(cycle_weather)
	root_ctrl.add_child(mob_btn)

## Triggers the 3-second GTA badge animation
func _show_gta_badge(cfg: Dictionary) -> void:
	if not _badge_panel or not is_instance_valid(_badge_panel):
		return
	
	_badge_title_label.text = "WEATHER: " + cfg.name
	_badge_subtitle_label.text = cfg.subtitle + " • [T] Cycle"
	_badge_icon_label.text = cfg.icon
	_badge_stylebox.border_color = cfg.badge_accent
	
	if _active_badge_tween and _active_badge_tween.is_valid():
		_active_badge_tween.kill()
	
	_badge_panel.visible = true
	_badge_panel.modulate.a = 0.0
	_badge_panel.scale = Vector2(0.95, 0.95)
	_badge_panel.pivot_offset = _badge_panel.size * 0.5
	
	_active_badge_tween = create_tween()
	
	# 1. Slide & Fade in (0.2s)
	_active_badge_tween.set_parallel(true)
	_active_badge_tween.tween_property(_badge_panel, "modulate:a", 1.0, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_badge_tween.tween_property(_badge_panel, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 2. Hold for exactly badge_display_duration (3.0s)
	_active_badge_tween.set_parallel(false)
	_active_badge_tween.tween_interval(badge_display_duration)
	
	# 3. Fade out (0.4s)
	_active_badge_tween.set_parallel(true)
	_active_badge_tween.tween_property(_badge_panel, "modulate:a", 0.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_badge_tween.tween_property(_badge_panel, "scale", Vector2(0.95, 0.95), 0.40)
	
	# 4. Hide when complete
	_active_badge_tween.set_parallel(false)
	_active_badge_tween.tween_callback(func():
		if is_instance_valid(_badge_panel):
			_badge_panel.visible = false
	)
