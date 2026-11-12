@tool
extends SceneTree

func _init():
	var p = "res://scenes/zombies/models/zombie_realistic_human.scn"
	var inst = load(p).instantiate()
	var ap = inst.find_children("*", "AnimationPlayer", true, false)
	if not ap.is_empty():
		for anim in ap[0].get_animation_list():
			print("Anim: ", anim)
	inst.free()
	quit()
