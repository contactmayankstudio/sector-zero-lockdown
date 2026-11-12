extends SceneTree

func _init():
	print("--- TESTING LOAD REALISTIC ZOMBIE ---")
	var res = load("res://assets/zombies/RealisticZombie.tscn")
	print("Loaded RealisticZombie: ", res)
	if res:
		var inst = res.instantiate()
		print("Instantiated: ", inst)
		inst.free()
	quit(0)
