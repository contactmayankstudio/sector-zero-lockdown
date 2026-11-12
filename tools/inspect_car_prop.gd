extends SceneTree

func _init():
	var sc = load("res://scenes/environments/props/PoliceCarProp.scn")
	var inst = sc.instantiate()
	root.add_child(inst)
	
	var car_b = inst.find_child("car_b_002", true, false)
	car_b.scale = Vector3(1, 1, 1) # Instead of 100!
	car_b.rotation_degrees = Vector3(-90, 0, 0)
	
	await process_frame
	await process_frame
	
	for c in car_b.find_children("*", "MeshInstance3D", true, false):
		print("Visual: ", c.name, " global_pos: ", c.global_position, " aabb: ", c.get_aabb())
		
	inst.free()
	quit(0)
