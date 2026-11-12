extends SceneTree

var models = [
	{"name": "office_rot0", "path": "res://scenes/zombies/models/RealZombieOffice.scn", "rot_y": 0.0},
	{"name": "office_rotPI", "path": "res://scenes/zombies/models/RealZombieOffice.scn", "rot_y": PI},
	{"name": "6ft_rot0", "path": "res://scenes/zombies/models/RealZombie6ft.scn", "rot_y": 0.0},
	{"name": "6ft_rotPI", "path": "res://scenes/zombies/models/RealZombie6ft.scn", "rot_y": PI},
	{"name": "biker_rot0", "path": "res://scenes/zombies/models/RealZombieBiker.scn", "rot_y": 0.0},
	{"name": "biker_rotPI", "path": "res://scenes/zombies/models/RealZombieBiker.scn", "rot_y": PI},
	{"name": "titan_rot0", "path": "res://scenes/zombies/models/RealTitanBrute.scn", "rot_y": 0.0},
	{"name": "titan_rotPI", "path": "res://scenes/zombies/models/RealTitanBrute.scn", "rot_y": PI},
	{"name": "raptor_rot0", "path": "res://scenes/zombies/models/RealVelociraptor.scn", "rot_y": 0.0},
	{"name": "raptor_rotPI", "path": "res://scenes/zombies/models/RealVelociraptor.scn", "rot_y": PI},
	{"name": "scary_rot0", "path": "res://scenes/zombies/models/zombie_scary.scn", "rot_y": 0.0},
	{"name": "scary_rotPI", "path": "res://scenes/zombies/models/zombie_scary.scn", "rot_y": PI},
]

func _init():
	_run()

func _run():
	var root = get_root()
	
	var env = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.15, 0.15, 0.18)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.8, 0.8, 0.8)
	env.environment = e
	root.add_child(env)
	
	var light = DirectionalLight3D.new()
	root.add_child(light)
	light.position = Vector3(1, 3, -3)
	light.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	
	var cam = Camera3D.new()
	root.add_child(cam)
	cam.position = Vector3(0, 1.2, -2.5) # Looking from -Z towards +Z
	cam.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	cam.current = true
	
	for item in models:
		var scn = load(item.path)
		var inst = scn.instantiate()
		inst.position = Vector3(0, 0, 0)
		inst.rotation.y = item.rot_y
		root.add_child(inst)
		
		# Wait 5 frames
		for i in range(5):
			await process_frame
			
		var img = root.get_texture().get_image()
		var filename = "/home/am/targetkill/screenshots/zombie_face_" + item.name + ".png"
		img.save_png(filename)
		print("Saved capture: ", filename)
		
		inst.free()
		await process_frame
		
	print("ALL CAPTURES DONE!")
	quit(0)
