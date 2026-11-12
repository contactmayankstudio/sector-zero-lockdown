extends SceneTree

func _init():
	var sc = load("res://scenes/zombies/models/zombie_normal.tscn")
	if sc:
		var inst = sc.instantiate()
		print("Root name: ", inst.name, " class: ", inst.get_class())
		var anims = inst.find_children("*", "AnimationPlayer", true, false)
		print("AnimPlayers in zombie_normal.tscn: ", anims.size())
		for a in anims:
			print("Anims: ", a.get_animation_list())
		inst.free()
	quit(0)
