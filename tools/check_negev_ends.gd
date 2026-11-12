extends SceneTree

func _init():
	var res = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = res.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		if m.mesh:
			var faces = m.mesh.get_faces()
			var neg_x_verts = []
			var pos_x_verts = []
			for v in faces:
				if v.x < -0.25:
					neg_x_verts.append(v)
				elif v.x > 0.25:
					pos_x_verts.append(v)
			print("negev_ng7 neg_x count: ", neg_x_verts.size(), " pos_x count: ", pos_x_verts.size())
			
			# Check bounding box of neg_x vs pos_x
			var neg_min_y = 999.0
			var neg_max_y = -999.0
			var neg_min_z = 999.0
			var neg_max_z = -999.0
			for v in neg_x_verts:
				neg_min_y = min(neg_min_y, v.y)
				neg_max_y = max(neg_max_y, v.y)
				neg_min_z = min(neg_min_z, v.z)
				neg_max_z = max(neg_max_z, v.z)
				
			var pos_min_y = 999.0
			var pos_max_y = -999.0
			var pos_min_z = 999.0
			var pos_max_z = -999.0
			for v in pos_x_verts:
				pos_min_y = min(pos_min_y, v.y)
				pos_max_y = max(pos_max_y, v.y)
				pos_min_z = min(pos_min_z, v.z)
				pos_max_z = max(pos_max_z, v.z)
				
			print("neg_x thickness: Y=", (neg_max_y - neg_min_y), " Z=", (neg_max_z - neg_min_z))
			print("pos_x thickness: Y=", (pos_max_y - pos_min_y), " Z=", (pos_max_z - pos_min_z))
	inst.free()
	quit(0)
