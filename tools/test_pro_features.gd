@tool
extends SceneTree

func _init():
	print("=== TESTING PRO FEATURES SUITE ===")
	
	# 1. Weapon Tracers
	print("\n--- 1. Validating Weapon Tracers ---")
	var weapon_scene = load("res://scenes/weapons/Weapon.tscn")
	var weapon = weapon_scene.instantiate()
	get_root().add_child(weapon)
	weapon._ready()
	weapon._spawn_bullet_tracer(Vector3(0, 1, 0), Vector3(0, 1, -10))
	var tracer = get_root().find_child("BulletTracer", true, false)
	if not tracer:
		tracer = weapon.get_node_or_null("BulletTracer")
	print("Bullet Tracer Node: ", tracer)
	assert(tracer != null, "Bullet tracer should spawn")
	print("[PASS] Bullet tracers active.")
	
	# 2. Overhead Health Bar & Damage Popups
	print("\n--- 2. Validating Overhead Health Bar & Damage Popups ---")
	var z_scn = load("res://scenes/zombies/Zombie.tscn")
	var zombie = z_scn.instantiate()
	zombie.archetype = "normal"
	get_root().add_child(zombie)
	zombie._ready()
	zombie.health_component.max_health = 100.0
	zombie.health_component.current_health = 100.0
	zombie.health_bar_3d.setup(100.0, 2.2)
	
	# Simulate body shot
	zombie.take_damage(30.0, false, Vector3(0, 0, -1))
	print("Damage Popup: ", zombie.health_bar_3d.label_damage.text)
	assert(zombie.health_bar_3d.label_damage.text == "-30", "Popup should show -30")
	
	# Simulate lethal headshot
	zombie.take_damage(80.0, true, Vector3(0, 0, -1))
	print("Lethal Headshot Popup: ", zombie.health_bar_3d.label_damage.text)
	assert("CRIT" in zombie.health_bar_3d.label_damage.text, "Lethal headshot should show CRIT")
	print("[PASS] Overhead health bar & damage popups active.")
	
	# 3. Loot Pickups
	print("\n--- 3. Validating Loot Pickups ---")
	var pickup_scene = load("res://scenes/pickups/AmmoPickup.tscn")
	var pickup = pickup_scene.instantiate()
	get_root().add_child(pickup)
	pickup.pickup_type = "health"
	pickup._setup_visuals()
	assert(pickup.label.text == "+HEALTH", "Health pickup should show +HEALTH")
	
	pickup.pickup_type = "cash"
	pickup._setup_visuals()
	assert(pickup.label.text == "+$150 CASH", "Cash pickup should show +$150 CASH")
	print("[PASS] Loot pickups (Ammo, Health, Cash) active.")
	
	# 4. Player Flashlight
	print("\n--- 4. Validating Player Flashlight (Torch) ---")
	var player_scene = load("res://scenes/player/Player.tscn")
	var player = player_scene.instantiate()
	get_root().add_child(player)
	player._ready()
	assert(player.has_method("toggle_flashlight"), "Player should have toggle_flashlight")
	player.toggle_flashlight()
	assert(player.flashlight != null, "Flashlight should exist")
	var f_vis1 = player.flashlight.visible
	player.toggle_flashlight()
	var f_vis2 = player.flashlight.visible
	assert(f_vis1 != f_vis2, "Flashlight should toggle visibility")
	print("[PASS] Flashlight toggle active.")
	
	# 5. HUD Torch Button
	print("\n--- 5. Validating HUD Controls & Group ---")
	var hud = player.get_node_or_null("HUD")
	assert(hud != null, "HUD should exist")
	assert(hud.is_in_group("hud"), "HUD should be in 'hud' group")
	var torch_btn = hud.find_child("FlashlightButton", true, false)
	assert(torch_btn != null, "HUD should have FlashlightButton")
	print("[PASS] HUD torch button and group active.")
	
	print("\n[SUCCESS] ALL PRO FEATURES TESTED AND VALIDATED SUCCESSFULLY!")
	quit(0)
