extends SceneTree

func _init():
	var arena_res = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not arena_res:
		print("Failed to load CityCarZombieArena.tscn")
		quit(1)
		return

	var arena = arena_res.instantiate()
	get_root().add_child(arena)

	var verify_script = load("res://tools/test_visual_verification.gd")
	var verify_node = Node.new()
	verify_node.set_script(verify_script)
	arena.add_child(verify_node)
