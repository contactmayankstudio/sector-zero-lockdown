extends SceneTree

func _init():
	for name in ["tree_pine_tall", "tree_pine_round", "rock_large", "grass_tuft", "bush_detailed"]:
		var path = "res://assets/nature_kit/scn/" + name + ".scn"
		var scn = load(path)
		if scn:
			var inst = scn.instantiate()
			print("Scn ", name, " loaded. Finding meshes:")
			_find_mesh(inst)
			inst.free()
		else:
			print("Failed: ", path)
	quit(0)

func _find_mesh(n: Node):
	if n is MeshInstance3D and n.mesh:
		print("  -> Found Mesh: ", n.name, " class: ", n.mesh.get_class(), " surfaces: ", n.mesh.get_surface_count())
	for c in n.get_children():
		_find_mesh(c)
