extends SceneTree

func _init():
	var scene = load("res://scenes/weapons/models/negev_ng7.scn")
	if not scene:
		print("ERROR: Could not load negev_ng7.scn")
		quit(1)
		return
	var inst = scene.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	print("Negev meshes count: ", meshes.size())
	for m in meshes:
		if m.mesh:
			var aabb = m.mesh.get_aabb()
			print(m.name, " AABB pos=", aabb.position, " size=", aabb.size)
	inst.free()
	quit(0)
