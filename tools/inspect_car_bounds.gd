
extends SceneTree

func _init():
	var sc = load("res://scenes/environments/props/PoliceCarProp.scn")
	var inst = sc.instantiate()
	root.add_child(inst)
	var aabb = AABB()
	var first = true
	for mi in inst.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh:
			var m_aabb = mi.get_aabb()
			if first:
				aabb = m_aabb
				first = false
			else:
				aabb = aabb.merge(m_aabb)
	print("Car aabb: ", aabb, " size: ", aabb.size, " center: ", aabb.get_center())
	inst.free()
	quit(0)
