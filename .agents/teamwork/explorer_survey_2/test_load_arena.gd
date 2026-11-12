@tool
extends SceneTree

func _init():
	print("Checking CityCarZombieArena scene loading...")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		push_error("Failed to load scene")
		quit(1)
		return
	var inst = scn.instantiate()
	print("Scene instantiated successfully! Node count: ", inst.get_child_count())
	inst.free()
	quit(0)
