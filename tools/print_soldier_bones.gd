extends SceneTree

func _init():
	var scene = load("res://scenes/characters/RealSoldier.tscn")
	if not scene:
		print("Failed to load RealSoldier.tscn")
		quit(1)
		return
	var inst = scene.instantiate()
	var skel: Skeleton3D = inst.find_child("Skeleton3D", true, false)
	if skel:
		print("Total bones: ", skel.get_bone_count())
		for i in range(skel.get_bone_count()):
			print("%d: %s (parent: %d)" % [i, skel.get_bone_name(i), skel.get_bone_parent(i)])
	quit(0)
