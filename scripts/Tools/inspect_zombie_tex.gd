@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = scn.instantiate()
	var mesh = inst.find_child("Object_7", true, false) as MeshInstance3D
	if mesh and mesh.mesh:
		var mat = mesh.get_active_material(0)
		if mat is StandardMaterial3D and mat.albedo_texture:
			var img = mat.albedo_texture.get_image()
			if img:
				img.save_png("screenshots/zombie_texture.png")
				print("Saved zombie_texture.png: ", img.get_size(), " format: ", img.get_format())
	quit()
