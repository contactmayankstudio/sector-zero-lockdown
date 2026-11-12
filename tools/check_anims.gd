extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var ap = s.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap:
		print("Animations in RealSoldier:", ap.get_animation_list())
	quit(0)
