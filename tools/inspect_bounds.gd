extends SceneTree

func _init():
	var boss_sc = load("res://scenes/zombies/models/RealButcherBoss.scn")
	var b = boss_sc.instantiate()
	print("--- Butcher Boss ---")
	_inspect_bounds(b)
	b.free()
	
	var ammo_sc = load("res://scenes/pickups/AmmoPickupModel.scn")
	var a = ammo_sc.instantiate()
	print("--- Ammo Model ---")
	_inspect_bounds(a)
	a.free()
	
	quit(0)

func _inspect_bounds(node: Node):
	for c in node.get_children():
		if c is VisualInstance3D:
			var aabb = c.get_aabb()
			print("Visual: ", c.name, " aabb size: ", aabb.size, " aabb pos: ", aabb.position)
		_inspect_bounds(c)
