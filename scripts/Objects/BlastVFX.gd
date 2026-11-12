extends RefCounted

static func spawn(parent: Node3D, world_position: Vector3, radius: float, tint: Color):
	if not is_instance_valid(parent) or not parent.is_inside_tree():
		return

	var fx_root := Node3D.new()
	fx_root.name = "BlastBurst"
	parent.add_child(fx_root)
	fx_root.global_position = world_position

	var wave_material := StandardMaterial3D.new()
	wave_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wave_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wave_material.albedo_color = tint
	wave_material.emission_enabled = true
	wave_material.emission = tint
	wave_material.emission_energy_multiplier = 1.4

	var wave_mesh := TorusMesh.new()
	wave_mesh.inner_radius = 0.76
	wave_mesh.outer_radius = 1.0
	wave_mesh.rings = 8
	wave_mesh.ring_segments = 24
	wave_mesh.material = wave_material

	var wave := MeshInstance3D.new()
	wave.name = "ShockwaveRing"
	wave.mesh = wave_mesh
	wave.position.y = 0.07
	wave.scale = Vector3(0.22, 0.045, 0.22)
	fx_root.add_child(wave)

	var spark_material := StandardMaterial3D.new()
	spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spark_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	spark_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.92)
	var spark_mesh := QuadMesh.new()
	spark_mesh.size = Vector2(0.12, 0.12)
	spark_mesh.material = spark_material

	var particles := GPUParticles3D.new()
	particles.name = "BlastSparks"
	particles.amount = 20
	particles.lifetime = 0.48
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.draw_pass_1 = spark_mesh
	var process_material := ParticleProcessMaterial.new()
	process_material.direction = Vector3.UP
	process_material.spread = 180.0
	process_material.initial_velocity_min = 3.5
	process_material.initial_velocity_max = 8.5
	process_material.gravity = Vector3(0.0, -5.5, 0.0)
	process_material.scale_min = 0.45
	process_material.scale_max = 1.15
	particles.process_material = process_material
	particles.position.y = 0.5
	fx_root.add_child(particles)
	particles.restart()

	var flash := OmniLight3D.new()
	flash.name = "BlastFlash"
	flash.light_color = tint
	flash.light_energy = 7.0
	flash.omni_range = maxf(8.0, radius * 1.8)
	flash.shadow_enabled = false
	flash.position.y = 0.65
	fx_root.add_child(flash)

	var tween := fx_root.create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave, "scale", Vector3(radius, 0.07, radius), 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(wave_material, "albedo_color:a", 0.0, 0.38)
	tween.tween_property(flash, "light_energy", 0.0, 0.28).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_interval(0.5)
	tween.tween_callback(fx_root.queue_free)
