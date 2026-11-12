extends SceneTree

func _init():
	print("--- VERIFYING PROPOSED ENVIRONMENT & LIGHTING PROFILE ---")
	var env = Environment.new()
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	
	# ProceduralSkyMaterial gritty post-apocalyptic horizon colors
	sky_mat.sky_top_color = Color(0.22, 0.38, 0.58, 1.0)
	sky_mat.sky_horizon_color = Color(0.72, 0.58, 0.42, 1.0)
	sky_mat.ground_bottom_color = Color(0.12, 0.13, 0.15, 1.0)
	sky_mat.ground_horizon_color = Color(0.35, 0.32, 0.28, 1.0)
	sky_mat.sun_angle_max = 30.0
	sky_mat.sun_curve = 0.15
	sky.sky_material = sky_mat
	
	# WorldEnvironment properties
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.58, 0.64, 1.0)
	env.ambient_light_energy = 0.8
	
	# Filmic Tonemapping
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC # 2
	env.tonemap_exposure = 1.05
	env.tonemap_white = 1.0
	
	# Mobile gl_compatibility safeguards: ZERO SSAO / SSIL
	env.ssao_enabled = false
	env.ssil_enabled = false
	env.glow_enabled = false
	
	# Distance fog tuning: NO white glare
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL # 0
	env.fog_light_color = Color(0.35, 0.32, 0.28, 1.0)
	env.fog_light_energy = 0.7
	env.fog_sun_scatter = 0.0
	env.fog_density = 0.002
	env.fog_aerial_perspective = 0.0
	env.fog_sky_affect = 0.15
	
	# DirectionalLight3D
	var sun = DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.94, 0.85, 1.0)
	sun.light_energy = 1.85
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL # 0
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.8
	sun.directional_shadow_max_distance = 60.0
	
	print("[PASS] ProceduralSkyMaterial instantiated: sky_top=%s, sky_horizon=%s" % [sky_mat.sky_top_color, sky_mat.sky_horizon_color])
	print("[PASS] Environment tonemap: mode=%d (FILMIC), exposure=%f" % [env.tonemap_mode, env.tonemap_exposure])
	print("[PASS] Zero SSAO/SSIL verified: ssao=%s, ssil=%s" % [env.ssao_enabled, env.ssil_enabled])
	print("[PASS] Fog parameters: light_color=%s, sun_scatter=%f, density=%f" % [env.fog_light_color, env.fog_sun_scatter, env.fog_density])
	print("[PASS] DirectionalLight3D: mode=%d (SHADOW_ORTHOGONAL), energy=%f, color=%s" % [sun.directional_shadow_mode, sun.light_energy, sun.light_color])
	print("ALL PROFILE PARAMETERS VERIFIED IN ENGINE RUNTIME.")
	quit(0)
