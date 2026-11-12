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
	
	# Target Dummy 4m ahead at center of view (crosshair position)
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
	
	# Let's test negev rotations systematically
	var test_rotations = [
		Vector3(0, 0, 0),
		Vector3(0, 90, 0),
		Vector3(0, -90, 0),
		Vector3(0, 180, 0),
		Vector3(90, 0, 0),
		Vector3(-90, 0, 0),
		Vector3(0, 90, 90),
		Vector3(0, -90, -90),
		Vector3(0, 90, 180),
		Vector3(0, -90, 180),
		Vector3(90, 90, 0),
		Vector3(90, -90, 0),
		Vector3(-90, 90, 0),
		Vector3(-90, -90, 0),
		Vector3(0, 0, 90),
		Vector3(0, 0, -90),
		Vector3(0, 0, 180)
	]
	
	var res = load("res://scenes/weapons/models/negev_ng7.scn")
	call_deferred("_run", win, wm, res, test_rotations)

func _run(win: Window, wm: Node3D, res: PackedScene, rots: Array):
	for i in range(rots.size()):
		var rot = rots[i]
		for c in wm.get_children():
			c.queue_free()
		var inst = res.instantiate()
		inst.scale = Vector3(0.048, 0.048, 0.048)
		inst.rotation_degrees = rot
		inst.position = Vector3(-0.02, -0.06, -0.04)
		wm.add_child(inst)
		
		for f in range(4):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/rot_test_%d_%d_%d.png" % [int(rot.x), int(rot.y), int(rot.z)]
		img.save_png(fname)
		print("Tested rot: ", rot, " -> ", fname)
		
	quit(0)
