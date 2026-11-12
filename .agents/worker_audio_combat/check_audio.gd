extends SceneTree

func _init():
	var test_files = [
		"res://audio/weapons/sfx_minigun_shoot.wav",
		"res://audio/weapons/sfx_flatline_shoot.wav",
		"res://audio/weapons/sfx_car_shoot.wav",
		"res://audio/weapons/sfx_hawk_shoot.wav",
		"res://audio/weapons/sfx_sniper_shoot.wav",
		"res://audio/weapons/sfx_reload_shotgun.wav",
		"res://audio/weapons/sfx_reload_bolt.wav",
		"res://audio/weapons/sfx_reload_slide.wav",
		"res://audio/weapons/sfx_reload_mag.wav",
		"res://audio/impacts/sfx_headshot_crunch.wav",
		"res://audio/impacts/sfx_bone_break.wav",
		"res://audio/ambience/sfx_horror_drone.wav"
	]
	print("--- CHECKING AUDIO LOADS ---")
	for path in test_files:
		var exists = ResourceLoader.exists(path)
		var res = load(path) if exists else null
		print("Path: %s | Exists: %s | Loaded: %s | Type: %s" % [path, exists, res != null, res.get_class() if res else "null"])
	quit()
