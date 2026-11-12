extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if scn:
		var err = ResourceSaver.save(scn, "res://scenes/environments/CityCarZombieArena.scn")
		print("Saved CityCarZombieArena.scn status: ", err)
	quit(0)
