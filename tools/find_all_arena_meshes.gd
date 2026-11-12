extends SceneTree
func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var arena = scn.instantiate()
	_find_meshes(arena)
	quit(0)

func _find_meshes(n: Node):
	if n is MeshInstance3D:
		var pos = n.global_position
		var aabb = n.get_aabb() if n.mesh else AABB()
		print("Mesh: ", n.get_path(), " pos: ", pos, " aabb: ", aabb)
		if n.material_override:
			print("   mat_override: ", n.material_override.resource_name)
		for i in range(n.get_surface_override_material_count()):
			var sm = n.get_surface_override_material(i)
			if sm:
				print("   surf_override ", i, ": ", sm.resource_name, " color: ", sm.albedo_color if "albedo_color" in sm else "N/A")
	for c in n.get_children():
		_find_meshes(c)
