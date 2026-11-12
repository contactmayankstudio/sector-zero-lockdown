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
	
	call_deferred("_test_all_equipped", win, wm)

func _test_all_equipped(win: Window, wm: Node3D):
	var weps = [
		{
			"id": "negev_ng7", 
			"path": "res://scenes/weapons/models/negev_ng7.scn",
			"offset": Vector3(-0.02, -0.06, -0.04),
			"rot": Vector3(0.0, 0.0, 90.0),
			"scale": Vector3(0.048, 0.048, 0.048)
		},
		{
			"id": "akx_scifi", 
			"path": "res://scenes/weapons/models/akx_scifi.scn",
			"offset": Vector3(-0.04, -0.16, -0.15),
			"rot": Vector3(-90.0, 0.0, 180.0),
			"scale": Vector3(0.85, 0.85, 0.85)
		},
		{
			"id": "car_smg", 
			"path": "res://scenes/weapons/models/car_smg.scn",
			"offset": Vector3(-0.03, -0.15, 0.05),
			"rot": Vector3(0.0, 180.0, 0.0),
			"scale": Vector3(1.0, 1.0, 1.0)
		},
		{
			"id": "pestilence_handgun", 
			"path": "res://scenes/weapons/models/pestilence_handgun.scn",
			"offset": Vector3(-0.04, -0.01, 0.02),
			"rot": Vector3(0.0, -90.0, 0.0),
			"scale": Vector3(0.008, 0.008, 0.008)
		},
		{
			"id": "primordium_vandal", 
			"path": "res://scenes/weapons/models/primordium_vandal.scn",
			"offset": Vector3(-0.03, 0.0, -0.05),
			"rot": Vector3(0.0, 180.0, 0.0),
			"scale": Vector3(0.85, 0.85, 0.85)
		},
		{
			"id": "prowler_smg", 
			"path": "res://scenes/weapons/models/prowler_smg.scn",
			"offset": Vector3(-0.04, -0.22, -0.20),
			"rot": Vector3(0.0, 180.0, 0.0),
			"scale": Vector3(0.038, 0.038, 0.038)
		}
	]
	
	for w in weps:
		for c in wm.get_children():
			c.queue_free()
		var res = load(w.path)
		var inst = res.instantiate()
		inst.scale = w.scale
		inst.rotation_degrees = w.rot
		inst.position = w.offset
		wm.add_child(inst)
		
		for f in range(6):
			await RenderingServer.frame_post_draw
			
		var img = win.get_texture().get_image()
		var fname = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/final_gun_%s.png" % w.id
		img.save_png(fname)
		print("Saved: ", fname)
		
	quit(0)
