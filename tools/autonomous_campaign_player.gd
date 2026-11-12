@tool
extends SceneTree

# Autonomous AI Campaign Player
# Automatically plays through campaign missions, aiming at zombie heads,
# firing weapons, reloading, dodging, and recording mission results!

var mission_files = [
	"res://resources/missions/campaign/mission_01_01.tres",
	"res://resources/missions/campaign/mission_01_02.tres",
	"res://resources/missions/campaign/mission_01_03.tres",
	"res://resources/missions/campaign/mission_01_04.tres",
	"res://resources/missions/campaign/mission_01_05.tres",
	"res://resources/missions/campaign/mission_01_06.tres",
	"res://resources/missions/campaign/mission_01_07.tres"
]

var current_mission_idx: int = 0
var active_scene: Node = null
var is_playing_mission: bool = false
var mission_results: Array = []

func _init():
	print("==================================================")
	print("   AUTONOMOUS AI CAMPAIGN PLAYTHROUGH INITIALIZED")
	print("==================================================")
	Engine.time_scale = 3.0 # Fast-forward for smooth execution
	_play_next_mission()

func _play_next_mission():
	if current_mission_idx >= mission_files.size():
		_finish_campaign_report()
		return
		
	var m_path = mission_files[current_mission_idx]
	print("\n>>> STARTING MISSION [%d/%d]: %s" % [current_mission_idx + 1, mission_files.size(), m_path.get_file()])
	
	var m_res: MissionData = load(m_path)
	if not m_res:
		print("Failed loading mission: ", m_path)
		current_mission_idx += 1
		_play_next_mission()
		return
		
	var scene_path = m_res.scene_path if m_res.scene_path != "" else "res://scenes/environments/AirportTerminal.tscn"
	var packed_scene = load(scene_path)
	if not packed_scene:
		print("Failed loading scene: ", scene_path)
		current_mission_idx += 1
		_play_next_mission()
		return
		
	if active_scene:
		active_scene.queue_free()
		for f in range(2):
			await process_frame
			
	active_scene = packed_scene.instantiate()
	root.add_child(active_scene)
	
	# Connect to MissionManager
	var mission_mgr = root.get_node_or_null("/root/MissionManager")
	if not mission_mgr:
		mission_mgr = active_scene.find_child("MissionManager", true, false)
		
	if mission_mgr:
		mission_mgr.current_mission = m_res
		mission_mgr.kill_count = 0
		mission_mgr.wave_count = 0
		mission_mgr.boss_kill_count = 0
		mission_mgr.shots_fired = 0
		mission_mgr.shots_hit = 0
		mission_mgr.headshots = 0
		mission_mgr.score = 0
		mission_mgr._is_finishing = false
		
	# Wait for nodes to initialize
	for f in range(6):
		await process_frame
		
	var player = active_scene.find_child("Player", true, false)
	var spawner = active_scene.find_child("ZombieSpawner", true, false)
	
	if spawner:
		spawner.mission = m_res
		spawner.current_wave = 0
		spawner.start_next_wave()
		
	_run_ai_player_loop(player, m_res, mission_mgr)

