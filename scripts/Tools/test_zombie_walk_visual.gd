@tool
extends SceneTree

func _init():
	var root_3d = Node3D.new()
	root.add_child(root_3d)
	
	# Floor with static body
	var sb = StaticBody3D.new()
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(20, 0.2, 20)
	col.shape = box
	col.position = Vector3(0, -0.1, 0)
	sb.add_child(col)
	root_3d.add_child(sb)
	
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(20, 20)
	floor_mesh.mesh = plane
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.25, 0.3)
	floor_mesh.material_override = mat
	root_3d.add_child(floor_mesh)
	
	# Light
	var light = DirectionalLight3D.new()
	light.position = Vector3(5, 10, 5)
	light.rotation_degrees = Vector3(-45, 45, 0)
	root_3d.add_child(light)
	
	var amb = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.12, 0.15)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.65, 0.7)
	amb.environment = env
	root_3d.add_child(amb)
	
	# Zombie
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var zombie = z_scene.instantiate()
	zombie.position = Vector3(0, 0, 0)
	root_3d.add_child(zombie)
	
	# Camera looking directly at zombie from Z = -2.8 (in front of zombie)
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.2, -2.8)
	cam.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	cam.current = true
	root_3d.add_child(cam)
	
	_capture(zombie)

func _capture(zombie):
	for f in range(5):
		await process_frame
	print("Zombie pos: ", zombie.global_position)
	var meshes = zombie.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		print("Mesh ", m.name, " vis: ", m.visible, " global_pos: ", m.global_position)
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		img.save_png("screenshots/test_zombie_chase_view.png")
		print("Saved test_zombie_chase_view.png")
	quit()
