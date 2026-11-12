extends SceneTree

func _init():
	var hound_sc = load("res://scenes/zombies/models/RealInfectedHound.scn")
	var inst = hound_sc.instantiate()
	print("Hound inst: ", inst.name)
	for c in inst.find_children("*", "VisualInstance3D", true, false):
		print("  Mesh: ", c.name, " aabb: ", c.get_aabb())
	for c in inst.find_children("*", "AnimationPlayer", true, false):
		print("  AnimPlayer: ", c.name, " anims: ", c.get_animation_list())
	inst.free()
	quit(0)
