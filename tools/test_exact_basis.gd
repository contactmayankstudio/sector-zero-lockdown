extends SceneTree

func _init():
	var win = root
	var world_3d = World3D.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.12, 0.15, 0.18)
	world_3d.environment = env
	win.world_3d = world_3d
	
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_color = Color.WHITE
	sun.light_energy = 2.0
	win.add_child(sun)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0.0, 1.65, 0.0)
	cam.fov = 70.0
	cam.current = true
	win.add_child(cam)
	
	# Target Dummy 4m ahead
	var dummy = MeshInstance3D.new()
	var cap = CapsuleMesh.new()
	cap.radius = 0.25
	cap.height = 1.7
	dummy.mesh = cap
	dummy.position = Vector3(0, 1.65, -4.0)
	var dmat = StandardMaterial3D.new()
	dmat.albedo_color = Color(1.0, 0.2, 0.2)
	dummy.material_override = dmat
	win.add_child(dummy)
	
	# Crosshair dot at center
	var ch = MeshInstance3D.new()
	var sm = SphereMesh.new()
	sm.radius = 0.02
	sm.height = 0.04
	ch.mesh = sm
	ch.position = Vector3(0, 1.65, -2.0)
	var cmat = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.0, 1.0, 0.0)
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ch.material_override = cmat
	win.add_child(ch)
	
	var wm = Node3D.new()
	wm.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wm)
	
	var res = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = res.instantiate()
	
	# Find muzzle and stock positions in inst local space
	# Object_103 is front sight: pos=(-0.355, 0.161, -0.008)
	# Object_125 is stock: pos=(0.167, 0.064, -0.028)
	var front_sight_node = inst.find_child("Object_103", true, false)
	var stock_node = inst.find_child("Object_125", true, false)
	
	var p_muzzle = front_sight_node.global_position if front_sight_node else Vector3(-0.355, 0.161, 0)
	var p_stock = stock_node.global_position if stock_node else Vector3(0.26, 0.12, 0)
	
	print("p_muzzle: ", p_muzzle)
	print("p_stock: ", p_stock)
	
	# Local forward vector of the gun: from stock towards muzzle
	var v_forward = (p_muzzle - p_stock).normalized()
	# Up vector: let's test (0, 1, 0) vs (0, 0, 1) vs (1, 0, 0)
	var v_up = Vector3.UP
	var v_right = v_forward.cross(v_up).normalized()
	v_up = v_right.cross(v_forward).normalized()
	
	print("Gun local forward: ", v_forward)
	print("Gun local up: ", v_up)
	print("Gun local right: ", v_right)
	
	# We want:
	# basis * v_forward = Vector3(0, 0, -1)
	# basis * v_up = Vector3(0, 1, 0)
	# basis * v_right = Vector3(1, 0, 0)
	#
	# Since basis is orthogonal, if matrix M has columns [v_right, v_up, -v_forward],
	# then basis * M = Identity => basis = M.inverse() = M.transposed()!
	var M = Basis(v_right, v_up, -v_forward)
	var target_basis = M.transposed()
	
	print("Solved Target Basis:\n", target_basis)
	
	# Let's test 4 roll variations around the barrel axis
	var roll_tests = [
		{"name": "roll_0", "basis": target_basis},
		{"name": "roll_90", "basis": target_basis.rotated(Vector3(0, 0, -1), deg_to_rad(90))},
		{"name": "roll_180", "basis": target_basis.rotated(Vector3(0, 0, -1), deg_to_rad(180))},
		{"name": "roll_270", "basis": target_basis.rotated(Vector3(0, 0, -1), deg_to_rad(270))}
	]
	
	inst.free()
	call_deferred("_render_rolls", win, wm, res, roll_tests)

func _render_rolls(win: Window, wm: Node3D, res: PackedScene, roll_tests: Array):
	for t in roll_tests:
		for ch in wm.get_children():
			ch.queue_free()
		var inst = res.instantiate()
		inst.transform.basis = t.basis * Basis.from_scale(Vector3(0.048, 0.048, 0.048))
		inst.position = Vector3(-0.02, -0.06, -0.04)
		wm.add_child(inst)
		
		for f in range(4):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var p = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/negev_" + t.name + ".png"
		img.save_png(p)
		print("Saved: ", p)
		
	quit(0)
