extends Node

const SAVE_PATH = "user://savegame.json"
const SAVE_TEMP = "user://savegame.json.tmp"
const SAVE_BACKUP = "user://savegame.json.bak"
const SAVE_VERSION = 4

const LEGACY_MISSION_MAP = {
	"mission_01": "1-1",
	"mission_02": "2-1",
	"mission_03": "3-1",
	"mission_04": "4-1",
	"mission_05": "5-1",
	"mission_06": "6-1",
	"mission_07": "7-1",
	"mission_08": "8-1",
	"mission_09": "9-1",
	"mission_10": "10-1",
	"mission_11": "11-1",
	"mission_12": "12-7",
}

var data = {
	"version": SAVE_VERSION,
	"cash": 0,
	"equipped_weapon": "negev_ng7",
	"completed_missions": [],
	"unlocked_weapons": [
		"negev_ng7"
	],
	"is_first_launch": true,
	"selected_quality": 0 if OS.get_name() == "Android" else 1, # 0: Low, 1: Medium, 2: High
	"settings": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"ambience_volume": 0.7,
		"sensitivity": 0.048,
		"aim_sensitivity": 0.024,
		"invert_y": false
	},
	"weapon_upgrades": {
		"pistol": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"usp45": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"rifle": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"m4a1": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"shotgun": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"remington870": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"ak47": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"desert_eagle": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"mp5": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"awp": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"combat_knife": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"crossbow": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0},
		"grenade_launcher": {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0}
	},
	"rented_weapons": {},
	"mission_stars": {},
	"highest_wave": 0,
	"highest_score": 0,
	"total_kills": 0,
	"total_headshots": 0,
	"daily_bounties": {},
	"daily_challenge": {
		"date": "",
		"id": "",
		"progress": 0,
		"claimed": false
	},
	"daily_rewards": {
		"last_claim_date": "",
		"current_day": 1,
		"claimed_days": []
	},
	"lucky_spin": {
		"last_free_spin_date": "",
		"total_spins": 0
	}
}

func _ready():
	var t0 = Time.get_ticks_msec()
	load_game()
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("mission_finished"):
		event_bus.mission_finished.connect(func(_id, _s): consume_rented_weapons())
		
	print("[%d ms] [BOOT:01] SaveManager initialized in %d ms (Cash: %d, Completed: %s)" % [Time.get_ticks_msec(), Time.get_ticks_msec() - t0, data.cash, str(data.completed_missions)])

func save_game():
	# Atomic Save Process: Write to .tmp first, then atomically replace
	var file = FileAccess.open(SAVE_TEMP, FileAccess.WRITE)
	if not file:
		printerr("[SaveManager Error] Cannot open temp save file: ", SAVE_TEMP)
		return
		
	data.version = SAVE_VERSION
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.flush()
	file.close()
	
	# Create backup of current valid save
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, SAVE_BACKUP)
		
	# Replace main save with temp
	var err = DirAccess.rename_absolute(SAVE_TEMP, SAVE_PATH)
	if err != OK:
		# Fallback if rename across filesystems fails
		DirAccess.copy_absolute(SAVE_TEMP, SAVE_PATH)
		DirAccess.remove_absolute(SAVE_TEMP)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(SAVE_BACKUP):
			_load_from_path(SAVE_BACKUP)
		else:
			save_game()
		return
		
	if not _load_from_path(SAVE_PATH):
		if FileAccess.file_exists(SAVE_BACKUP):
			print("[SaveManager] Main save corrupted. Recovering from backup...")
			_load_from_path(SAVE_BACKUP)
		else:
			printerr("[SaveManager] Save corrupted. Resetting to defaults.")
			save_game()

