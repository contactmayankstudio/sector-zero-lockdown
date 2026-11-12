extends SceneTree

func _init():
	var dog_sc = load("res://scenes/zombies/InfectedDog.tscn")
	var dog = dog_sc.instantiate()
	print("InfectedDog instantiated successfully! Child count: ", dog.get_child_count())
	dog.free()
	quit(0)
