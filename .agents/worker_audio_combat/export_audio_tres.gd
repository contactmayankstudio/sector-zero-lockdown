extends SceneTree

func _init():
	var audio_targets = [
		"res://audio/weapons/sfx_minigun_shoot",
		"res://audio/weapons/sfx_flatline_shoot",
		"res://audio/weapons/sfx_car_shoot",
		"res://audio/weapons/sfx_hawk_shoot",
		"res://audio/weapons/sfx_sniper_shoot",
		"res://audio/weapons/sfx_reload_shotgun",
		"res://audio/weapons/sfx_reload_bolt",
		"res://audio/weapons/sfx_reload_slide",
		"res://audio/weapons/sfx_reload_mag",
		"res://audio/impacts/sfx_headshot_crunch",
		"res://audio/impacts/sfx_bone_break",
		"res://audio/ambience/sfx_horror_drone"
	]
	
	print("--- EXPORTING NATIVE AUDIOSTREAMWAV .TRES RESOURCES ---")
	for base_path in audio_targets:
		var wav_path = base_path + ".wav"
		var tres_path = base_path + ".tres"
		var stream = load(wav_path) as AudioStreamWAV
		if stream:
			var err = ResourceSaver.save(stream, tres_path)
			print("Saved %s -> error code: %d" % [tres_path, err])
			var test_load = load(tres_path)
			print("Verified reload %s: %s (class: %s)" % [tres_path, test_load != null, test_load.get_class() if test_load else "null"])
		else:
			printerr("Failed to load source: %s" % wav_path)
	quit()
