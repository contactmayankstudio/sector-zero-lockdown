extends SceneTree

func _init():
	var skel = Skeleton3D.new()
	for m in skel.get_method_list():
		if "pose" in m.name.to_lower() or "bone" in m.name.to_lower():
			print(m.name)
	quit(0)
