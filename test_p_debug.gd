extends SceneTree

func _init():
	var p = load("res://scenes/player/Player.tscn").instantiate()
	root.add_child(p)
	p.take_damage(20.0)
	print("HP after 20: ", p.current_health)
	p.take_damage(200.0)
	print("Dead after 200: ", p.is_dead)
	var dead = p.is_dead
	p.free()
	quit(0 if dead else 1)
