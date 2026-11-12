extends SceneTree

func _init():
	var s = load("res://scenes/zombies/models/zombie_normal.tscn")
	var inst = s.instantiate()
	var mesh = inst.find_child("*Mesh*", true, false)
	if mesh:
		print("Mesh name: ", mesh.name, " rotation: ", mesh.rotation)
		var aabb = mesh.get_aabb()
		print("AABB: ", aabb)
	inst.free()
	quit(0)
