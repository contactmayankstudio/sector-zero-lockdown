extends SceneTree

func _init():
	var sc = load("res://scenes/environments/props/PoliceCarProp.scn")
	var inst = sc.instantiate()
	var car_b = inst.find_child("car_b_002", true, false)
	if car_b:
		car_b.position.y = -0.45
		
	var packed = PackedScene.new()
	var err = packed.pack(inst)
	if err == OK:
		ResourceSaver.save(packed, "res://scenes/environments/props/PoliceCarProp.scn", ResourceSaver.FLAG_COMPRESS)
		print("Successfully adjusted car_b position.y = -0.45")
	inst.free()
	quit(0)
