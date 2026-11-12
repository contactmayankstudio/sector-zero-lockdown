@tool
extends SceneTree

func _init():
	var dir = DirAccess.open("res://scenes/zombies/models/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".scn") or file_name.ends_with(".tscn"):
				var p = "res://scenes/zombies/models/" + file_name
				var inst = load(p).instantiate()
				var skels = inst.find_children("*", "Skeleton3D", true, false)
				var ap = inst.find_children("*", "AnimationPlayer", true, false)
				var meshes = inst.find_children("*", "MeshInstance3D", true, false)
				var tris = 0
				for m in meshes:
					if m.mesh:
						for i in range(m.mesh.get_surface_count()):
							tris += m.mesh.surface_get_array_len(i) / 3
				var anim_cnt = 0
				if not ap.is_empty(): anim_cnt = ap[0].get_animation_list().size()
				print(file_name, " | skel: ", skels.size(), " | anims: ", anim_cnt, " | tris: ", tris)
				inst.free()
			file_name = dir.get_next()
	quit()