func _run_ai_player_loop(player: Node, m_res: MissionData, mission_mgr: Node):
	is_playing_mission = true
	var mission_timer = 0.0
	var max_duration = 120.0 # Safety limit per mission
	var fire_cooldown = 0.0
	var last_logged_kills = -1
	
	if mission_mgr:
		var on_complete = func(_m):
			if is_playing_mission:
				print(">>> [VICTORY] Mission %s completed in %.1fs!" % [m_res.display_name, mission_timer])
				_record_victory(m_res, mission_mgr, mission_timer)
				is_playing_mission = false
		mission_mgr.mission_completed.connect(on_complete, CONNECT_ONE_SHOT)
	
	while is_playing_mission and mission_timer < max_duration:
		await process_frame
		var dt = 0.0166 * Engine.time_scale
		mission_timer += dt
		fire_cooldown -= dt
		
		# Find all alive zombies
		var living_zombies: Array = []
		for z in root.find_children("*", "CharacterBody3D", true, false):
			if z != player and z.is_in_group("zombies") and not z.get("is_dead"):
				living_zombies.append(z)
				
		# Fallback completion check
		if mission_mgr:
			match m_res.objective_type:
				MissionData.ObjectiveType.KILL_COUNT:
					if mission_mgr.kill_count >= m_res.target_count and is_playing_mission:
						print(">>> [VICTORY:KILL_COUNT] %d kills reached!" % m_res.target_count)
						_record_victory(m_res, mission_mgr, mission_timer)
						is_playing_mission = false
						break
				MissionData.ObjectiveType.SURVIVE_WAVES:
					if mission_mgr.wave_count >= m_res.wave_count and is_playing_mission:
						print(">>> [VICTORY:WAVES] %d waves cleared!" % m_res.wave_count)
						_record_victory(m_res, mission_mgr, mission_timer)
						is_playing_mission = false
						break
				MissionData.ObjectiveType.BOSS_KILL:
					if mission_mgr.boss_kill_count >= m_res.target_count and is_playing_mission:
						print(">>> [VICTORY:BOSS] Boss killed!")
						_record_victory(m_res, mission_mgr, mission_timer)
						is_playing_mission = false
						break
						
		# AI Combat Behavior
		if player and is_instance_valid(player) and not player.get("is_dead"):
			# 1. Find nearest priority zombie
			var target_zombie = null
			var min_dist = 9999.0
			for z in living_zombies:
				var d = player.global_position.distance_to(z.global_position)
				if d < min_dist:
					min_dist = d
					target_zombie = z
					
			if target_zombie and is_instance_valid(target_zombie):
				# Target Head
				var head_zone = target_zombie.find_child("*HeadHitZone*", true, false)
				var aim_pos = head_zone.global_position if head_zone else (target_zombie.global_position + Vector3(0, 1.7, 0))
				
				# Smooth Aim towards Head
				var cam = player.get_node_or_null("Camera3D")
				if cam:
					var dir_to_head = (aim_pos - cam.global_position).normalized()
					var forward = -cam.global_transform.basis.z
					var dot = forward.dot(dir_to_head)
					
					# Look at head
					var look_tf = cam.global_transform.looking_at(aim_pos, Vector3.UP)
					var euler = look_tf.basis.get_euler()
					player.rotation.y = euler.y
					cam.rotation.x = clamp(euler.x, deg_to_rad(-60.0), deg_to_rad(60.0))
					
					# 2. Tactical Fire
					if dot > 0.92 and fire_cooldown <= 0.0:
						fire_cooldown = 0.10 # Rapid fire burst
						if player.has_method("_trigger_shoot"):
							player._trigger_shoot()
							
					# 3. Auto Reload
					var curr_w = player.get_current_weapon() if player.has_method("get_current_weapon") else null
					if curr_w and curr_w.current_ammo == 0 and not curr_w.is_reloading:
						if player.has_method("_trigger_reload"):
							player._trigger_reload()
							
				# 4. Tactical Movement & Kiting
				var move_vec = Vector2.ZERO
				if min_dist < 4.0:
					move_vec.y = 1.0 # Back up
					move_vec.x = 0.5 if (int(mission_timer * 2) % 2 == 0) else -0.5 # Strafe
				elif min_dist > 12.0:
					move_vec.y = -0.6 # Advance
				player.set_virtual_movement(move_vec)
				
		# Progress log every 3 kills
		if mission_mgr and mission_mgr.kill_count != last_logged_kills and mission_mgr.kill_count % 3 == 0:
			last_logged_kills = mission_mgr.kill_count
			print("  [COMBAT] Kills: %d/%d | Waves: %d/%d | HP: %.0f | Time: %.1fs" % [
				mission_mgr.kill_count, m_res.target_count,
				mission_mgr.wave_count, m_res.wave_count,
				player.current_health if player else 0.0, mission_timer
			])
			
	current_mission_idx += 1
	_play_next_mission()

func _record_victory(m_res: MissionData, mission_mgr: Node, duration: float):
	var kills = mission_mgr.kill_count if mission_mgr else m_res.target_count
	var headshots = mission_mgr.headshots if mission_mgr else int(kills * 0.6)
	var cash = m_res.reward_cash
	
	var res_entry = {
		"id": m_res.mission_id,
		"name": m_res.display_name,
		"kills": kills,
		"headshots": headshots,
		"cash_reward": cash,
		"duration": "%.1fs" % duration,
		"stars": 3 if (headshots >= kills * 0.4) else 2
	}
	mission_results.append(res_entry)
	print("  + RESULTS: Kills: %d, Headshots: %d, Bounty: +%d Cash, Rating: %d Stars!" % [
		kills, headshots, cash, res_entry.stars
	])
	
	# Update SaveManager
	var save_mgr = root.get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.add_cash(cash)
		save_mgr.complete_mission(m_res.mission_id)
		save_mgr.set_mission_stars(m_res.mission_id, res_entry.stars)

func _finish_campaign_report():
	print("\n==================================================")
	print("   CAMPAIGN CHAPTER 1 PLAYTHROUGH SUMMARY")
	print("==================================================")
	var total_kills = 0
	var total_headshots = 0
	var total_cash = 0
	
	for r in mission_results:
		print("Mission %s: %s | Kills: %d | Headshots: %d | Time: %s | Stars: %s" % [
			r.id, r.name, r.kills, r.headshots, r.duration, "★".repeat(r.stars)
		])
		total_kills += r.kills
		total_headshots += r.headshots
		total_cash += r.cash_reward
		
	print("--------------------------------------------------")
	print("TOTAL MISSIONS CLEARED : %d / %d" % [mission_results.size(), mission_files.size()])
	print("TOTAL ZOMBIES KILLED   : %d" % total_kills)
	print("TOTAL HEADSHOTS        : %d (%.1f%%)" % [total_headshots, (float(total_headshots) / max(1, total_kills)) * 100.0])
	print("TOTAL CASH EARNED      : +%d CASH" % total_cash)
	print("==================================================")
	
	# Capture final screenshot
	var vp = root.get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		if img and not img.is_empty():
			img.save_png("screenshots/campaign_chapter1_cleared.png")
			print("Saved: screenshots/campaign_chapter1_cleared.png")
			
	quit(0)
