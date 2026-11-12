extends SceneTree

func _init():
	var res = load("res://scenes/weapons/models/car_smg.scn")
	var inst = res.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		if m.mesh:
			var faces = m.mesh.get_faces()
			for v in faces:
				var world_v = m.transform * v
				if world_v.z < -10.0:
					print("car_smg Z < -10 vertex: ", world_v)
					break
			for v in faces:
				var world_v = m.transform * v
				if world_v.z > 10.0:
					print("car_smg Z > 10 vertex: ", world_v)
					break
	inst.free()
	quit(0)
