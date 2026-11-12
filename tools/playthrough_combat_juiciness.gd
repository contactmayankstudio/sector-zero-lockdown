extends SceneTree

var frame_count: int = 0
var scene_inst: Node3D = null
var player: Node3D = null
var hud: Node = null
var test_zombie: Node3D = null
var butcher_boss: Node3D = null
var phase: int = 0
var state_timer: float = 0.0

const REALISTIC_ZOMBIE_SCN = preload("res://assets/zombies/RealisticZombie.tscn")

func _process(delta: float):
	frame_count += 1
	state_timer += delta
	
	if frame_count == 1:
		print("[PLAYTHROUGH] Booting Mission 1 (UrbanStreet / Grove Street)...")
		var s = load("res://scenes/environments/UrbanStreet.tscn") as PackedScene
		scene_inst = s.instantiate()
		root.add_child(scene_inst)
		
	elif frame_count == 10:
		# Player and HUD are fully initialized now
		player = scene_inst.find_child("Player", true, false)
		var hud_nodes = get_nodes_in_group("hud")
		hud = hud_nodes[0] if not hud_nodes.is_empty() else null
		
		if player:
			print("[PLAYTHROUGH] Aiming down Grove Street road...")
			var cam = player.find_child("Camera3D", true, false)
			if cam:
				cam.rotation_degrees.x = -12.0
				
			print("[PLAYTHROUGH] Equipping AK-74u tactical rifle (weapons count: %d)..." % player.weapons.size())
			for idx in range(player.weapons.size()):
				var w = player.weapons[idx]
				if w.weapon_data and w.weapon_data.weapon_id == "ak74u":
					player.switch_to_weapon(idx)
					print("[PLAYTHROUGH] Switched to weapon index %d (%s)!" % [idx, w.weapon_data.display_name])
					break
					
	elif frame_count == 40 and phase == 0:
		# Capture Phase 1: AK-74u ready in combat stance aiming down road
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/live_gameplay_ak74u_combat.png")
			print("[SAVED] screenshots/live_gameplay_ak74u_combat.png")
		
		# Spawn test zombie directly in front for decapitation demonstration
		print("[PLAYTHROUGH] Spawning infected host directly in crosshairs...")
		test_zombie = REALISTIC_ZOMBIE_SCN.instantiate()
		test_zombie.archetype = "soldier"
		scene_inst.add_child(test_zombie)
		test_zombie.global_position = Vector3(0.0, 0.05, -3.2)
		test_zombie.look_at(player.global_position, Vector3.UP)
		phase = 1
		state_timer = 0.0
		
	elif phase == 1 and state_timer > 0.4:
		# Phase 2: Fire lethal headshot into the zombie
		print("[PLAYTHROUGH] FIRING LETHAL HEADSHOT INTO TARGET HEAD...")
		if test_zombie and is_instance_valid(test_zombie):
			test_zombie.take_damage(500.0, true, Vector3(0, 0, -1))
		phase = 2
		state_timer = 0.0
		
	elif phase == 2 and state_timer > 0.25:
		# Capture Phase 2: Decapitation & arterial blood fountain
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/live_gameplay_headshot_decapitation.png")
			print("[SAVED] screenshots/live_gameplay_headshot_decapitation.png (Decapitation & Arterial Spray!)")
		
		# Phase 3: Player sustains heavy melee claw damage
		print("[PLAYTHROUGH] Player sustains damage: dropping to 24 HP (< 30 HP)...")
		if player:
			player.take_damage(76.0)
		phase = 3
		state_timer = 0.0
		
	elif phase == 3 and state_timer > 0.45:
		# Capture Phase 3: Dynamic screen blood splatters + pulsating cardiac vignette + heartbeat
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/live_gameplay_blood_splatter_heartbeat.png")
			print("[SAVED] screenshots/live_gameplay_blood_splatter_heartbeat.png (Screen Blood & Cardiac Vignette!)")
		
		# Heal player slightly and spawn The Butcher Giant Boss for Wave 3!
		print("[PLAYTHROUGH] Spawning Wave 3 Giant Alpha: THE BUTCHER BOSS...")
		if player:
			player.current_health = 75.0
			if hud and hud.has_method("update_health"):
				hud.update_health(75.0, 100.0)
				
		butcher_boss = REALISTIC_ZOMBIE_SCN.instantiate()
		butcher_boss.archetype = "boss"
		scene_inst.add_child(butcher_boss)
		butcher_boss.global_position = Vector3(0.0, 0.05, -5.5)
		butcher_boss.scale = Vector3(1.35, 1.35, 1.35)
		butcher_boss.look_at(player.global_position, Vector3.UP)
		
		var event_bus = root.get_node_or_null("EventBus")
		if event_bus and event_bus.has_signal("boss_health_changed"):
			event_bus.boss_health_changed.emit(800.0, 800.0)
			
		phase = 4
		state_timer = 0.0
		
	elif phase == 4 and state_timer > 0.6:
		# Capture Phase 4: Wave 3 Butcher Boss showdown with Boss Health Bar
		var vp = root.get_viewport()
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("screenshots/live_gameplay_butcher_boss_wave3.png")
			print("[SAVED] screenshots/live_gameplay_butcher_boss_wave3.png (The Butcher Boss Showdown!)")
		
		# Phase 5: Deliver final fatal blow and trigger slow-mo & result dossier
		print("[PLAYTHROUGH] Delivering final blow to The Butcher Boss! Engaging Bullet-Time Slow-Mo Cam...")
		if butcher_boss and is_instance_valid(butcher_boss):
			butcher_boss.take_damage(850.0, true, Vector3(0, 0, -1))
			
		var mission_mgr = root.get_node_or_null("MissionManager")
		if mission_mgr:
			if mission_mgr.current_mission == null:
				mission_mgr.current_mission = load("res://resources/missions/mission_01.tres")
			mission_mgr.kill_count = 15
			mission_mgr.headshots = 12
			mission_mgr.boss_kill_count = 1
			mission_mgr.finish_mission(true)
			
		phase = 5
		state_timer = 0.0
		
	elif phase == 5:
		# Check if ResultUI is showing
		var result_ui = scene_inst.find_child("ResultUI", true, false)
		if result_ui and result_ui.visible and state_timer > 1.8:
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png("screenshots/live_gameplay_slowmo_victory_dossier.png")
				print("[SAVED] screenshots/live_gameplay_slowmo_victory_dossier.png (Victory Dossier Post-Slow-Mo!)")
			print("\n🎉 ALL LIVE GAMEPLAY PLAYTHROUGH SCREENSHOTS CAPTURED SUCCESSFULLY!")
			quit(0)
		elif state_timer > 5.0:
			var vp = root.get_viewport()
			var img = vp.get_texture().get_image()
			if img:
				img.save_png("screenshots/live_gameplay_slowmo_victory_dossier.png")
			quit(0)
