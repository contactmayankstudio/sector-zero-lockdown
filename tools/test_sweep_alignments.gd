extends SceneTree

func _init():
	var win = root
	var world_3d = World3D.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.22, 0.25)
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
	
	# Zombie Target Dummy at center of screen (4m ahead)
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
	
	# Crosshair at center
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
	
	call_deferred("_test_sweep", win, wm)

func _test_sweep(win: Window, wm: Node3D):
	var tests = [
		# AKX Sci-Fi candidates
		{"id": "akx_90_0_180", "path": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(90, 0, 180), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_-90_180_0", "path": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(-90, 180, 0), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_90_180_180", "path": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(90, 180, 180), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},
		{"id": "akx_-90_0_180", "path": "res://scenes/weapons/models/akx_scifi.scn", "rot": Vector3(-90, 0, 180), "offset": Vector3(-0.04, -0.16, -0.15), "scale": Vector3(0.85, 0.85, 0.85)},

		# Negev NG7 candidates
		{"id": "negev_0_0_90", "path": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(0, 0, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_0_10_90", "path": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(0, 10, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_0_-10_90", "path": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(0, -10, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_0_180_90", "path": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(0, 180, 90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},
		{"id": "negev_0_0_-90", "path": "res://scenes/weapons/models/negev_ng7.scn", "rot": Vector3(0, 0, -90), "offset": Vector3(-0.02, -0.06, -0.04), "scale": Vector3(0.048, 0.048, 0.048)},

		# Pestilence Handgun candidates
		{"id": "pestilence_0_-90_0", "path": "res://scenes/weapons/models/pestilence_handgun.scn", "rot": Vector3(0, -90, 0), "offset": Vector3(-0.04, -0.01, 0.02), "scale": Vector3(0.008, 0.008, 0.008)},
		{"id": "pestilence_0_90_0", "path": "res://scenes/weapons/models/pestilence_handgun.scn", "rot": Vector3(0, 90, 0), "offset": Vector3(-0.04, -0.01, 0.02), "scale": Vector3(0.008, 0.008, 0.008)},
		{"id": "pestilence_0_180_0", "path": "res://scenes/weapons/models/pestilence_handgun.scn", "rot": Vector3(0, 180, 0), "offset": Vector3(-0.04, -0.01, 0.02), "scale": Vector3(0.008, 0.008, 0.008)},
		{"id": "pestilence_0_0_0", "path": "res://scenes/weapons/models/pestilence_handgun.scn", "rot": Vector3(0, 0, 0), "offset": Vector3(-0.04, -0.01, 0.02), "scale": Vector3(0.008, 0.008, 0.008)}
	]
	
	for t in tests:
		for c in wm.get_children():
			c.queue_free()
		var res = load(t.path)
		var inst = res.instantiate()
		inst.scale = t.scale
		inst.rotation_degrees = t.rot
		inst.position = t.offset
		wm.add_child(inst)
		
		for f in range(6):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/sweep_%s.png" % t.id
		img.save_png(fname)
		print("Sweep rendered: ", t.id, " -> ", fname)
		
	quit(0)
