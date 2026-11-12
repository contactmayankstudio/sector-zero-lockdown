@tool
extends SceneTree

func _init():
	var s = load("res://scenes/environments/CityCarZombieArena.tscn")
	var inst = s.instantiate()
	var vf = inst.get_node_or_null("AdvancedTerrain/ValleyFloor") as MeshInstance3D
	if vf and vf.mesh:
		var faces = vf.mesh.get_faces()
		print("ValleyFloor face count: ", faces.size() / 3)
		# Check the first 5 triangles
		for i in range(5):
			var v0 = faces[i*3]
			var v1 = faces[i*3 + 1]
			var v2 = faces[i*3 + 2]
			var normal = (v1 - v0).cross(v2 - v0).normalized()
			print("Tri ", i, ": v0=", v0, " v1=", v1, " v2=", v2, " cross normal=", normal)
	inst.free()
	quit()
