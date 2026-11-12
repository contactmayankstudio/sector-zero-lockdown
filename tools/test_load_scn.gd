
extends SceneTree

func _init():
	var t0 = Time.get_ticks_msec()
	var sc = load("res://scenes/zombies/models/RealDoomZombie.scn")
	var t1 = Time.get_ticks_msec()
	print("Loaded binary .scn in ", (t1 - t0), " ms!")
	quit(0)
