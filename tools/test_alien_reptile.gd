extends SceneTree

func _init():
	var alien_sc = load("res://scenes/zombies/models/RealAlienMutant.scn")
	var a_inst = alien_sc.instantiate()
	print("Alien inst: ", a_inst.name)
	for c in a_inst.find_children("*", "AnimationPlayer", true, false):
		print("  Alien AnimPlayer: ", c.name, " anims: ", c.get_animation_list())
	for c in a_inst.find_children("*", "Skeleton3D", true, false):
		print("  Alien Skeleton: ", c.name, " bones: ", c.get_bone_count())
	a_inst.free()

	var rep_sc = load("res://scenes/zombies/models/RealReptileMutant.scn")
	var r_inst = rep_sc.instantiate()
	print("Reptile inst: ", r_inst.name)
	for c in r_inst.find_children("*", "VisualInstance3D", true, false):
		print("  Reptile mesh: ", c.name, " aabb: ", c.get_aabb())
	r_inst.free()
	quit(0)
