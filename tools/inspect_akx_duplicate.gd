extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/akx_scifi.scn")
	var inst = s.instantiate()
	for c in inst.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", c.name, " parent: ", c.get_parent().name, " pos: ", c.position)
	inst.free()
	quit(0)
