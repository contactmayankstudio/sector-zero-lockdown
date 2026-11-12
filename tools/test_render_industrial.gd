extends SceneTree

var frame_count = 0
var scene_inst = null

func _process(delta):
	frame_count += 1
	if frame_count == 1:
		var root_node = Node3D.new()
		root.add_child(root_node)
		scene_inst = root_node
		
		# Light
		var light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-45, 45, 0)
		light.light_energy = 1.5
		root_node.add_child(light)
		
		# Street
		var s = load("res://assets/3d/environments/industrial_street.glb")
		var street_inst = s.instantiate()
		root_node.add_child(street_inst)
		
		# Camera
		var cam = Camera3D.new()
		cam.position = Vector3(0, 2, 5)
		cam.look_at(Vector3(0, 1, 0), Vector3.UP)
		root_node.add_child(cam)
		cam.current = true
		
	elif frame_count == 5:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/test_industrial_render.png")
			print("Saved test_industrial_render.png")
		quit(0)
