
extends SceneTree
func _init():
	var res = load("res://scenes/player/Player.tscn")
	if not res:
		print("FAILED to load Player.tscn")
		quit(1)
		return
	var inst = res.instantiate()
	print("SUCCESS! Instantiated Player.tscn:", inst.name)
	quit(0)
