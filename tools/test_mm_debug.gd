extends SceneTree

func _init():
	var s = load("res://scenes/UI/MainMenu.tscn") as PackedScene
	var inst = s.instantiate()
	var t = inst.find_child("Title", true, false)
	print("Title node: ", t)
	if t:
		print("Title text: ", t.text)
	quit()
