extends Node

signal mission_started(mission: MissionData)
signal mission_completed(mission: MissionData)
signal mission_failed(mission: MissionData)

var current_mission: MissionData = null
var kill_count: int = 0
var wave_count: int = 0
var boss_kill_count: int = 0
var current_wave_number: int = 0
var endless_run_cash: int = 0
var endless_cash_paid: int = 0
var shots_fired: int = 0
var shots_hit: int = 0
var headshots: int = 0
var score: int = 0

var last_stats: Dictionary = {
	"kills": 0,
	"headshots": 0,
	"score": 0,
	"accuracy": 0,
	"cash": 0,
	"success": false
}

var _is_finishing: bool = false

func _get_autoload(autoload_name: String) -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/" + autoload_name)
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null(autoload_name)
	return null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var event_bus = _get_autoload("EventBus")
	if event_bus:
		if not event_bus.weapon_fired.is_connected(_on_weapon_fired):
			event_bus.weapon_fired.connect(_on_weapon_fired)
		if not event_bus.damage_dealt.is_connected(_on_damage_dealt):
			event_bus.damage_dealt.connect(_on_damage_dealt)
		if not event_bus.enemy_killed.is_connected(_on_enemy_killed_event):
			event_bus.enemy_killed.connect(_on_enemy_killed_event)
		if not event_bus.wave_started.is_connected(_on_wave_started):
			event_bus.wave_started.connect(_on_wave_started)
	print("[%d ms] [BOOT:02] MissionManager ready." % Time.get_ticks_msec())

func _on_weapon_fired(_weapon_id: String, _cur: int, _max: int):
	shots_fired += 1

func _on_wave_started(wave_number: int, _total_waves: int):
	current_wave_number = max(current_wave_number, wave_number)
	if current_mission and current_mission.is_endless:
		var save_mgr = _get_autoload("SaveManager")
		if save_mgr and save_mgr.has_method("set_highest_wave"):
			save_mgr.set_highest_wave(current_wave_number)
		_notify_objective()

func _on_damage_dealt(_amount: float, is_headshot: bool, _hit_zone: String, _target: Node):
	shots_hit += 1
	if is_headshot:
		headshots += 1

func _on_enemy_killed_event(_archetype: String, is_headshot: bool, _pos: Vector3):
	if is_headshot and headshots == 0:
		headshots += 1
	if current_mission:
		var points = 100
		if is_headshot:
			points += 75
		if _archetype in ["heavy", "dog", "spitter", "special"]:
			points += 50
		if _archetype == "boss":
			points += 500
		score += points
		var event_bus = _get_autoload("EventBus")
		if event_bus:
			event_bus.score_changed.emit(score)

var last_loaded_scene: String = ""
const ROTATING_ENVIRONMENTS: Array[String] = [
	"res://scenes/environments/AirportTerminal.tscn",
	"res://scenes/environments/AirportServiceRoad.tscn",
	"res://scenes/environments/UrbanStreet.tscn",
	"res://scenes/environments/RailwayStation.tscn",
	"res://scenes/environments/AbandonedTrain.tscn",
	"res://scenes/environments/DarkIndustrial.tscn",
	"res://scenes/environments/FinalLockdown.tscn"
]
var _rotation_index: int = 0

func start_mission(mission: MissionData):
	current_mission = mission
	_is_finishing = false
	kill_count = 0
	wave_count = 0
	boss_kill_count = 0
	current_wave_number = 0
	endless_run_cash = 0
	endless_cash_paid = 0
	shots_fired = 0
	shots_hit = 0
	headshots = 0
	score = 0
	var event_bus = _get_autoload("EventBus")
	if event_bus:
		event_bus.score_changed.emit(score)
	
	print("[%d ms] [MISSION:START] Starting mission: %s" % [Time.get_ticks_msec(), mission.display_name if mission else "None"])
	mission_started.emit(mission)
	
	var target_scene = "res://scenes/environments/AirportTerminal.tscn"
	if mission and mission.scene_path != "" and ResourceLoader.exists(mission.scene_path):
		target_scene = mission.scene_path
	elif not ResourceLoader.exists(target_scene):
		_rotation_index = (_rotation_index + 1) % ROTATING_ENVIRONMENTS.size()
		target_scene = ROTATING_ENVIRONMENTS[_rotation_index]
	
	last_loaded_scene = target_scene
		
	var loading_mgr = _get_autoload("LoadingManager")
	if loading_mgr and loading_mgr.has_method("load_scene_async"):
		loading_mgr.load_scene_async(target_scene, mission)
	else:
		get_tree().change_scene_to_file(target_scene)

