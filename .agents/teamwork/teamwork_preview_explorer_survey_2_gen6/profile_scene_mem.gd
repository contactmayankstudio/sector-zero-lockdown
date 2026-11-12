extends SceneTree

func _init():
	print("--- Testing CityCarZombieArena Memory Footprint ---")
	var mem_before = OS.get_static_memory_usage()
	print("Static memory before load: ", mem_before / (1024 * 1024), " MB")
	
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	print("Scene loaded from disk. Memory: ", OS.get_static_memory_usage() / (1024 * 1024), " MB")
	
	print("Instantiating scene...")
	var arena = scn.instantiate()
	print("Scene instantiated! Memory: ", OS.get_static_memory_usage() / (1024 * 1024), " MB")
	
	get_root().add_child(arena)
	print("Scene added to tree! Memory: ", OS.get_static_memory_usage() / (1024 * 1024), " MB")
	
	arena.queue_free()
	quit(0)
