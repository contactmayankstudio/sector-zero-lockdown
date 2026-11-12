extends SceneTree

func _init():
	print("--- INSPECTING CAMPAIGN MISSIONS 1-12 & ENDLESS ---")
	for i in range(1, 13):
		var path = "res://resources/missions/mission_%02d.tres" % i
		_inspect(path)
	
	_inspect_endless("res://resources/missions/mission_endless.tres")
	quit(0)

func _inspect(path: String):
	var m = load(path) as MissionData
	if not m:
		print("FAILED TO LOAD: ", path)
		return
	print("--------------------------------------------------")
	print("MISSION: ", m.mission_id, " (", m.display_name, ")")
	print("  File: ", path)
	print("  Location: ", m.location_name)
	print("  Scene: ", m.scene_path, " (Exists: ", ResourceLoader.exists(m.scene_path), ")")
	print("  Objective Type: ", m.objective_type, " (0=KILL, 1=SURVIVE, 2=BOSS)")
	print("  Target Count: ", m.target_count)
	print("  Wave Count (property): ", m.wave_count)
	print("  Waves Array Size: ", m.waves.size())
	print("  Reward Cash: $", m.reward_cash)
	print("  Unlock Req: '", m.unlock_requirement_id, "'")
	
	var total_enemies_waves_1_to_3 = 0
	var total_all_waves = 0
	for w_idx in range(m.waves.size()):
		var w = m.waves[w_idx]
		var w_num = w.get("wave_num", w_idx + 1)
		var groups = w.get("groups", [])
		var w_enemies = 0
		var group_descs = []
		for g in groups:
			var e_type = g.get("enemy_type", "normal")
			var count = g.get("count", 0)
			var dir = g.get("spawn_direction", "")
			var delay = g.get("delay", 0.0)
			w_enemies += count
			group_descs.append("%dx %s (%s, delay=%.1fs)" % [count, e_type, dir, delay])
		if w_idx < 3:
			total_enemies_waves_1_to_3 += w_enemies
		total_all_waves += w_enemies
		print("  Wave %d (idx %d): %d enemies -> %s" % [w_num, w_idx, w_enemies, ", ".join(group_descs)])
	
	print("  SUMMARY: Waves 1-3 enemies = %d; Total in array = %d; Target count = %d" % [total_enemies_waves_1_to_3, total_all_waves, m.target_count])
	if m.waves.size() > 3:
		print("  *** WARNING: Residual waves detected! waves.size() = %d, wave_count = %d" % [m.waves.size(), m.wave_count])
	if m.objective_type == MissionData.ObjectiveType.KILL_COUNT and total_enemies_waves_1_to_3 != m.target_count:
		print("  *** WARNING: KILL_COUNT target (%d) != wave 1-3 enemy sum (%d)" % [m.target_count, total_enemies_waves_1_to_3])

func _inspect_endless(path: String):
	var m = load(path) as MissionData
	if not m:
		print("FAILED TO LOAD: ", path)
		return
	print("==================================================")
	print("ENDLESS MISSION: ", m.mission_id, " (", m.display_name, ")")
	print("  File: ", path)
	print("  Location: ", m.location_name)
	print("  Scene: ", m.scene_path, " (Exists: ", ResourceLoader.exists(m.scene_path), ")")
	print("  Objective Type: ", m.objective_type)
	print("  Wave Count: ", m.wave_count)
	print("  Target Count: ", m.target_count)
	print("  Is Endless: ", m.is_endless)
	print("  Unlock Req: '", m.unlock_requirement_id, "'")
	print("  Endless Base Count: ", m.endless_base_count)
	print("  Endless Scale Per Wave: ", m.endless_scale_per_wave)
	print("  Waves array size: ", m.waves.size())
