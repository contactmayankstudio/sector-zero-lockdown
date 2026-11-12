extends SceneTree

func _init():
	var win = root
	var world_3d = World3D.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.15, 0.18, 0.22)
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
	
	var wm = Node3D.new()
	wm.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wm)
	
	# Let's test combinations of rotations based on (90, 90, Z) and others
	var test_configs = [
		{"id": "negev_A", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(90, 90, 0), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_B", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(90, 90, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_C", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(90, 90, 180), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_D", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(90, 90, -90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_E", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(-90, 0, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_F", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(-90, 0, -90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_G", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(90, 0, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_H", "model": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(90, 0, -90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		
		# AKX
		{"id": "akx_A", "model": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(90, 0, 0), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_B", "model": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(90, 180, 0), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_C", "model": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(-90, 180, 0), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_D", "model": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(0, 90, 0), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		
		# CAR SMG
		{"id": "car_A", "model": "res://scenes/weapons/models/car_smg.scn", "rot": Vector3(0, 0, 0), "offset": Vector3(-0.03, -0.15, 0.05), "scale": Vector3(1.0, 1.0, 1.0)},
		{"id": "car_B", "model": "res://scenes/weapons/models/car_smg.scn", "rot": Vector3(0, 180, 0), "offset": Vector3(-0.03, -0.15, 0.05), "scale": Vector3(1.0, 1.0, 1.0)}
	]
	
	call_deferred("_run", win, wm, test_configs)

func _run(win: Window, wm: Node3D, configs: Array):
	for c in configs:
		for ch in wm.get_children():
			ch.queue_free()
		var res = load(c.model)
		var inst = res.instantiate()
		inst.scale = c.scale
		inst.rotation_degrees = c.rot
		inst.position = c.offset
		wm.add_child(inst)
		
		for f in range(4):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/rot_focus_%s.png" % c.id
		img.save_png(fname)
		print("Tested: ", c.id, " -> ", fname)
		
	quit(0)
