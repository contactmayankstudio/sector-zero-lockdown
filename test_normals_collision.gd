extends SceneTree

func _init():
	print("--- TESTING TRIANGLE WINDING AND COLLISION ---")
	var res = 2
	var size = 10.0
	var step = size / float(res)
	
	var vertices = PackedVector3Array()
	var indices_up = PackedInt32Array()
	
	for gz in range(res + 1):
		for gx in range(res + 1):
			vertices.append(Vector3(gx * step, 0.0, gz * step))
			
	for gz in range(res):
		for gx in range(res):
			var r1 = gz * (res + 1)
			var r2 = (gz + 1) * (res + 1)
			var i0 = r1 + gx
			var i1 = r1 + gx + 1
			var i2 = r2 + gx
			var i3 = r2 + gx + 1
			
			# Correct winding:
			indices_up.append(i0)
			indices_up.append(i2)
			indices_up.append(i1)
			indices_up.append(i1)
			indices_up.append(i2)
			indices_up.append(i3)
	
	# Test collision with CharacterBody3D
	var arrays_up = []
	arrays_up.resize(Mesh.ARRAY_MAX)
	arrays_up[Mesh.ARRAY_VERTEX] = vertices
	arrays_up[Mesh.ARRAY_INDEX] = indices_up
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays_up)
	
	var sb = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	var shape = mesh.create_trimesh_shape()
	shape.backface_collision = true
	cs.shape = shape
	sb.add_child(cs)
	root.add_child(sb)
	
	var cb = CharacterBody3D.new()
	var col = CollisionShape3D.new()
	var cap = CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	cb.add_child(col)
	cb.position = Vector3(5.0, 2.0, 5.0)
	root.add_child(cb)
	
	for i in range(50):
		await process_frame
		cb.velocity.y -= 19.6 * 0.016
		cb.move_and_slide()
		if i > 20:
			print("Step %d | y: %f | on_floor: %s" % [i, cb.position.y, str(cb.is_on_floor())])
		
	print("Final CharacterBody3D pos: ", cb.position, " on floor: ", cb.is_on_floor())
	quit(0)
