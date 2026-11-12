@tool
extends SceneTree

func _init():
	var paths = [
		"res://scenes/zombies/models/zombie_realistic_human.scn",
		"res://scenes/zombies/models/RealZombieOffice.scn",
		"res://scenes/zombies/models/RealZombieBiker.scn",
		"res://scenes/zombies/models/RealTitanBrute.scn"
	]
	for p in paths:
		var inst = load(p).instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		print(p.get_file(), " has ", meshes.size(), " meshes:")
		for m in meshes:
			var mat = m.get_active_material(0)
			var tex_name = "none"
			var col = "none"
			if mat and mat is StandardMaterial3D:
				if mat.albedo_texture:
					tex_name = mat.albedo_texture.resource_path.get_file()
				col = str(mat.albedo_color)
			print("  ", m.name, " mat: ", mat != null, " tex: ", tex_name, " col: ", col)
		inst.free()
	quit()
