extends SceneTree

func _init():
	var scn = load("res://scenes/environments/models/road_pack.scn")
	var inst = scn.instantiate()
	var mesh_instances = inst.find_children("*", "MeshInstance3D", true, false)
	print("Total MeshInstance3D found: ", mesh_instances.size())
	for mi in mesh_instances:
		var parent_name = mi.get_parent().name if mi.get_parent() else "none"
		var gparent_name = mi.get_parent().get_parent().name if (mi.get_parent() and mi.get_parent().get_parent()) else "none"
		print("- Node: ", mi.name, " Parent: ", parent_name, " GP: ", gparent_name, " AABB: ", mi.get_aabb() if mi.mesh else "no mesh")
	inst.free()
	quit(0)
