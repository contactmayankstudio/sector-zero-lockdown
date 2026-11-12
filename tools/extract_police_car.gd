
extends SceneTree

func _init():
	var sc = load("res://scenes/environments/props/WreckedVehiclesPack.scn")
	var inst = sc.instantiate()
	var car = inst.find_child("car_b_002", true, false)
	if car:
		car.get_parent().remove_child(car)
		var root_n = Node3D.new()
		root_n.name = "PoliceCarProp"
		root_n.add_child(car)
		car.position = Vector3.ZERO
		car.rotation = Vector3.ZERO
		car.owner = root_n
		for child in car.find_children("*", "Node3D", true, false):
			child.owner = root_n
		
		# Add a StaticBody3D collision box
		var sb = StaticBody3D.new()
		sb.name = "Collider"
		var cs = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = Vector3(2.4, 1.6, 4.6)
		cs.shape = box
		cs.position = Vector3(0, 0.8, 0)
		sb.add_child(cs)
		root_n.add_child(sb)
		sb.owner = root_n
		cs.owner = root_n
		
		var packed = PackedScene.new()
		packed.pack(root_n)
		var err = ResourceSaver.save(packed, "res://scenes/environments/props/PoliceCarProp.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved PoliceCarProp.scn err: ", err)
		root_n.free()
	inst.free()
	quit(0)
