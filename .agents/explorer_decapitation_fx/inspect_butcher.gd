extends SceneTree

func _init():
	var res = load("res://scenes/zombies/models/RealButcherBoss.scn")
	var inst = res.instantiate()
	for child in inst.find_children("*", "MeshInstance3D", true, false):
		print("Boss child: ", child.name, " pos: ", child.position, " aabb: ", child.get_aabb())
	inst.free()
	quit()
