extends SceneTree

func _init():
	var s = load("res://audio/ambience/sfx_horror_drone.tres") as AudioStreamWAV
	if s:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		var err = ResourceSaver.save(s, "res://audio/ambience/sfx_horror_drone.tres")
		print("Updated sfx_horror_drone.tres with loop_mode=1 (err: %d)" % err)
	quit()
