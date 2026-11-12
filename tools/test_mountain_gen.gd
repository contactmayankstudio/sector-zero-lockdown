@tool
extends SceneTree

func _init():
	print("--- Testing Procedural Mountain Generation ---")
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.008
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate a 120m x 400m mountain range along the flank
	var x_samples = 25
	var z_samples = 40
	var width = 140.0
	var length = 450.0
	
	for z_i in range(z_samples):
		for x_i in range(x_samples):
			var u = float(x_i) / float(x_samples - 1)
			var v = float(z_i) / float(z_samples - 1)
			var x = (u - 0.5) * width
			var z = (v - 0.5) * length
			
			# Height envelope: peaks rise higher away from road
			var dist_factor = smoothstep(0.0, 1.0, u)
			var n = noise.get_noise_2d(x, z)
			var h = max(0.0, (n + 0.3) * 45.0 * dist_factor)
			
			st.set_uv(Vector2(u * 12.0, v * 36.0))
			st.set_normal(Vector3.UP)
			st.add_vertex(Vector3(x, h, z))
			
	for z_i in range(z_samples - 1):
		for x_i in range(x_samples - 1):
			var i0 = z_i * x_samples + x_i
			var i1 = i0 + 1
			var i2 = (z_i + 1) * x_samples + x_i
			var i3 = i2 + 1
			
			st.add_index(i0)
			st.add_index(i1)
			st.add_index(i2)
			
			st.add_index(i1)
			st.add_index(i3)
			st.add_index(i2)
			
	st.generate_normals()
	var mesh = st.commit()
	print("Mountain mesh created! Vertices: ", mesh.get_faces().size())
	quit(0)