func on_zombie_killed():
	kill_count += 1
	if current_mission and current_mission.is_endless:
		endless_run_cash += 15
	_notify_objective()
	check_objective()

func on_boss_killed():
	boss_kill_count += 1
	kill_count += 1
	if current_mission and current_mission.is_endless:
		endless_run_cash += 15
	_notify_objective()
	check_objective()

func on_wave_completed():
	wave_count += 1
	_bank_endless_cash()
	_notify_objective()
	check_objective()

func _bank_endless_cash():
	if not current_mission or not current_mission.is_endless:
		return
	var payout = endless_run_cash - endless_cash_paid
	if payout <= 0:
		return
	var save_mgr = _get_autoload("SaveManager")
	if save_mgr and save_mgr.has_method("add_cash"):
		save_mgr.add_cash(payout)
		endless_cash_paid = endless_run_cash

func _notify_objective():
	if not current_mission: return
	var current_prog = 0
	var target_prog = 1
	match current_mission.objective_type:
		MissionData.ObjectiveType.KILL_COUNT:
			current_prog = kill_count
			target_prog = max(1, current_mission.target_count)
		MissionData.ObjectiveType.SURVIVE_WAVES:
			current_prog = current_wave_number if current_mission.is_endless else wave_count
			target_prog = 0 if current_mission.is_endless else current_mission.wave_count
		MissionData.ObjectiveType.BOSS_KILL:
			current_prog = boss_kill_count
			target_prog = max(1, current_mission.target_count)
			
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.objective_updated.emit(current_mission.display_name, current_mission.description, current_prog, target_prog)

func check_objective():
	if not current_mission: return
	
	var completed = false
	var total_killed = kill_count
	match current_mission.objective_type:
		MissionData.ObjectiveType.KILL_COUNT:
			# Secure the sector only after clearing every wave and reaching the kill target.
			if wave_count >= current_mission.wave_count and kill_count >= current_mission.target_count:
				completed = true
		MissionData.ObjectiveType.SURVIVE_WAVES:
			if not current_mission.is_endless and wave_count >= current_mission.wave_count:
				completed = true
		MissionData.ObjectiveType.BOSS_KILL:
			if boss_kill_count >= max(1, current_mission.target_count) and wave_count >= current_mission.wave_count:
				completed = true
			elif wave_count >= current_mission.wave_count and boss_kill_count >= 1:
				completed = true
	
	if completed:
		finish_mission(true)

