extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var ap = s.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for anim_name in ["RifleAimIdle", "Idle"]:
		var a = ap.get_animation(anim_name)
		print(anim_name, "track count:", a.get_track_count())
		for i in range(min(5, a.get_track_count())):
			print("  ", a.track_get_path(i), "type:", a.track_get_type(i))
			if a.track_get_key_count(i) > 0:
				print("    val 0:", a.track_get_key_value(i, 0))
	quit(0)
