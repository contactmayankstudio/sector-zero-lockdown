extends SceneTree

func _init():
	var s = load("res://scenes/zombies/models/RealAlienMutant.scn")
	var inst = s.instantiate()
	inst.rotation_degrees = Vector3(0, 180, 0)
	inst.scale = Vector3(0.011, 0.011, 0.011)
	root.add_child(inst)
	for m in inst.find_children("*", "VisualInstance3D", true, false):
		var tr = m.global_transform
		var aabb = m.get_aabb()
		print("Mesh: ", m.name, " global_pos: ", tr.origin, " scale: ", tr.basis.get_scale(), " aabb: ", aabb)
	quit(0)
