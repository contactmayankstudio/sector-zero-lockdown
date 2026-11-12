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
	sun.light_energy = 1.8
	win.add_child(sun)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0.0, 1.65, 0.0)
	cam.fov = 70.0
	cam.current = true
	win.add_child(cam)
	
	var wm = Node3D.new()
	wm.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wm)
	
	# Target Zombie Dummy 3 meters ahead
	var dummy = MeshInstance3D.new()
	var cap = CapsuleMesh.new()
	cap.radius = 0.28
	cap.height = 1.75
	dummy.mesh = cap
	dummy.position = Vector3(0, 1.65, -3.5)
	var dmat = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.85, 0.2, 0.2)
	dummy.material_override = dmat
	win.add_child(dummy)
	
	# Wall with grid ground
	var ground = MeshInstance3D.new()
	var pmesh = PlaneMesh.new()
	pmesh.size = Vector2(20, 20)
	ground.mesh = pmesh
	var gmat = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.25, 0.28, 0.3)
	ground.material_override = gmat
	win.add_child(ground)
	
	var configs = [
		{"id": "negev_1", "model": "res://scenes/weapons/models/negev_ng7.scn", "offset": Vector3(-0.02, -0.06, -0.04), "rot": Vector3(0.0, 90.0, 180.0), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_2", "model": "res://scenes/weapons/models/negev_ng7.scn", "offset": Vector3(-0.02, -0.06, -0.04), "rot": Vector3(0.0, -90.0, 0.0), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_3", "model": "res://scenes/weapons/models/negev_ng7.scn", "offset": Vector3(-0.02, -0.06, -0.04), "rot": Vector3(0.0, 90.0, 0.0), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_4", "model": "res://scenes/weapons/models/negev_ng7.scn", "offset": Vector3(-0.02, -0.06, -0.04), "rot": Vector3(0.0, -90.0, 180.0), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "akx_1", "model": "res://scenes/weapons/models/akx_scifi.scn", "offset": Vector3(-0.03, -0.15, 0.0), "rot": Vector3(90.0, 0.0, 0.0), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_2", "model": "res://scenes/weapons/models/akx_scifi.scn", "offset": Vector3(-0.03, -0.15, 0.0), "rot": Vector3(-90.0, 0.0, 0.0), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "car_smg_1", "model": "res://scenes/weapons/models/car_smg.scn", "offset": Vector3(-0.03, -0.15, 0.05), "rot": Vector3(0.0, 0.0, 0.0), "scale": Vector3(1.0, 1.0, 1.0)},
		{"id": "car_smg_2", "model": "res://scenes/weapons/models/car_smg.scn", "offset": Vector3(-0.03, -0.15, 0.05), "rot": Vector3(0.0, 180.0, 0.0), "scale": Vector3(1.0, 1.0, 1.0)}
	]
	
	call_deferred("_render_all", win, wm, configs)

func _render_all(win: Window, wm: Node3D, configs: Array):
	for c in configs:
		for ch in wm.get_children():
			ch.queue_free()
			
		var res = load(c.model)
		var inst = res.instantiate()
		inst.position = c.offset
		inst.rotation_degrees = c.rot
		inst.scale = c.scale
		wm.add_child(inst)
		
		for f in range(4):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var p = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/chk_" + c.id + ".png"
		img.save_png(p)
		print("Saved render: ", p)
		
	quit(0)
