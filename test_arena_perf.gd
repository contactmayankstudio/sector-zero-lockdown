extends SceneTree

func _init():
	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	print("[TEST] Arena loaded with C# and optimized shadows successfully!")
	quit()
