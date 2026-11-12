extends SceneTree

func _init():
	print("Testing CPUParticles3D creation in Godot 4.3...")
	var p = CPUParticles3D.new()
	p.amount = 25
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 0.7
	p.direction = Vector3(0, 0.2, 1).normalized()
	p.spread = 35.0
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 8.0
	p.gravity = Vector3(0, -9.8, 0)
	p.damping_min = 1.0
	p.damping_max = 2.0
	p.scale_amount_min = 0.06
	p.scale_amount_max = 0.18
	p.color = Color(0.6, 0.03, 0.03, 0.95)
	
	var q = QuadMesh.new()
	q.size = Vector2(0.12, 0.12)
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.albedo_color = Color(0.6, 0.03, 0.03, 0.95)
	q.material = mat
	p.mesh = q
	
	root.add_child(p)
	p.emitting = true
	print("CPUParticles3D created and emitting successfully! Class: ", p.get_class())
	p.queue_free()
	quit()
