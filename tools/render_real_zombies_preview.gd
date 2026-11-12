extends SceneTree

var frame_count = 0
var scene_root = null

func _process(delta):
	frame_count += 1
	if frame_count == 1:
		scene_root = Node3D.new()
		root.add_child(scene_root)
		
		var light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-35, 45, 0)
		light.light_color = Color(1, 0.95, 0.9, 1)
		light.light_energy = 1.2
		scene_root.add_child(light)
		
		# Left: RealDoomZombie
		var s1 = load("res://scenes/zombies/models/RealDoomZombie.tscn")
		var inst1 = s1.instantiate()
		inst1.position = Vector3(-1.2, 0, 0)
		inst1.rotation_degrees = Vector3(0, 0, 0)
		scene_root.add_child(inst1)
		
		# Right: RealSoldierZombie
		var s2 = load("res://scenes/zombies/models/RealSoldierZombie.tscn")
		var inst2 = s2.instantiate()
		inst2.position = Vector3(1.2, 0, 0)
		inst2.rotation_degrees = Vector3(0, 0, 0)
		scene_root.add_child(inst2)
		
		var cam = Camera3D.new()
		cam.position = Vector3(0, 1.3, 3.2)
		cam.look_at_from_position(Vector3(0, 1.3, 3.2), Vector3(0, 1.1, 0), Vector3.UP)
		scene_root.add_child(cam)
		cam.current = true
		
	elif frame_count == 5:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/preview_real_zombies_showcase.png")
			print("Saved screenshots/preview_real_zombies_showcase.png")
		quit(0)
