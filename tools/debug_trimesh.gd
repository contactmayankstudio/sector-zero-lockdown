extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = scn.instantiate()
	get_root().add_child(arena)
	
	var adv = arena.get_node_or_null("AdvancedTerrain")
	var vf = adv.get_node_or_null("ValleyFloor") as MeshInstance3D
	print("ValleyFloor mesh: ", vf.mesh)
	print("ValleyFloor faces count: ", vf.mesh.get_faces().size())
	
	var col_shape = vf.mesh.create_trimesh_shape()
	print("create_trimesh_shape result: ", col_shape)
	if col_shape:
		print("Faces in shape: ", col_shape.get_faces().size())
		
	# Now test raycast specifically against ValleyFloor shape
	var sb = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	cs.shape = col_shape
	sb.add_child(cs)
	get_root().add_child(sb)
	
	for i in range(2):
		await process_frame
		
	var space = get_root().get_world_3d().direct_space_state
	var res = space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(-45, 50, -100), Vector3(-45, -50, -100)))
	print("Raycast result at (-45, -100): ", res)
	
	arena.queue_free()
	sb.queue_free()
	quit(0)
