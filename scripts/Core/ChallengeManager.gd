extends Node

signal challenge_changed(challenge: Dictionary, progress: int, completed: bool)

const REWARD_CASH := 300
const CHALLENGES := [
	{"id": "clean_sweep", "title": "CLEAN SWEEP", "description": "Eliminate 40 infected", "target": 40, "stat": "kills"},
	{"id": "deadeye", "title": "DEADEYE", "description": "Score 15 headshots", "target": 15, "stat": "headshots"},
	{"id": "hold_the_line", "title": "HOLD THE LINE", "description": "Clear 5 waves", "target": 5, "stat": "waves"},
	{"id": "field_work", "title": "FIELD WORK", "description": "Complete 2 missions", "target": 2, "stat": "missions"}
]

var current_challenge: Dictionary = {}
var _date_key := ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sync_daily_challenge()
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		if not event_bus.enemy_killed.is_connected(_on_enemy_killed):
			event_bus.enemy_killed.connect(_on_enemy_killed)
		if not event_bus.wave_completed.is_connected(_on_wave_completed):
			event_bus.wave_completed.connect(_on_wave_completed)
		if not event_bus.mission_finished.is_connected(_on_mission_finished):
			event_bus.mission_finished.connect(_on_mission_finished)

func _sync_daily_challenge():
	var date = Time.get_date_dict_from_system()
	_date_key = "%04d-%02d-%02d" % [date.year, date.month, date.day]
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr:
		return
	var stored = save_mgr.data.get("daily_challenge", {})
	if stored.get("date", "") != _date_key:
		var day_index = int(Time.get_unix_time_from_datetime_dict(date) / 86400.0)
		var template = CHALLENGES[posmod(day_index, CHALLENGES.size())]
		save_mgr.data["daily_challenge"] = {
			"date": _date_key,
			"id": template.id,
			"progress": 0,
			"claimed": false
		}
		save_mgr.save_game()
	current_challenge = _get_template(save_mgr.data.daily_challenge.get("id", "clean_sweep"))
	_emit_changed()

func _get_template(challenge_id: String) -> Dictionary:
	for template in CHALLENGES:
		if template.id == challenge_id:
			return template
	return CHALLENGES[0]

func get_daily_challenge() -> Dictionary:
	_sync_daily_challenge()
	return current_challenge.duplicate()

func get_progress() -> int:
	var save_mgr = get_node_or_null("/root/SaveManager")
	return int(save_mgr.data.get("daily_challenge", {}).get("progress", 0)) if save_mgr else 0

func is_completed() -> bool:
	return get_progress() >= int(current_challenge.get("target", 1))

func is_claimed() -> bool:
	var save_mgr = get_node_or_null("/root/SaveManager")
	return bool(save_mgr.data.get("daily_challenge", {}).get("claimed", false)) if save_mgr else false

func claim_reward() -> bool:
	_sync_daily_challenge()
	if not is_completed() or is_claimed():
		return false
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr:
		return false
	save_mgr.data.daily_challenge.claimed = true
	save_mgr.add_cash(REWARD_CASH)
	_emit_changed()
	return true

func _on_enemy_killed(_archetype: String, is_headshot: bool, _position: Vector3):
	var stat = current_challenge.get("stat", "")
	if stat == "kills" or (stat == "headshots" and is_headshot):
		_increment_progress()

func _on_wave_completed(_wave_number: int):
	if current_challenge.get("stat", "") == "waves":
		_increment_progress()

func _on_mission_finished(_mission_id: String, success: bool):
	if success and current_challenge.get("stat", "") == "missions":
		_increment_progress()

func _increment_progress():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr or is_completed():
		return
	var entry = save_mgr.data.daily_challenge
	entry.progress = min(int(entry.get("progress", 0)) + 1, int(current_challenge.target))
	if is_completed():
		save_mgr.save_game()
	_emit_changed()

func _emit_changed():
	challenge_changed.emit(current_challenge.duplicate(), get_progress(), is_completed())
