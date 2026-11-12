@tool
extends SceneTree

func _init():
	print("=== TESTING BODY SHOT KILL AND WAVE PROGRESSION ===")
	var scene_res = load("res://scenes/environments/AirportTerminal.tscn")
	var game = scene_res.instantiate()
	root.add_child(game)
	
	for i in range(10):
		await process_frame
		
	var spawner = game.find_child("ZombieSpawner", true, false)
	var player = game.find_child("Player", true, false)
	
	# Wait for first zombie to spawn
	var test_zombie = null
	for f in range(60):
		await process_frame
		for z in root.find_children("*", "CharacterBody3D", true, false):
			if z != player and z.is_in_group("zombies") and not z.get("is_dead"):
				test_zombie = z
				break
		if test_zombie:
			break
			
	print("Spawned test zombie: ", test_zombie != null)
	if test_zombie:
		print("Zombie initial is_dead: ", test_zombie.is_dead)
		print("Simulating 3 body shots (chest zone)...")
		# Shoot chest zone (body shot, NOT headshot)
		var chest = test_zombie.find_child("*ChestHitZone*", true, false)
		if chest and chest.has_method("take_hit"):
			chest.take_hit(35.0, Vector3.FORWARD)
			chest.take_hit(35.0, Vector3.FORWARD)
		else:
			test_zombie.take_damage(70.0, false, Vector3.FORWARD)
			
		print("After body shots: zombie is_dead = ", test_zombie.is_dead)
		print("Is in group 'zombies': ", test_zombie.is_in_group("zombies"))
		
		# Check if queue_free happens
		for f in range(150): # ~2.5s
			await process_frame
			
		print("Zombie freed after 2.2s: ", not is_instance_valid(test_zombie))
		print("Spawner zombies_alive: ", spawner.zombies_alive if spawner else -1)
		
	game.queue_free()
	print("=== DONE TESTING BODY SHOT KILL ===")
	quit(0)
