@tool
extends SceneTree

func _init():
	print("=== RENDERING FRONT VIEWS OF ALL ZOMBIES ===")
	var root = SubViewport.new()
	root.size = Vector2i(512, 512)
	root.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(root)
	
	var world = World3D.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.2, 0.2)
	world.environment = env
	root.world_3d = world
	
	# Light
	var light = DirectionalLight3D.new()
	light.transform.origin = Vector3(2, 5, -4)
	light.look_at(Vector3.ZERO, Vector3.UP)
	root.add_child(light)
	
	var cam = Camera3D.new()
	# Camera is at (0, 1.2, -3.0), looking at (0, 1.2, 0).
	# This means the camera is in FRONT if the model faces -Z.
	# If the model faces -Z, we should see its FACE and CHEST.
	# If the model faces +Z, we will see its BACK / PEETH!
	cam.position = Vector3(0, 1.2, -3.0)
	cam.look_at(Vector3(0, 1.2, 0), Vector3.UP)
	cam.current = true
	root.add_child(cam)
	
	var models = {
		"velociraptor": "res://scenes/zombies/models/RealVelociraptor.scn",
		"office": "res://scenes/zombies/models/RealZombieOffice.scn",
		"6ft": "res://scenes/zombies/models/RealZombie6ft.scn",
		"biker": "res://scenes/zombies/models/RealZombieBiker.scn",
		"titan": "res://scenes/zombies/models/RealTitanBrute.scn",
		"scary": "res://scenes/zombies/models/zombie_scary.scn"
	}
	
	for name in models:
		var path = models[name]
		var scn = load(path)
		var inst = scn.instantiate()
		root.add_child(inst)
		inst.position = Vector3(0, 0, 0)
		inst.rotation = Vector3.ZERO
		
		# Wait 2 frames to render
		for i in range(3):
			await process_frame
			
		var img = root.get_texture().get_image()
		var out_path = "/home/am/targetkill/screenshots/face_check_" + name + ".png"
		img.save_png(out_path)
		print("Saved: ", out_path)
		
		inst.queue_free()
		await process_frame
		
	quit(0)
