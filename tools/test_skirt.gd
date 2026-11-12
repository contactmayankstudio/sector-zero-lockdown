@tool
extends SceneTree

func _init():
	print("--- Testing North Backdrop with Skirt ---")
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.008
	noise.fractal_octaves = 4
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var x_samples = 36
	var z_samples = 18
	var width = 460.0
	var depth = 120.0
	var height_scale = 55.0
	var center_pos = Vector3(0.0, 0.0, -480.0)
	
	var grid_verts: Array[Vector3] = []
	for z_i in range(z_samples):
		for x_i in range(x_samples):
			var u = float(x_i) / float(x_samples - 1)
			var v = float(z_i) / float(z_samples - 1)
			var x = (u - 0.5) * width
			var z = (v - 0.5) * depth
			
			var dist_factor = v # Peaks rise toward the deep horizon
			var n = noise.get_noise_2d(x, z)
			var h = max(0.0, (n + 0.35) * height_scale * (0.2 + 0.8 * dist_factor))
			var pos = Vector3(x, h, z) + center_pos
			grid_verts.append(pos)
			
			st.set_uv(Vector2(u * 28.0, v * 12.0))
			st.set_normal(Vector3.UP)
			st.add_vertex(pos)
			
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

	var perimeter: Array[int] = []
	var outward_dirs: Array[Vector3] = []
	
	# North edge (z_i = 0): x_i goes (x_samples - 1) down to 1
	for x_i in range(x_samples - 1, 0, -1):
		perimeter.append(0 * x_samples + x_i)
		outward_dirs.append(Vector3(0, 0, -1))
	# West edge (x_i = 0): z_i goes 0 to (z_samples - 2)
	for z_i in range(z_samples - 1):
		perimeter.append(z_i * x_samples + 0)
		outward_dirs.append(Vector3(-1, 0, 0))
	# South edge (z_i = z_samples - 1): x_i goes 0 to (x_samples - 2)
	for x_i in range(x_samples - 1):
		perimeter.append((z_samples - 1) * x_samples + x_i)
		outward_dirs.append(Vector3(0, 0, 1))
	# East edge (x_i = x_samples - 1): z_i goes (z_samples - 1) down to 1
	for z_i in range(z_samples - 1, 0, -1):
		perimeter.append(z_i * x_samples + (x_samples - 1))
		outward_dirs.append(Vector3(1, 0, 0))

	var n_p = perimeter.size()
	var bot_start_idx = x_samples * z_samples
	for k in range(n_p):
		var top_v = grid_verts[perimeter[k]]
		var out_dir = outward_dirs[k]
		st.set_uv(Vector2(0, 0))
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(top_v.x + out_dir.x * 0.5, -5.0, top_v.z + out_dir.z * 0.5))

	for k in range(n_p):
		var next_k = (k + 1) % n_p
		var top_a = perimeter[k]
		var top_b = perimeter[next_k]
		var bot_a = bot_start_idx + k
		var bot_b = bot_start_idx + next_k
		
		# CCW outward:
		st.add_index(top_a)
		st.add_index(bot_b)
		st.add_index(bot_a)
		
		st.add_index(top_a)
		st.add_index(top_b)
		st.add_index(bot_b)

	st.generate_normals()
	var mesh = st.commit()
	var arr = mesh.surface_get_arrays(0)
	var norms = arr[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var up = 0; var down = 0
	var avg = Vector3.ZERO
	for norm in norms:
		avg += norm
		if norm.y > 0.0: up += 1
		elif norm.y < 0.0: down += 1
	avg /= norms.size()
	print("North Backdrop with Skirt: verts=", norms.size(), " up_y=", up, " down_y=", down, " avg_norm=", avg)
	quit(0)
