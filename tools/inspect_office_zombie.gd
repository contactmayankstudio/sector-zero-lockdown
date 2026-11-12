@tool
extends SceneTree

func _init():
	for p in ["res://scenes/zombies/models/RealZombieBiker.scn", "res://scenes/zombies/models/RealTitanBrute.scn"]:
		var inst = load(p).instantiate()
		var ap = inst.find_children("*", "AnimationPlayer", true, false)
		if not ap.is_empty():
			print(p.get_file(), " anims: ", ap[0].get_animation_list())
		inst.free()
	quit()
