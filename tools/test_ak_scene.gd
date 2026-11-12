extends SceneTree

func _init():
	var sc = load("res://scenes/weapons/models/ak74u.tscn")
	var inst = sc.instantiate()
	root.add_child(inst)
	print("--- AK74u instantiated ---")
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", m.name, " parent: ", m.get_parent().name, " global_pos: ", m.global_position)
	inst.free()
	quit(0)
