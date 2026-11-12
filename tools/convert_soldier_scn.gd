extends SceneTree

func _init():
	var scn = load("res://scenes/characters/RealSoldier.tscn")
	if scn:
		var err = ResourceSaver.save(scn, "res://scenes/characters/RealSoldier.scn")
		print("Saved RealSoldier.scn status: ", err)
	quit(0)