func finish_mission(success: bool):
	if not current_mission or _is_finishing:
		return
	_is_finishing = true
	
	if success and is_inside_tree() and DisplayServer.get_name() != "headless":
		# Visceral Last-Kill Slow-Mo Cam (0.25x time scale for 1.2s unscaled)
		Engine.time_scale = 0.25
		await get_tree().create_timer(1.2, true, false, true).timeout
		Engine.time_scale = 1.0
	
	var accuracy = 0
	if shots_fired > 0:
		accuracy = int(clamp((float(shots_hit) / float(shots_fired)) * 100.0, 0.0, 100.0))
	elif kill_count > 0:
		accuracy = 100
		
	var save_mgr = _get_autoload("SaveManager")
	var is_first_win = false
	if success:
		if save_mgr:
			is_first_win = not save_mgr.is_mission_completed(current_mission.mission_id)
		else:
			is_first_win = true
			
	var earned_cash = current_mission.reward_cash if (success and is_first_win) else 0
	if current_mission.is_endless:
		earned_cash = endless_run_cash
		_bank_endless_cash()
		
	last_stats = {
		"kills": kill_count,
		"headshots": headshots,
		"score": score,
		"accuracy": accuracy,
		"cash": earned_cash,
		"bounty_awarded": earned_cash,
		"first_time_reward": is_first_win if success else false,
		"success": success
	}
	
	var game_state_mgr = _get_autoload("GameStateManager")
	
	# Track endless mode highest wave
	if current_mission and current_mission.is_endless and save_mgr:
		var reached_wave = max(wave_count, current_wave_number)
		save_mgr.set_highest_wave(reached_wave)
		save_mgr.set_highest_score(score)
		last_stats["highest_wave"] = reached_wave
		last_stats["highest_score"] = save_mgr.get_highest_score()
		if not success:
			save_mgr.add_total_kills(kill_count)
			save_mgr.add_total_headshots(headshots)
	
	if success:
		if game_state_mgr:
			game_state_mgr.change_state(game_state_mgr.State.MISSION_COMPLETE)
			
		if save_mgr:
			var claimed = false
			if save_mgr.has_method("claim_mission_reward"):
				claimed = save_mgr.claim_mission_reward(current_mission.mission_id, current_mission.reward_cash)
			elif not save_mgr.is_mission_completed(current_mission.mission_id):
				save_mgr.add_cash(current_mission.reward_cash)
				save_mgr.complete_mission(current_mission.mission_id)
				claimed = true
			
			if claimed:
				last_stats["bounty_awarded"] = current_mission.reward_cash
				last_stats["first_time_reward"] = true
			else:
				last_stats["bounty_awarded"] = 0
				last_stats["first_time_reward"] = false
			
			# Calculate star rating
			var stars = 1  # Base: survived = 1 star
			if shots_fired > 0:
				var hs_pct = float(headshots) / float(shots_fired) * 100.0
				if hs_pct >= 50.0:
					stars = 2  # 50%+ headshot accuracy = 2 stars
			if kill_count > 0 and headshots > 0:
				var hs_ratio = float(headshots) / float(max(1, kill_count))
				if hs_ratio >= 0.4:
					stars = 3  # 40%+ headshot kill ratio = 3 stars
			save_mgr.set_mission_stars(current_mission.mission_id, stars)
			last_stats["stars"] = stars
			
			# Track lifetime stats
			save_mgr.add_total_kills(kill_count)
			save_mgr.add_total_headshots(headshots)
			
		print("[%d ms] [MISSION:COMPLETE] Mission succeeded: %s (Kills: %d, Accuracy: %d%%, Cash Awarded: %d)" % [Time.get_ticks_msec(), current_mission.display_name, last_stats.kills, accuracy, last_stats.bounty_awarded])
		mission_completed.emit(current_mission)
	else:
		if game_state_mgr:
			game_state_mgr.change_state(game_state_mgr.State.MISSION_FAILED)
		print("[%d ms] [MISSION:FAILED] Mission failed: %s" % [Time.get_ticks_msec(), current_mission.display_name])
		mission_failed.emit(current_mission)
		
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.mission_finished.emit(current_mission.mission_id, success)
		
	current_mission = null
	_is_finishing = false

func get_next_mission(current: MissionData) -> MissionData:
	if not current:
		return null
	var mid = current.mission_id
	var norm_id = mid
	var save_mgr = _get_autoload("SaveManager")
	if save_mgr and "LEGACY_MISSION_MAP" in save_mgr and save_mgr.LEGACY_MISSION_MAP.has(mid):
		norm_id = save_mgr.LEGACY_MISSION_MAP[mid]
	
	var parts = norm_id.split("-")
	if parts.size() == 2:
		var ch = int(parts[0])
		var m_idx = int(parts[1])
		if m_idx < 7:
			m_idx += 1
		else:
			if ch < 12:
				ch += 1
				m_idx = 1
			else:
				return null
		var next_path = "res://resources/missions/campaign/mission_%02d_%02d.tres" % [ch, m_idx]
		if ResourceLoader.exists(next_path):
			return load(next_path) as MissionData
	
	var legacy_order = [
		"mission_01", "mission_02", "mission_03", "mission_04", "mission_05", "mission_06",
		"mission_07", "mission_08", "mission_09", "mission_10", "mission_11", "mission_12"
	]
	var idx = legacy_order.find(mid)
	if idx != -1 and idx + 1 < legacy_order.size():
		var p = "res://resources/missions/%s.tres" % legacy_order[idx + 1]
		if ResourceLoader.exists(p):
			return load(p) as MissionData
			
	return null