func _load_from_path(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(json_string)
	if not json is Dictionary or not json.has("version"):
		return false

	var loaded_version = int(json.get("version", -1))
	if loaded_version < 1 or loaded_version > SAVE_VERSION:
		printerr("[SaveManager] Unsupported save version: %d" % loaded_version)
		return false

	_merge_data(json)
	if loaded_version < 4:
		# Migrate to Version 4: Rebalance economy and locked weapons
		# Ensure only negev_ng7 is unlocked initially unless user actually purchased weapons
		data.unlocked_weapons = ["negev_ng7"]
		if not is_weapon_rented(data.equipped_weapon):
			data.equipped_weapon = "negev_ng7"
		data.version = SAVE_VERSION
		save_game()
	elif loaded_version < SAVE_VERSION:
		data.version = SAVE_VERSION
		save_game()
	return true

func _merge_data(loaded_data: Dictionary):
	for key in data.keys():
		if loaded_data.has(key):
			if key in ["cash", "version", "selected_quality"]:
				data[key] = int(loaded_data[key])
			elif key == "weapon_upgrades" and loaded_data[key] is Dictionary:
				for w_id in loaded_data[key].keys():
					if not data[key].has(w_id):
						data[key][w_id] = {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0}
					var stats = loaded_data[key][w_id]
					if stats is Dictionary:
						for s in stats.keys():
							data[key][w_id][s] = int(stats[s])
			elif key == "settings" and loaded_data[key] is Dictionary:
				for s_key in data[key].keys():
					if loaded_data[key].has(s_key):
						data[key][s_key] = loaded_data[key][s_key]
			elif key == "unlocked_weapons" and loaded_data[key] is Array:
				data.unlocked_weapons.clear()
				for w_id in loaded_data[key]:
					if not w_id in data.unlocked_weapons:
						data.unlocked_weapons.append(w_id)
				if not "negev_ng7" in data.unlocked_weapons:
					data.unlocked_weapons.append("negev_ng7")
			elif key == "completed_missions" and loaded_data[key] is Array:
				for mid in loaded_data[key]:
					var s_mid = str(mid)
					if not s_mid in data.completed_missions:
						data.completed_missions.append(s_mid)
					if LEGACY_MISSION_MAP.has(s_mid):
						var mapped = LEGACY_MISSION_MAP[s_mid]
						if not mapped in data.completed_missions:
							data.completed_missions.append(mapped)
			elif key == "mission_stars" and loaded_data[key] is Dictionary:
				for mid in loaded_data[key].keys():
					var s_mid = str(mid)
					data.mission_stars[s_mid] = int(loaded_data[key][mid])
					if LEGACY_MISSION_MAP.has(s_mid):
						data.mission_stars[LEGACY_MISSION_MAP[s_mid]] = int(loaded_data[key][mid])
			elif typeof(data[key]) == typeof(loaded_data[key]):
				data[key] = loaded_data[key]

func add_cash(amount: int):
	if amount <= 0:
		if amount < 0:
			spend_cash(-amount)
		return
	data.cash += amount
	data.cash = max(0, data.cash)
	save_game()
	if is_inside_tree():
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus:
			event_bus.cash_changed.emit(data.cash)

func spend_cash(amount: int) -> bool:
	if amount <= 0:
		return false
	if data.cash < amount:
		return false
	data.cash -= amount
	data.cash = max(0, data.cash)
	save_game()
	if is_inside_tree():
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus:
			event_bus.cash_changed.emit(data.cash)
	return true

func claim_mission_reward(mission_id: String, reward_amount: int) -> bool:
	if is_mission_completed(mission_id):
		# Replay farming bounty: awards 40% repeat reward
		var repeat_bounty = int(round(reward_amount * 0.40))
		if repeat_bounty > 0:
			add_cash(repeat_bounty)
		return false
	if reward_amount > 0:
		add_cash(reward_amount)
	complete_mission(mission_id)
	return true

func complete_mission(mission_id: String):
	var changed = false
	if not mission_id in data.completed_missions:
		data.completed_missions.append(mission_id)
		changed = true
	if LEGACY_MISSION_MAP.has(mission_id):
		var mapped = LEGACY_MISSION_MAP[mission_id]
		if not mapped in data.completed_missions:
			data.completed_missions.append(mapped)
			changed = true
	for leg_k in LEGACY_MISSION_MAP.keys():
		if LEGACY_MISSION_MAP[leg_k] == mission_id and not leg_k in data.completed_missions:
			data.completed_missions.append(leg_k)
			changed = true
	if changed:
		save_game()

func is_mission_completed(mission_id: String) -> bool:
	if mission_id in data.completed_missions:
		return true
	if LEGACY_MISSION_MAP.has(mission_id) and LEGACY_MISSION_MAP[mission_id] in data.completed_missions:
		return true
	for leg_k in LEGACY_MISSION_MAP.keys():
		if LEGACY_MISSION_MAP[leg_k] == mission_id and leg_k in data.completed_missions:
			return true
	return false

func is_campaign_completed() -> bool:
	return is_mission_completed("12-7")

func is_endless_unlocked() -> bool:
	return true

func is_weapon_rented(weapon_id: String) -> bool:
	var rentals = data.get("rented_weapons", {})
	return rentals.get(weapon_id, 0) > 0

func get_rental_matches_remaining(weapon_id: String) -> int:
	var rentals = data.get("rented_weapons", {})
	return rentals.get(weapon_id, 0)

func rent_weapon(weapon_id: String, matches: int = 1) -> bool:
	if not data.has("rented_weapons"):
		data["rented_weapons"] = {}
	data["rented_weapons"][weapon_id] = matches
	data["equipped_weapon"] = weapon_id
	save_game()
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("weapon_equipped"):
		event_bus.emit_signal("weapon_equipped", weapon_id)
	print("[SaveManager] Weapon successfully rented for %d match: %s" % [matches, weapon_id])
	return true

func consume_rented_weapons():
	var rentals = data.get("rented_weapons", {})
	if rentals.is_empty():
		return
	var changed = false
	var expired = []
	for wid in rentals.keys():
		rentals[wid] -= 1
		print("[SaveManager] Rented weapon %s matches remaining: %d" % [wid, rentals[wid]])
		if rentals[wid] <= 0:
			expired.append(wid)
			changed = true
	for exp_wid in expired:
		rentals.erase(exp_wid)
		print("[SaveManager] Rental expired for: %s (Now locked again)" % exp_wid)
		if data.get("equipped_weapon", "") == exp_wid:
			data["equipped_weapon"] = "negev_ng7"
	if changed:
		data["rented_weapons"] = rentals
		save_game()

func is_weapon_owned(weapon_id: String) -> bool:
	if weapon_id == "negev_ng7":
		return true
	var unlocked = data.get("unlocked_weapons", [])
	if weapon_id in unlocked:
		return true
	match weapon_id:
		"usp45": return "pistol" in unlocked
		"pistol": return "usp45" in unlocked
		"m4a1": return "rifle" in unlocked
		"rifle": return "m4a1" in unlocked
		"remington870": return "shotgun" in unlocked
		"shotgun": return "remington870" in unlocked
		"deagle": return "desert_eagle" in unlocked
		"knife": return "combat_knife" in unlocked
		"m79": return "grenade_launcher" in unlocked
	return false

func is_weapon_unlocked(weapon_id: String) -> bool:
	return is_weapon_owned(weapon_id) or is_weapon_rented(weapon_id)

func unlock_weapon(weapon_id: String) -> bool:
	var unlocked = data.get("unlocked_weapons", [])
	var changed = false
	if not weapon_id in unlocked:
		unlocked.append(weapon_id)
		changed = true
	var alias = ""
	match weapon_id:
		"usp45": alias = "pistol"
		"pistol": alias = "usp45"
		"m4a1": alias = "rifle"
		"rifle": alias = "m4a1"
		"remington870": alias = "shotgun"
		"shotgun": alias = "remington870"
		"desert_eagle": alias = "deagle"
		"deagle": alias = "desert_eagle"
		"combat_knife": alias = "knife"
		"knife": alias = "combat_knife"
		"grenade_launcher": alias = "m79"
		"m79": alias = "grenade_launcher"
	if alias != "" and not alias in unlocked:
		unlocked.append(alias)
		changed = true
	if changed:
		data["unlocked_weapons"] = unlocked
		save_game()
	return changed

func get_equipped_weapon() -> String:
	var eq = data.get("equipped_weapon", "negev_ng7")
	if not is_weapon_unlocked(eq):
		if is_weapon_unlocked("pistol"):
			eq = "pistol"
		elif is_weapon_unlocked("usp45"):
			eq = "usp45"
		elif is_weapon_unlocked("m4a1"):
			eq = "m4a1"
	return eq

func set_equipped_weapon(weapon_id: String) -> bool:
	if not is_weapon_unlocked(weapon_id):
		return false
	data["equipped_weapon"] = weapon_id
	save_game()
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("weapon_equipped"):
		event_bus.emit_signal("weapon_equipped", weapon_id)
	return true

func get_weapon_upgrade(weapon_id: String, stat_name: String) -> int:
	var upgrades = data.get("weapon_upgrades", {})
	var w = upgrades.get(weapon_id, {})
	if w.is_empty():
		match weapon_id:
			"usp45": w = upgrades.get("pistol", {})
			"pistol": w = upgrades.get("usp45", {})
			"m4a1": w = upgrades.get("rifle", {})
			"rifle": w = upgrades.get("m4a1", {})
			"remington870": w = upgrades.get("shotgun", {})
			"shotgun": w = upgrades.get("remington870", {})
	return w.get(stat_name, 0)

func set_weapon_upgrade(weapon_id: String, stat_name: String, level: int):
	var upgrades = data.get("weapon_upgrades", {})
	if not upgrades.has(weapon_id):
		upgrades[weapon_id] = {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0}
	upgrades[weapon_id][stat_name] = level
	var alias = ""
	match weapon_id:
		"usp45": alias = "pistol"
		"pistol": alias = "usp45"
		"m4a1": alias = "rifle"
		"rifle": alias = "m4a1"
		"remington870": alias = "shotgun"
		"shotgun": alias = "remington870"
	if alias != "":
		if not upgrades.has(alias):
			upgrades[alias] = {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0}
		upgrades[alias][stat_name] = level
	save_game()

func upgrade_weapon(weapon_id: String, stat_name: String, cost: int) -> bool:
	if not spend_cash(cost):
		return false
	var cur_lvl = get_weapon_upgrade(weapon_id, stat_name)
	set_weapon_upgrade(weapon_id, stat_name, cur_lvl + 1)
	return true

# --- Star Rating System ---
func get_mission_stars(mission_id: String) -> int:
	return int(data.get("mission_stars", {}).get(mission_id, 0))

func set_mission_stars(mission_id: String, stars: int):
	if not data.has("mission_stars"):
		data["mission_stars"] = {}
	var current = get_mission_stars(mission_id)
	if stars > current:
		data["mission_stars"][mission_id] = stars
		save_game()

func get_total_stars() -> int:
	var total = 0
	for mid in data.get("mission_stars", {}).keys():
		total += int(data["mission_stars"][mid])
	return total

# --- Endless Mode Records ---
func get_highest_wave() -> int:
	return int(data.get("highest_wave", 0))

func set_highest_wave(wave: int):
	if wave > get_highest_wave():
		data["highest_wave"] = wave
		save_game()

func get_highest_score() -> int:
	return int(data.get("highest_score", 0))

func set_highest_score(score: int):
	if score > get_highest_score():
		data["highest_score"] = score
		save_game()

# --- Lifetime Stats ---
func add_total_kills(kills: int):
	data["total_kills"] = int(data.get("total_kills", 0)) + kills
	save_game()

func add_total_headshots(hs: int):
	data["total_headshots"] = int(data.get("total_headshots", 0)) + hs
	save_game()

# --- Daily Login Rewards System ---
const DAILY_REWARDS_TABLE = [
	{"day": 1, "cash": 100, "label": "₹100"},
	{"day": 2, "cash": 150, "label": "₹150"},
	{"day": 3, "cash": 200, "label": "₹200"},
	{"day": 4, "cash": 250, "label": "₹250"},
	{"day": 5, "cash": 350, "label": "₹350"},
	{"day": 6, "cash": 500, "label": "₹500"},
	{"day": 7, "cash": 800, "label": "₹800"}
]

func is_daily_reward_claimable() -> bool:
	var dr = data.get("daily_rewards", {})
	var last_date = dr.get("last_claim_date", "")
	var today = Time.get_date_string_from_system()
	return last_date != today

func get_daily_reward_info() -> Dictionary:
	var dr = data.get("daily_rewards", {})
	var cur_day = int(dr.get("current_day", 1))
	var last_date = dr.get("last_claim_date", "")
	var today = Time.get_date_string_from_system()
	var claimable = (last_date != today)
	return {
		"current_day": cur_day,
		"claimable": claimable,
		"last_claim_date": last_date,
		"today": today,
		"claimed_days": dr.get("claimed_days", [])
	}

func claim_daily_reward() -> Dictionary:
	if not is_daily_reward_claimable():
		return {"success": false, "message": "Already claimed today"}
		
	var dr = data.get("daily_rewards", {})
	var cur_day = int(dr.get("current_day", 1))
	if cur_day < 1 or cur_day > 7:
		cur_day = 1
		
	var reward = DAILY_REWARDS_TABLE[cur_day - 1]
	var cash_gain = reward["cash"]
	add_cash(cash_gain)
	
	var today = Time.get_date_string_from_system()
	dr["last_claim_date"] = today
	if not dr.has("claimed_days") or not (dr["claimed_days"] is Array):
		dr["claimed_days"] = []
	if not cur_day in dr["claimed_days"]:
		dr["claimed_days"].append(cur_day)
	
	var next_day = cur_day + 1
	if next_day > 7:
		next_day = 1
		dr["claimed_days"] = []
	dr["current_day"] = next_day
	data["daily_rewards"] = dr
	save_game()
	
	return {
		"success": true,
		"day": cur_day,
		"cash": cash_gain,
		"label": reward["label"],
		"next_day": next_day
	}

# --- Lucky Spin System ---
func is_free_spin_available() -> bool:
	var ls = data.get("lucky_spin", {})
	var last_date = ls.get("last_free_spin_date", "")
	var today = Time.get_date_string_from_system()
	return last_date != today

func record_spin_reward(cash_amount: int, is_free: bool):
	var ls = data.get("lucky_spin", {})
	if is_free:
		ls["last_free_spin_date"] = Time.get_date_string_from_system()
	ls["total_spins"] = int(ls.get("total_spins", 0)) + 1
	data["lucky_spin"] = ls
	
	if cash_amount > 0:
		add_cash(cash_amount)
	save_game()
