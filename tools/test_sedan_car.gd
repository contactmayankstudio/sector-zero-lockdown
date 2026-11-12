@tool
extends SceneTree

func _init():
	var scn = load("res://assets/downloaded_cars/sedan_real.glb")
	var inst: Node3D = scn.instantiate()
	
	var mats = {}
	var stack = [inst]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D and curr.mesh:
			for i in range(curr.mesh.get_surface_count()):
				var mat = curr.get_surface_override_material(i)
				if not mat:
					mat = curr.mesh.surface_get_material(i)
				if mat and not mats.has(mat.resource_name):
					mats[mat.resource_name] = mat
		for c in curr.get_children():
			stack.push_back(c)
			
	print("Found ", mats.size(), " unique materials:")
	for name in mats:
		var m = mats[name]
		if m is StandardMaterial3D:
			print(" - ", name, ": albedo_col=", m.albedo_color, " metal=", m.metallic, " rough=", m.roughness, " has_alb_tex=", (m.albedo_texture != null))
		else:
			print(" - ", name, ": (", m.get_class(), ")")
			
	inst.queue_free()
	quit()
