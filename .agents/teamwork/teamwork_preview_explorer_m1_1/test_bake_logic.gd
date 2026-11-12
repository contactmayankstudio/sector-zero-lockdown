@tool
extends SceneTree

func _init():
	print("--- TESTING BAKE LOGIC IN MEMORY ---")
	var scene_path = "res://scenes/environments/CityCarZombieArena.tscn"
	var packed = load(scene_path)
	if not packed:
		print("ERROR: Failed to load scene")
		quit(1)
		return
		
	var scene = packed.instantiate()
	var adv = scene.get_node_or_null("AdvancedTerrain")
	if not adv:
		print("ERROR: AdvancedTerrain not found")
		quit(1)
		return
		
	var m_west = adv.get_node_or_null("MountainWest") as MeshInstance3D
	var body_west = adv.get_node_or_null("MountainWest_Physics") as StaticBody3D
	
	if not m_west or not body_west:
		print("ERROR: MountainWest or MountainWest_Physics not found")
		quit(1)
		return
		
	print("MountainWest mesh vertices: ", m_west.mesh.get_faces().size())
	
	var shape = m_west.mesh.create_trimesh_shape()
	print("Created trimesh shape: ", shape.get_class(), " faces count: ", shape.get_faces().size())
	
	var cs = CollisionShape3D.new()
	cs.name = "CollisionShape3D"
	cs.shape = shape
	body_west.add_child(cs)
	cs.owner = scene
	
	print("cs parent: ", cs.get_parent().name, " cs owner: ", cs.owner.name)
	
	var test_packed = PackedScene.new()
	var pack_err = test_packed.pack(scene)
	print("Pack error code: ", pack_err)
	
	# Instantiate from the newly packed scene to verify persistence!
	var re_scene = test_packed.instantiate()
	var re_adv = re_scene.get_node_or_null("AdvancedTerrain")
	var re_body = re_adv.get_node_or_null("MountainWest_Physics")
	var re_cols = re_body.find_children("*", "CollisionShape3D", true, false)
	print("Re-instantiated MountainWest_Physics CollisionShape3D count: ", re_cols.size())
	if not re_cols.is_empty():
		var re_shape = re_cols[0].shape
		print("Re-instantiated shape class: ", re_shape.get_class(), " faces: ", re_shape.get_faces().size())
		print("SUCCESS: Pre-baked ConcavePolygonShape3D successfully preserved in PackedScene!")
	else:
		print("FAILED: CollisionShape3D was NOT preserved in PackedScene!")
		
	scene.queue_free()
	re_scene.queue_free()
	quit(0)
