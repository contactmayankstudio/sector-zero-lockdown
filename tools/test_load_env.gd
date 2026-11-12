extends SceneTree
func _init():
	var s = load("res://assets/3d/environments/railway_station.glb")
	if s:
		var inst = s.instantiate()
		for c in inst.find_children("*", "MeshInstance3D"):
			print("Railway Mesh: ", c.name, " mesh: ", c.mesh)
			if c.mesh:
				print("  AABB: ", c.mesh.get_aabb())
		inst.free()
	quit(0)
