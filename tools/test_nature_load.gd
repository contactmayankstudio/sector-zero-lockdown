extends SceneTree

func _init():
	var models = [
		"res://assets/nature_kit/glb/tree_palm.glb",
		"res://assets/nature_kit/glb/tree_oak.glb",
		"res://assets/nature_kit/glb/tree_pineTallA.glb",
		"res://assets/nature_kit/glb/plant_bushLarge.glb",
		"res://assets/nature_kit/glb/rock_tallA.glb"
	]
	for mpath in models:
		var scn = load(mpath)
		if scn:
			var inst = scn.instantiate()
			print("=== ", mpath, " ===")
			for child in inst.get_children():
				if child is MeshInstance3D:
					print("  Mesh: ", child.mesh, " surface_count: ", child.mesh.get_surface_count())
					for s in range(child.mesh.get_surface_count()):
						print("    surf ", s, " mat: ", child.mesh.surface_get_material(s))
			inst.free()
	quit()
