@tool
extends SceneTree

func _init():
	print("=== TESTING DINOSAUR SCALE & 3D HEALTH BAR SYSTEM ===")
	
	# 1. Test Dinosaur Size & Properties
	var dog_scn = load("res://scenes/zombies/InfectedDog.tscn")
	var dog = dog_scn.instantiate()
	get_root().add_child(dog)
	dog._resolve_nodes()
	dog._apply_archetype()
	
	print("\n--- 1. DINOSAUR VALIDATION ---")
	print("Dinosaur Archetype: ", dog.archetype)
	print("Dinosaur HP: ", dog.health_component.max_health)
	assert(dog.health_component.max_health >= 70.0, "Dinosaur max_health should be at least 70")
	print("Dinosaur Scale: ", dog.scale)
	assert(dog.scale.x >= 1.4, "Dinosaur scale should be >= 1.4x")
	print("Dinosaur Move Speed: ", dog.move_speed)
	print("Dinosaur Attack Damage: ", dog.attack_damage)
	assert(dog.attack_damage >= 18.0, "Dinosaur damage should be >= 18.0")
	
	var dog_col: CollisionShape3D = dog.get_node("CollisionShape3D")
	print("Dinosaur Collision Size: ", dog_col.shape.size)
	assert(dog_col.shape.size.z >= 3.0, "Dinosaur collision length should match 1.5x scale")
	print("[PASS] Dinosaur is successfully scaled up to 1.5x!")
	
	# 2. Test 3D Overhead Health Bar on Regular Zombie
	var z_scn = load("res://scenes/zombies/Zombie.tscn")
	var zombie = z_scn.instantiate()
	zombie.archetype = "normal"
	get_root().add_child(zombie)
	zombie._ready()
	zombie.health_component.max_health = 100.0
	zombie.health_component.current_health = 100.0
	zombie.health_bar_3d.setup(100.0, 2.2)
	
	print("\n--- 2. OVERHEAD HEALTH BAR VALIDATION ---")
	assert(zombie.health_bar_3d != null, "Zombie should have health_bar_3d component")
	print("HealthBar3D Initial Position Y: ", zombie.health_bar_3d.position.y)
	print("HealthBar3D Initial Active: ", zombie.health_bar_3d.is_active)
	assert(not zombie.health_bar_3d.is_active, "Health bar should be hidden before being shot")
	
	# Simulate shooting body
	print("\nSimulating Body Shot (25 Damage)...")
	zombie.take_damage(25.0, false, Vector3(0, 0, -1))
	assert(zombie.health_bar_3d.is_active, "Health bar should activate upon taking damage")
	print("HealthBar3D Current Health: ", zombie.health_bar_3d.current_health, " / ", zombie.health_bar_3d.max_health)
	print("HealthBar3D Damage Popup Text: ", zombie.health_bar_3d.label_damage.text)
	assert(zombie.health_bar_3d.label_damage.text == "-25", "Damage popup should show -25")
	assert(zombie.health_bar_3d.current_health == 75.0, "Current health should be 75.0")
	print("[PASS] Body shot activates health bar and displays '-25' damage popup!")
	
	# Simulate headshot
	print("\nSimulating Headshot (25 Damage)...")
	zombie.take_damage(25.0, true, Vector3(0, 0, -1))
	print("HealthBar3D Damage Popup Text: ", zombie.health_bar_3d.label_damage.text)
	assert("CRIT" in zombie.health_bar_3d.label_damage.text, "Headshot popup should show CRIT")
	assert(zombie.health_bar_3d.current_health == 50.0, "Current health should be 50.0")
	print("[PASS] Headshot displays 'CRIT -25!' damage popup in gold!")
	
	# Check death behavior
	print("\nSimulating Fatal Shot (50 Damage)...")
	zombie.take_damage(50.0, false, Vector3(0, 0, -1))
	assert(zombie.is_dead, "Zombie should be dead after lethal damage")
	assert(not zombie.health_bar_3d.is_active, "Health bar should hide immediately on death")
	print("[PASS] Health bar hides immediately on zombie death!")
	
	dog.queue_free()
	zombie.queue_free()
	
	print("\n==========================================")
	print("ALL DINOSAUR & HEALTH BAR TESTS PASSED 100%!")
	print("==========================================")
	quit(0)
