extends SceneTree

func _init():
	var path = "res://scenes/environments/models/RealApartment.scn"
	print("Loading ", path, " (size: ", FileAccess.get_file_as_bytes(path).size() / (1024*1024), " MB)...")
	var scn = load(path) as PackedScene
	if not scn:
		print("Failed to load scene")
		quit(1)
		return
	var err = ResourceSaver.save(scn, path, ResourceSaver.FLAG_COMPRESS)
	print("Compressed RealApartment.scn saved with code: ", err)
	var new_size = FileAccess.get_file_as_bytes(path).size() / (1024*1024)
	print("New size: ", new_size, " MB")
	quit(0)
