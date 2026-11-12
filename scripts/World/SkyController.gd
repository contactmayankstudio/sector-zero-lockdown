# SkyController.gd
# AGENT 5: REALISTIC GTA V-STYLE SKY, SUNLIGHT, DAY/NIGHT & DYNAMIC WEATHER
# Manages seamless procedural sky, dynamic day/night cycles, rain storm effects, and night street lighting.
class_name SkyController
extends Node3D

const WorldMaterialManager = preload("res://scripts/World/WorldMaterialManager.gd")

@export var sun_light: DirectionalLight3D
@export var world_env: WorldEnvironment

enum TimeOfDay { DAY, GOLDEN_HOUR, NIGHT }
var current_time_mode: TimeOfDay = TimeOfDay.DAY

var is_raining: bool = false
var rain_emitter: CPUParticles3D = null

func _ready():
	_setup_lighting()
	_setup_rain_system()

func _setup_lighting():
	if not sun_light:
		sun_light = DirectionalLight3D.new()
		sun_light.name = "SunLight"
		add_child(sun_light)
		
	# GTA V Californian Sun settings
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun_light.directional_shadow_max_distance = 30.0 # Low-end 4GB APU optimization (28m-32m calibrated)
	sun_light.directional_shadow_blend_splits = false
	sun_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY
	
	if not world_env:
		world_env = WorldEnvironment.new()
		world_env.name = "WorldEnvironment"
		add_child(world_env)
		
	var env_res = load("res://resources/materials/env_gta5_clear_sky.tres")
	if env_res:
		world_env.environment = env_res
		
	apply_time_of_day(TimeOfDay.DAY)

func _setup_rain_system():
	rain_emitter = CPUParticles3D.new()
	rain_emitter.name = "RainEmitter"
	rain_emitter.amount = 320
	rain_emitter.lifetime = 1.2
	rain_emitter.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain_emitter.emission_box_extents = Vector3(25.0, 1.0, 25.0)
	rain_emitter.direction = Vector3(-0.15, -1.0, 0.05).normalized()
	rain_emitter.spread = 5.0
	rain_emitter.gravity = Vector3(0, -38.0, 0)
	rain_emitter.initial_velocity_min = 28.0
	rain_emitter.initial_velocity_max = 35.0
	rain_emitter.emitting = false
	
	var rmat = StandardMaterial3D.new()
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rmat.albedo_color = Color(0.75, 0.88, 1.0, 0.45)
	
	var rmesh = BoxMesh.new()
	rmesh.size = Vector3(0.02, 0.45, 0.02)
	rmesh.material = rmat
	rain_emitter.mesh = rmesh
	
	add_child(rain_emitter)

func toggle_weather():
	is_raining = not is_raining
	if not world_env or not world_env.environment:
		return
	var env = world_env.environment
	if is_raining:
		rain_emitter.emitting = true
		env.fog_density = 0.0028
		env.fog_light_color = Color(0.45, 0.52, 0.62)
		WorldMaterialManager.get_road_material().roughness = 0.22 # Wet shiny road puddles
		print("[WEATHER] Rainstorm ACTIVE! Wet road reflections enabled.")
	else:
		rain_emitter.emitting = false
		env.fog_density = 0.0008
		env.fog_light_color = Color(0.68, 0.80, 0.94)
		WorldMaterialManager.get_road_material().roughness = 0.90 # Dry asphalt
		print("[WEATHER] Clear weather restored.")

func apply_time_of_day(mode: TimeOfDay):
	current_time_mode = mode
	if not sun_light or not world_env or not world_env.environment:
		return
		
	var env = world_env.environment
	var sky_mat = env.sky.sky_material as ProceduralSkyMaterial if env.sky else null
	var lamp_mat = WorldMaterialManager.get_lamp_glow_material()
	
	match mode:
		TimeOfDay.DAY:
			# High bright Californian sun (Los Santos daylight)
			sun_light.rotation_degrees = Vector3(-52.0, 32.0, 0.0)
			sun_light.light_color = Color(1.0, 0.97, 0.91)
			sun_light.light_energy = 0.95
			env.ambient_light_energy = 0.40
			env.fog_light_color = Color(0.68, 0.80, 0.94)
			env.fog_density = 0.0008
			if sky_mat:
				sky_mat.sky_top_color = Color(0.24, 0.48, 0.88)
				sky_mat.sky_horizon_color = Color(0.68, 0.80, 0.94)
				sky_mat.ground_horizon_color = Color(0.68, 0.80, 0.94) # Zero horizon seam
				sky_mat.energy_multiplier = 1.0
			lamp_mat.emission_energy_multiplier = 0.0 # Streetlights OFF during day
			WorldMaterialManager.set_night_window_glow(false) # Windows unlit in daylight
				
		TimeOfDay.GOLDEN_HOUR:
			# Warm sunset over Vinewood hills
			sun_light.rotation_degrees = Vector3(-14.0, 68.0, 0.0)
			sun_light.light_color = Color(1.0, 0.65, 0.32)
			sun_light.light_energy = 1.40
			env.ambient_light_energy = 0.55
			env.fog_light_color = Color(0.85, 0.60, 0.42)
			env.fog_density = 0.0012
			if sky_mat:
				sky_mat.sky_top_color = Color(0.35, 0.28, 0.55)
				sky_mat.sky_horizon_color = Color(0.92, 0.52, 0.28)
				sky_mat.ground_horizon_color = Color(0.92, 0.52, 0.28)
				sky_mat.energy_multiplier = 1.15
			lamp_mat.emission_energy_multiplier = 1.2 # Streetlights starting to warm up
			WorldMaterialManager.set_night_window_glow(false, true) # Golden hour warm window sheen
				
		TimeOfDay.NIGHT:
			# Atmospheric night with cool moonlight
			sun_light.rotation_degrees = Vector3(-65.0, 140.0, 0.0)
			sun_light.light_color = Color(0.42, 0.52, 0.82)
			sun_light.light_energy = 0.30
			env.ambient_light_energy = 0.25
			env.fog_light_color = Color(0.12, 0.16, 0.28)
			env.fog_density = 0.0016
			if sky_mat:
				sky_mat.sky_top_color = Color(0.04, 0.06, 0.12)
				sky_mat.sky_horizon_color = Color(0.12, 0.18, 0.30)
				sky_mat.ground_horizon_color = Color(0.12, 0.18, 0.30)
				sky_mat.energy_multiplier = 0.40
			lamp_mat.emission_energy_multiplier = 3.5 # Streetlights glowing ON at night
			WorldMaterialManager.set_night_window_glow(true) # Warm glowing skyscraper and house windows at night

func cycle_time():
	var next = (int(current_time_mode) + 1) % 3
	apply_time_of_day(next as TimeOfDay)
	print("[SKY] Switched Time of Day to: ", TimeOfDay.keys()[next])

func _process(_delta):
	if is_raining and rain_emitter:
		# Follow current player or vehicle camera
		var vp = get_viewport()
		if vp:
			var cam = vp.get_camera_3d()
			if cam:
				rain_emitter.global_position = cam.global_position + Vector3(0.0, 14.0, 0.0)
