@tool
extends SceneTree

func _init():
	print("=================================================================")
	print("=== BAKING PERMANENT 3D TERRAIN COLLIDERS & CLEANING BARRIERS ===")
	print("=================================================================")
	
	var scene_path = "res://scenes/environments/CityCarZombieArena.tscn"
	var packed = load(scene_path)
	if not packed:
		printerr("ERROR: Failed to load ", scene_path)
		quit(1)
		return
		
	var scene = packed.instantiate()
	var adv = scene.get_node_or_null("AdvancedTerrain")
	if not adv:
		printerr("ERROR: AdvancedTerrain node not found!")
		scene.queue_free()
		quit(1)
		return
		
	# High traction mountain terrain physics material
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = 1.0
	physics_mat.rough = true
	
	var baked_count = 0
	
	# -------------------------------------------------------------
	# 1. AdvancedTerrain Targets (Mountains, Roads, Paths, Valley)
	# -------------------------------------------------------------
	var adv_targets = [
		{"mesh_name": "ValleyFloor", "body_name": "ValleyFloor_Physics"},
		{"mesh_name": "MountainWest", "body_name": "MountainWest_Physics"},
		{"mesh_name": "MountainEast", "body_name": "MountainEast_Physics"},
		{"mesh_name": "MountainNorthWall", "body_name": "MountainNorthWall_Physics"},
		{"mesh_name": "MountainSouthWall", "body_name": "MountainSouthWall_Physics"},
		{"mesh_name": "MountainRoad_West", "body_name": "MountainRoad_West_Physics"},
		{"mesh_name": "MountainRoad_East", "body_name": "MountainRoad_East_Physics"},
		{"mesh_name": "DirtPath_West", "body_name": "DirtPath_West_Physics"},
		{"mesh_name": "DirtPath_East", "body_name": "DirtPath_East_Physics"}
	]
	
	for t in adv_targets:
		var mi = adv.get_node_or_null(t.mesh_name) as MeshInstance3D
		if not mi or not mi.mesh:
			print("Skipping missing mesh: ", t.mesh_name)
			continue
			
		var body = adv.get_node_or_null(t.body_name) as StaticBody3D
		if not body:
			body = StaticBody3D.new()
			body.name = t.body_name
			body.transform = mi.transform
			adv.add_child(body)
			body.owner = scene # Required for PackedScene serialization
			body.physics_material_override = physics_mat
			print("+ Created missing physics body: ", t.body_name)
		else:
			body.physics_material_override = physics_mat
			
		var existing_shapes = body.find_children("*", "CollisionShape3D", true, false)
		if existing_shapes.is_empty():
			var shape = mi.mesh.create_trimesh_shape()
			if shape:
				var cs = CollisionShape3D.new()
				cs.name = "CollisionShape3D"
				cs.shape = shape
				cs.transform = Transform3D.IDENTITY
				body.add_child(cs)
				cs.owner = scene # Required for PackedScene serialization
				print("✓ Baked ConcavePolygonShape3D for: ", t.mesh_name, " -> ", body.name)
				baked_count += 1
		else:
			print("Collider already present in: ", body.name)

	# -------------------------------------------------------------
	# 2. RealisticTerrain Targets (Sidewalks, Shoulders)
	# -------------------------------------------------------------
	var real = scene.get_node_or_null("RealisticTerrain")
	if real:
		var real_targets = ["SidewalkLeft", "SidewalkRight", "DirtShoulderLeft", "DirtShoulderRight"]
		for p_name in real_targets:
			var sb = real.get_node_or_null(p_name) as StaticBody3D
			if not sb:
				print("RealisticTerrain body not found: ", p_name)
				continue
				
			var mi = sb.get_node_or_null("Mesh") as MeshInstance3D
			if not mi or not mi.mesh:
				print("RealisticTerrain mesh not found in: ", p_name)
				continue
				
			# Smooth sidewalk heights to flush <= 0.02m (y = 0.01m)
			if p_name.begins_with("Sidewalk"):
				var cur_pos = mi.transform.origin
				cur_pos.y = 0.01
				mi.transform.origin = cur_pos
				print("✓ Smoothed ", p_name, " mesh height to flush y = 0.01m")
				
			sb.physics_material_override = physics_mat
			
			var existing_shapes = sb.find_children("*", "CollisionShape3D", true, false)
			if existing_shapes.is_empty():
				var shape = mi.mesh.create_trimesh_shape()
				if shape:
					var cs = CollisionShape3D.new()
					cs.name = "CollisionShape3D"
					cs.shape = shape
					cs.transform = mi.transform # Must match local mesh offset!
					sb.add_child(cs)
					cs.owner = scene # Required for PackedScene serialization
					print("✓ Baked ConcavePolygonShape3D for: ", p_name, " at ", cs.transform.origin)
					baked_count += 1
			else:
				print("Collider already present in: ", sb.name)

	# -------------------------------------------------------------
	# 3. Highway Obstacle Cleanup (Remove Barrier_0 to Barrier_7)
	# -------------------------------------------------------------
	var hp = scene.get_node_or_null("HighwayProps")
	var barriers_removed = 0
	if hp:
		for i in range(8):
			var barrier = hp.get_node_or_null("Barrier_%d" % i)
			if barrier:
				barrier.free()
				barriers_removed += 1
				print("✓ Removed barrier obstacle: Barrier_%d" % i)
	print("Total concrete barriers removed: ", barriers_removed)
	
	print("Total newly baked colliders: ", baked_count)
	
	# -------------------------------------------------------------
	# 4. Pack and Re-Save CityCarZombieArena.tscn
	# -------------------------------------------------------------
	var new_packed = PackedScene.new()
	var err = new_packed.pack(scene)
	if err != OK:
		printerr("ERROR: Failed to pack scene! Error code: ", err)
		scene.queue_free()
		quit(1)
		return
		
	err = ResourceSaver.save(new_packed, scene_path)
	if err != OK:
		printerr("ERROR: Failed to save scene to ", scene_path, "! Error: ", err)
		scene.queue_free()
		quit(1)
		return
		
	print("✓ Successfully saved updated scene with permanent colliders to: ", scene_path)
	scene.queue_free()
	quit(0)
