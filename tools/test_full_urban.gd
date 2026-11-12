
extends SceneTree
func _init():
	var scene = load("res://scenes/environments/UrbanStreet.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	print("UrbanStreet added to scene root!")
	
	var p = inst.get_node("Player")
	print("Player pos:", p.global_position)
	
	var grove = inst.get_node("GTAGroveStreet")
	print("Grove Street pos:", grove.position, " scale:", grove.scale)
	
	var ground = inst.get_node("NavigationRegion3D/Ground")
	print("Ground pos:", ground.position)
	
	var spawner = inst.get_node("ZombieSpawner")
	print("Spawner points count:", spawner.spawn_points.size())
	for sp in spawner.spawn_points:
		print("  Spawn point:", sp.name, " pos:", sp.global_position)
		
	quit(0)
