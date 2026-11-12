@tool
extends SceneTree

func _init():
	print("--- TESTING DUNE WINDING FOR UPWARD NORMALS ---")
	for flip in [false, true]:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		# A quad on xz plane
		st.add_vertex(Vector3(0, 0, 0)) # 0
		st.add_vertex(Vector3(1, 0, 0)) # 1
		st.add_vertex(Vector3(0, 0, -1)) # 2 (z goes negative)
		st.add_vertex(Vector3(1, 0, -1)) # 3
		
		if not flip:
			st.add_index(0); st.add_index(1); st.add_index(2)
			st.add_index(1); st.add_index(3); st.add_index(2)
		else:
			st.add_index(0); st.add_index(2); st.add_index(1)
			st.add_index(1); st.add_index(2); st.add_index(3)
			
		st.generate_normals()
		var m = st.commit()
		var shape = m.create_trimesh_shape()
		var faces = shape.get_faces()
		var p0 = faces[0]
		var p1 = faces[1]
		var p2 = faces[2]
		var norm = (p1 - p0).cross(p2 - p0).normalized()
		print("Flip=", flip, " Normal: ", norm)
	quit(0)
