@tool
extends SceneTree

func _init():
	print("--- TEST LEFT & RIGHT DUNE NORMALS ---")
	test_grid("Left Dune", -7.0, -32.0, 10.0, -590.0)
	test_grid("Right Dune", 7.0, 32.0, 10.0, -590.0)
	quit(0)

func test_grid(dune_name: String, x_start: float, x_end: float, z_start: float, z_end: float):
	print("Checking ", dune_name)
	var x_steps = 2
	var z_steps = 2
	var dx = (x_end - x_start) / float(x_steps)
	var dz = (z_end - z_start) / float(z_steps)
	
	for flip in [false, true]:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for zi in range(z_steps + 1):
			var z = z_start + zi * dz
			for xi in range(x_steps + 1):
				var x = x_start + xi * dx
				var y = 0.0 # flat for test
				st.add_vertex(Vector3(x, y, z))
				
		for zi in range(z_steps):
			for xi in range(x_steps):
				var i0 = zi * (x_steps + 1) + xi
				var i1 = i0 + 1
				var i2 = (zi + 1) * (x_steps + 1) + xi
				var i3 = i2 + 1
				if not flip:
					st.add_index(i0); st.add_index(i1); st.add_index(i2)
					st.add_index(i1); st.add_index(i3); st.add_index(i2)
				else:
					st.add_index(i0); st.add_index(i2); st.add_index(i1)
					st.add_index(i1); st.add_index(i2); st.add_index(i3)
					
		st.generate_normals()
		var m = st.commit()
		var s = m.create_trimesh_shape()
		var faces = s.get_faces()
		var p0 = faces[0]
		var p1 = faces[1]
		var p2 = faces[2]
		var norm = (p1 - p0).cross(p2 - p0).normalized()
		print("  flip=", flip, " normal=", norm)
