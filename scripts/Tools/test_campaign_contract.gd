extends SceneTree

var passed := 0
var failed := 0

func _init():
	await process_frame
	print("\n==================================================")
	print("CAMPAIGN CONTRACT TEST")
	print("==================================================")

	for mission_index in range(1, 13):
		_check_mission("res://resources/missions/mission_%02d.tres" % mission_index)

	print("\n==================================================")
	print("CAMPAIGN CONTRACT SUMMARY: %d PASSED, %d FAILED" % [passed, failed])
	print("==================================================")
	quit(1 if failed > 0 else 0)

func _check_mission(path: String):
	var mission = load(path) as MissionData
	_check("Mission resource loads: %s" % path, mission != null)
	if not mission:
		return

	_check("Exactly three configured waves: %s" % mission.mission_id, mission.wave_count == 3 and mission.waves.size() == 3)
	_check("Scene exists: %s" % mission.mission_id, ResourceLoader.exists(mission.scene_path))
	if not ResourceLoader.exists(mission.scene_path):
		return

	var scene_text = FileAccess.get_file_as_string(mission.scene_path)
	_check("Scene text readable: %s" % mission.mission_id, scene_text != "")
	if scene_text == "":
		return

	var spawn_names := {}
	for direction in ["front", "back", "left", "right"]:
		if scene_text.contains('name="Spawn%s' % direction.capitalize()):
			spawn_names[direction] = true

	for wave in mission.waves:
		for group in wave.get("groups", []):
			var direction = str(group.get("spawn_direction", "")).to_lower()
			if direction == "":
				continue
			_check("Spawn direction %s: %s" % [direction, mission.mission_id], _has_direction(spawn_names, direction))

	# Requirement 4: Verify boss missions do not finish prematurely before the final configured wave
	if mission.objective_type == MissionData.ObjectiveType.BOSS_KILL:
		var boss_in_early_wave = false
		for i in range(mission.waves.size() - 1):
			for group in mission.waves[i].get("groups", []):
				if group.get("enemy_type") == "boss":
					boss_in_early_wave = true
		_check("Boss not spawned in early waves: %s" % mission.mission_id, not boss_in_early_wave)

		var boss_in_final_wave = false
		if not mission.waves.is_empty():
			for group in mission.waves.back().get("groups", []):
				if group.get("enemy_type") == "boss":
					boss_in_final_wave = true
		_check("Boss spawned in final wave: %s" % mission.mission_id, boss_in_final_wave)

		var mm = get_root().get_node_or_null("MissionManager")
		if mm:
			var prev_mission = mm.current_mission
			mm.current_mission = mission
			mm.kill_count = 10
			mm.boss_kill_count = mission.target_count
			mm._is_finishing = false

			mm.wave_count = 1
			mm.check_objective()
			_check("Boss mission does not finish at wave 1: %s" % mission.mission_id, not mm._is_finishing and mm.current_mission == mission)

			mm.wave_count = 2
			mm.check_objective()
			_check("Boss mission does not finish at wave 2: %s" % mission.mission_id, not mm._is_finishing and mm.current_mission == mission)

			mm.wave_count = 3
			mm.check_objective()
			_check("Boss mission completes at wave 3: %s" % mission.mission_id, mm._is_finishing or mm.current_mission == null)

			mm.current_mission = prev_mission
			mm._is_finishing = false

func _has_direction(spawn_names: Dictionary, direction: String) -> bool:
	for spawn_name in spawn_names.keys():
		if spawn_name.contains(direction):
			return true
	return false

func _check(label: String, condition: bool):
	if condition:
		passed += 1
		print("[PASS] %s" % label)
	else:
		failed += 1
		printerr("[FAIL] %s" % label)
