extends SceneTree

func _init():
	var scn = load("res://assets/nature_kit/scn/tree_pine_tall.scn")
	var inst = scn.instantiate()
	for c in inst.get_children():
		if c is MeshInstance3D and c.mesh:
			print("Mesh: ", c.name, " AABB: ", c.mesh.get_aabb())
	inst.free()
	quit(0)
