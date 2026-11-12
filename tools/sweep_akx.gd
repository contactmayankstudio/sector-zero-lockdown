extends SceneTree

func _init():
	var win = root
	var world_3d = World3D.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.18, 0.2, 0.24)
	world_3d.environment = env
	win.world_3d = world_3d
	
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, -45, 0)
	sun.light_color = Color.WHITE
	sun.light_energy = 2.0
	win.add_child(sun)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0.0, 1.65, 0.0)
	cam.fov = 70.0
	cam.current = true
	win.add_child(cam)
	
	var dummy = MeshInstance3D.new()
	var cap = CapsuleMesh.new()
	cap.radius = 0.3
	cap.height = 1.75
	dummy.mesh = cap
	dummy.position = Vector3(0, 1.65, -4.0)
	var dmat = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.85, 0.15, 0.15)
	dummy.material_override = dmat
	win.add_child(dummy)
	
	var wm = Node3D.new()
	wm.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wm)
	
	call_deferred("_test_akx", win, wm)

func _test_akx(win: Window, wm: Node3D):
	var rots = [
		Vector3(0, 0, 0),
		Vector3(0, 180, 0),
		Vector3(0, 0, 180),
		Vector3(0, 180, 180),
		Vector3(90, 0, 0),
		Vector3(-90, 0, 0),
		Vector3(0, 90, 0),
		Vector3(0, -90, 0),
		Vector3(0, 90, 90),
		Vector3(0, -90, 90),
		Vector3(90, 90, 0),
		Vector3(90, -90, 0)
	]
	
	var res = load("res://scenes/weapons/models/akx_scifi.scn")
	for r in rots:
		for c in wm.get_children():
			c.queue_free()
		var inst = res.instantiate()
		inst.scale = Vector3(0.85, 0.85, 0.85)
		inst.rotation_degrees = r
		inst.position = Vector3(-0.04, -0.16, -0.15)
		wm.add_child(inst)
		
		for f in range(5):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/akx_rot_%d_%d_%d.png" % [int(r.x), int(r.y), int(r.z)]
		img.save_png(fname)
		print("AKX: ", r, " -> ", fname)
		
	quit(0)
