extends SceneTree

func _init():
	for f in ["res://assets/nature_kit/glb/tree_pineTallA_detailed.glb", "res://assets/nature_kit/glb/rock_largeA.glb", "res://assets/nature_kit/glb/grass.glb"]:
		var scn = load(f)
		if scn:
			var inst = scn.instantiate()
			print("Loaded ", f, " -> root: ", inst.name)
			_dump_children(inst, "  ")
		else:
			print("Failed to load: ", f)
	quit(0)

func _dump_children(node: Node, indent: String):
	for c in node.get_children():
		print(indent, c.name, " [", c.get_class(), "]")
		if c is MeshInstance3D and c.mesh:
			print(indent, "  -> Mesh: ", c.mesh.resource_name, " surfaces: ", c.mesh.get_surface_count())
		_dump_children(c, indent + "  ")
