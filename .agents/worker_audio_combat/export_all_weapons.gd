extends SceneTree

func _init():
	var dir = DirAccess.open("res://audio/weapons")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				var base_name = file_name.trim_suffix(".wav")
				var wav_path = "res://audio/weapons/" + file_name
				var tres_path = "res://audio/weapons/" + base_name + ".tres"
				var stream = load(wav_path) as AudioStreamWAV
				if stream:
					var err = ResourceSaver.save(stream, tres_path)
					print("Exported %s (err %d)" % [tres_path, err])
			file_name = dir.get_next()
	quit()
