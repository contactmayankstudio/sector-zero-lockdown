@tool
extends SceneTree

func _init():
	print("--- TEST ZOMBIE SPAWN & Y PHYSICS ---")
	var scene_res = load("res://scenes/environments/UrbanStreet.tscn")
	var scene = scene_res.instantiate()
	root.add_child(scene)
	
	for i in range(5):
		await process_frame
		
	var spawner = scene.find_child("ZombieSpawner", true, false)
	print("ZombieSpawner found: ", spawner != null)
	
	# Observe first 120 frames
	for frame in range(120):
		await physics_frame
		var zombies = root.find_children("*", "CharacterBody3D", true, false)
		for z in zombies:
			if z.name != "Player" and z.is_in_group("zombies"):
				print("Frame %d | Zombie %s | pos: %s | on_floor: %s | vel.y: %.2f" % [
					frame, z.name, str(z.global_position), z.is_on_floor(), z.velocity.y
				])
				
	scene.queue_free()
	print("--- TEST COMPLETE ---")
	quit(0)
