extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var ap = s.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for anim_name in ["Idle", "Walk", "Run"]:
		var a = ap.get_animation(anim_name)
		for i in range(a.get_track_count()):
			var p = a.track_get_path(i)
			if "Hips" in str(p):
				print(anim_name, p, "type:", a.track_get_type(i))
				if a.track_get_key_count(i) > 0:
					print("  val:", a.track_get_key_value(i, 0))
	quit(0)
