extends SceneTree

func _init():
	var sc = load("res://scenes/weapons/models/AK74uAnimated.scn")
	var inst = sc.instantiate()
	root.add_child(inst)
	inst.rotation_degrees = Vector3(-90, 0, 0)
	await process_frame
	await process_frame
	var obj61 = inst.find_child("Object_61", true, false)
	if obj61:
		print("Object_61 global_position: ", obj61.global_position)
		print("Object_61 aabb: ", obj61.get_aabb())
	inst.free()
	quit(0)
