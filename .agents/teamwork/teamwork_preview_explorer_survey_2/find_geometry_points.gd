extends SceneTree

func _init():
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root_node.add_child(bike)
	
	create_timer(0.05).timeout.connect(func():
		_find_contact_points(bike)
	)

func _find_contact_points(bike: Node3D):
	print("\n=== FINDING PRECISE HANDLEBAR & FOOTPEG GEOMETRY ===")
	
	# The front fork steer node is:
	var steer = bike.fork_steer_node
	print("Steer node: ", steer)
	if steer:
		# Check all meshes under steer
		var meshes = steer.find_children("*", "MeshInstance3D", true, false)
		print("Meshes under fork_steer_node: ", meshes.size())
		for m in meshes:
			print("  Steer mesh: ", m.name, " local pos: ", m.position)
	
	# Let's inspect chassis meshes to find the seat and footpegs
	var hayabusa = bike.visual_wrapper.get_node("HayabusaMesh")
	var all_meshes = hayabusa.find_children("*", "MeshInstance3D", true, false)
	for m in all_meshes:
		var aabb = m.get_aabb()
		var g_aabb = m.global_transform * aabb
		var b_aabb_pos = bike.to_local(g_aabb.position)
		var b_aabb_end = bike.to_local(g_aabb.end)
		print("Mesh: %-35s -> Bike Y-range: [%.2f, %.2f], Z-range: [%.2f, %.2f], X-range: [%.2f, %.2f]" % [
			m.name,
			min(b_aabb_pos.y, b_aabb_end.y), max(b_aabb_pos.y, b_aabb_end.y),
			min(b_aabb_pos.z, b_aabb_end.z), max(b_aabb_pos.z, b_aabb_end.z),
			min(b_aabb_pos.x, b_aabb_end.x), max(b_aabb_pos.x, b_aabb_end.x)
		])
	
	quit(0)
