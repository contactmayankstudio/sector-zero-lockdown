extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.scn")
	var inst = scene.instantiate()
	for child in inst.find_children("*", "MeshInstance3D"):
		var mi: MeshInstance3D = child
		print("MeshInstance3D: ", mi.name, " mesh: ", mi.mesh)
		for s in range(mi.get_surface_override_material_count()):
			print("  surface ", s, " override: ", mi.get_surface_override_material(s))
		if mi.mesh:
			for s in range(mi.mesh.get_surface_count()):
				print("  mesh surface ", s, " mat: ", mi.mesh.surface_get_material(s))
	quit(0)
