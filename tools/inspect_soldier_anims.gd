extends SceneTree

func _init():
	var s_res = load("res://scenes/characters/RealSoldier.tscn")
	var s = s_res.instantiate()
	var anim: AnimationPlayer = s.find_child("AnimationPlayer", true, false)
	if anim:
		for a_name in anim.get_animation_list():
			var a = anim.get_animation(a_name)
			print("Animation: ", a_name, " tracks: ", a.get_track_count())
			for t in range(min(5, a.get_track_count())):
				print("   track ", t, ": ", a.track_get_path(t))
	s.queue_free()
	quit(0)
