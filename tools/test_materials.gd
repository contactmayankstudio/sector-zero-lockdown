extends SceneTree

func _init():
	var scn = load("res://scenes/environments/models/road_pack.scn")
	var inst = scn.instantiate()
	var mesh_instances = inst.find_children("*", "MeshInstance3D", true, false)
	for i in range(mini(5, mesh_instances.size())):
		var mi = mesh_instances[i]
		var m = mi.mesh
		if m and m.get_surface_count() > 0:
			var mat = m.surface_get_material(0)
			print("Mesh: ", mi.name, " Material: ", mat.resource_name if mat else "none")
			if mat is StandardMaterial3D:
				print("  albedo_texture: ", mat.albedo_texture != null, " normal: ", mat.normal_texture != null)
	inst.free()
	quit(0)
