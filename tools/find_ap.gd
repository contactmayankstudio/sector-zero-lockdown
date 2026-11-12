extends SceneTree
func _init():
	var s = load("res://scenes/characters/RealSoldier.scn").instantiate()
	var ap = s.find_child("AnimationPlayer", true, false)
	print("Found AnimationPlayer:", ap != null)
	if ap:
		print("Path:", ap.get_path())
	quit(0)
