extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/ak74_bayonet.scn")
	var inst = s.instantiate()
	root.add_child(inst)
	
	var comp: MeshInstance3D = inst.find_child("compensator_low_main_0", true, false)
	var stock: MeshInstance3D = inst.find_child("stock_low_main_0", true, false)
	var sight: MeshInstance3D = inst.find_child("front_sights_low_main_0", true, false)
	
	print("AK-74 Compensator global pos: ", comp.global_position)
	print("AK-74 Stock global pos: ", stock.global_position)
	var fwd = (comp.global_position - stock.global_position).normalized()
	print("AK-74 Barrel forward vector: ", fwd)
	var up = (sight.global_position - comp.global_position).normalized()
	print("AK-74 Up vector: ", up)
	
	inst.free()
	quit(0)
