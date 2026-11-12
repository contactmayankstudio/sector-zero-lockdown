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
		light.rotation_degrees = Vector3(-40, 45, 0)
		light.light_color = Color(1.0, 0.95, 0.88, 1)
		light.light_energy = 1.2
		light.shadow_enabled = true
		root_node.add_child(light)
		
		# Environment
		var we = WorldEnvironment.new()
		var env = load("res://resources/materials/env_apocalyptic_hdri.tres")
		we.environment = env
		root_node.add_child(we)
		
		# Grove Street
		var s = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
		var grove_inst = s.instantiate()
		root_node.add_child(grove_inst)
		
		# Camera at GTA Grove cul-de-sac view
		var cam = Camera3D.new()
		cam.position = Vector3(0, 1.8, 10)
		cam.look_at_from_position(Vector3(0, 1.8, 10), Vector3(0, 1.0, -10), Vector3.UP)
		root_node.add_child(cam)
		cam.current = true
		
	elif frame_count == 6:
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/test_grove_direct_render.png")
			print("Saved test_grove_direct_render.png")
		quit(0)
