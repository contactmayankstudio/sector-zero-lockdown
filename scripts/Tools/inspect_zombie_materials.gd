@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = scn.instantiate()
	var sk_mesh = inst.find_child("Object_7", true, false) as MeshInstance3D
	if sk_mesh and sk_mesh.mesh:
		print("Surface count: ", sk_mesh.mesh.get_surface_count())
		for s in range(sk_mesh.mesh.get_surface_count()):
			var mat = sk_mesh.get_active_material(s)
			if mat:
				print("Surface ", s, " mat name: ", mat.resource_name, " class: ", mat.get_class())
				if mat is StandardMaterial3D:
					print("  albedo_color: ", mat.albedo_color, " albedo_texture: ", mat.albedo_texture, " transparency: ", mat.transparency, " cull_mode: ", mat.cull_mode)
			else:
				print("Surface ", s, " mat: null")
	quit()
