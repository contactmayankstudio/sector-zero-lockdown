extends SceneTree
func _init():
	var scn = load("res://assets/nature_kit/scn/tree_pine_tall.scn")
	var inst = scn.instantiate()
	for c in inst.get_children():
		if c is MeshInstance3D:
			for i in range(c.mesh.get_surface_count()):
				var mat = c.mesh.surface_get_material(i)
				if mat is StandardMaterial3D:
					print("Surface ", i, " mat name: ", mat.resource_name)
					print("  Albedo Color: ", mat.albedo_color)
					print("  Albedo Texture: ", mat.albedo_texture)
					print("  Roughness: ", mat.roughness)
					print("  Emission: ", mat.emission_enabled, " color: ", mat.emission)
	quit(0)
