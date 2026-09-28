extends Control

@onready var mission_map = get_node_or_null("MissionMap")
@onready var scroll_container = get_node_or_null("ScrollContainer")
@onready var mission_list = get_node_or_null("ScrollContainer/VBoxContainer")
@export var mission_card_prefab: PackedScene = preload("res://scenes/UI/MissionCard.tscn")

@onready var briefing_modal = get_node_or_null("BriefingModal")
@onready var briefing_header = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingHeader")
@onready var briefing_location = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingLocation")
@onready var briefing_difficulty = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingDifficulty")
@onready var briefing_objective = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingObjective")
@onready var briefing_lore = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingLore")
@onready var briefing_loadout = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingLoadout")
@onready var briefing_reward = get_node_or_null("BriefingModal/ModalPanel/Margin/VBox/BriefingReward")
@onready var cash_label = find_child("CashLabel", true, false)
@onready var cash_display = get_node_or_null("TopBar/CashDisplay")
@onready var view_toggle_btn = get_node_or_null("TopBar/Margin/HBox/ViewToggleBtn")

@onready var chapter_bar = get_node_or_null("ChapterBar")
@onready var prev_chapter_btn = find_child("PrevChapterBtn", true, false)
@onready var next_chapter_btn = find_child("NextChapterBtn", true, false)
@onready var chapter_title_label = find_child("ChapterTitleLabel", true, false)
@onready var chapter_status_label = find_child("ChapterStatusLabel", true, false)

@onready var quick_play_bar = get_node_or_null("QuickPlayBar")
@onready var quick_title_label = find_child("QuickTitleLabel", true, false)
@onready var quick_desc_label = find_child("QuickDescLabel", true, false)
@onready var quick_start_btn = find_child("QuickStartButton", true, false)

var selected_mission: MissionData = null
var next_quick_mission: MissionData = null
var is_list_view_active: bool = false
var current_chapter_idx: int = 0

const CHAPTERS = [
	{
		"num": 1,
		"name": "AIRPORT COMPLEX",
		"location": "Sector 01 - Terminal Perimeter",
		"desc": "Primary international transit hub overrun in early outbreak phases.",
		"threat_stars": 1,
		"missions": [
			"res://resources/missions/campaign/mission_01_01.tres",
			"res://resources/missions/campaign/mission_01_02.tres",
			"res://resources/missions/campaign/mission_01_03.tres",
			"res://resources/missions/campaign/mission_01_04.tres",
			"res://resources/missions/campaign/mission_01_05.tres",
			"res://resources/missions/campaign/mission_01_06.tres",
			"res://resources/missions/campaign/mission_01_07.tres"
		]
	},
	{
		"num": 2,
		"name": "AIRPORT SERVICE ROAD",
		"location": "Sector 02 - Service Perimeter",
		"desc": "Supply conduits and outer access roads barricaded by stalled military convoys.",
		"threat_stars": 1,
		"missions": [
			"res://resources/missions/campaign/mission_02_01.tres",
			"res://resources/missions/campaign/mission_02_02.tres",
			"res://resources/missions/campaign/mission_02_03.tres",
			"res://resources/missions/campaign/mission_02_04.tres",
			"res://resources/missions/campaign/mission_02_05.tres",
			"res://resources/missions/campaign/mission_02_06.tres",
			"res://resources/missions/campaign/mission_02_07.tres"
		]
	},
	{
		"num": 3,
		"name": "RAILWAY STATION",
		"location": "Sector 03 - Metro Concourse",
		"desc": "Central subway junction under quarantine lockdown.",
		"threat_stars": 2,
		"missions": [
			"res://resources/missions/campaign/mission_03_01.tres",
			"res://resources/missions/campaign/mission_03_02.tres",
			"res://resources/missions/campaign/mission_03_03.tres",
			"res://resources/missions/campaign/mission_03_04.tres",
			"res://resources/missions/campaign/mission_03_05.tres",
			"res://resources/missions/campaign/mission_03_06.tres",
			"res://resources/missions/campaign/mission_03_07.tres"
		]
	},
	{
		"num": 4,
		"name": "ABANDONED TRAIN YARD",
		"location": "Sector 04 - Freight Rail Yard",
		"desc": "Derailment zone infested with aggressive runner bioforms.",
		"threat_stars": 2,
		"missions": [
			"res://resources/missions/campaign/mission_04_01.tres",
			"res://resources/missions/campaign/mission_04_02.tres",
			"res://resources/missions/campaign/mission_04_03.tres",
			"res://resources/missions/campaign/mission_04_04.tres",
			"res://resources/missions/campaign/mission_04_05.tres",
			"res://resources/missions/campaign/mission_04_06.tres",
			"res://resources/missions/campaign/mission_04_07.tres"
		]
	},
	{
		"num": 5,
		"name": "INDUSTRIAL ZONE",
		"location": "Sector 05 - Manufacturing Grid",
		"desc": "Dark industrial complex housing critical power substation.",
		"threat_stars": 3,
		"missions": [
			"res://resources/missions/campaign/mission_05_01.tres",
			"res://resources/missions/campaign/mission_05_02.tres",
			"res://resources/missions/campaign/mission_05_03.tres",
			"res://resources/missions/campaign/mission_05_04.tres",
			"res://resources/missions/campaign/mission_05_05.tres",
			"res://resources/missions/campaign/mission_05_06.tres",
			"res://resources/missions/campaign/mission_05_07.tres"
		]
	},
	{
		"num": 6,
		"name": "ABANDONED HOSPITAL",
		"location": "Sector 06 - Quarantine Medical Center",
		"desc": "Civilian hospital converted into emergency outbreak bio-research facility.",
		"threat_stars": 3,
		"missions": [
			"res://resources/missions/campaign/mission_06_01.tres",
			"res://resources/missions/campaign/mission_06_02.tres",
			"res://resources/missions/campaign/mission_06_03.tres",
			"res://resources/missions/campaign/mission_06_04.tres",
			"res://resources/missions/campaign/mission_06_05.tres",
			"res://resources/missions/campaign/mission_06_06.tres",
			"res://resources/missions/campaign/mission_06_07.tres"
		]
	},
	{
		"num": 7,
		"name": "SHOPPING DISTRICT / METRO",
		"location": "Sector 07 - Commercial Underground",
		"desc": "Dense commercial sector with claustrophobic underground retail concourses.",
		"threat_stars": 3,
		"missions": [
			"res://resources/missions/campaign/mission_07_01.tres",
			"res://resources/missions/campaign/mission_07_02.tres",
			"res://resources/missions/campaign/mission_07_03.tres",
			"res://resources/missions/campaign/mission_07_04.tres",
			"res://resources/missions/campaign/mission_07_05.tres",
			"res://resources/missions/campaign/mission_07_06.tres",
			"res://resources/missions/campaign/mission_07_07.tres"
		]
	},
	{
		"num": 8,
		"name": "NIGHT CITY STREET",
		"location": "Sector 08 - Downtown Urban Core",
		"desc": "Neon-drenched metropolitan boulevards overwhelmed by nocturnal apex hunters.",
		"threat_stars": 4,
		"missions": [
			"res://resources/missions/campaign/mission_08_01.tres",
			"res://resources/missions/campaign/mission_08_02.tres",
			"res://resources/missions/campaign/mission_08_03.tres",
			"res://resources/missions/campaign/mission_08_04.tres",
			"res://resources/missions/campaign/mission_08_05.tres",
			"res://resources/missions/campaign/mission_08_06.tres",
			"res://resources/missions/campaign/mission_08_07.tres"
		]
	},
	{
		"num": 9,
		"name": "MILITARY CHECKPOINT",
		"location": "Sector 09 - Fortified Outpost Gate",
		"desc": "Fall of the defensive military perimeter. Heavy infected breach.",
		"threat_stars": 4,
		"missions": [
			"res://resources/missions/campaign/mission_09_01.tres",
			"res://resources/missions/campaign/mission_09_02.tres",
			"res://resources/missions/campaign/mission_09_03.tres",
			"res://resources/missions/campaign/mission_09_04.tres",
			"res://resources/missions/campaign/mission_09_05.tres",
			"res://resources/missions/campaign/mission_09_06.tres",
			"res://resources/missions/campaign/mission_09_07.tres"
		]
	},
	{
		"num": 10,
		"name": "CHEMICAL PLANT / LAB",
		"location": "Sector 10 - Bio-Hazard Synthesis Core",
		"desc": "Toxic chemical refinery where bio-agents accelerated viral mutations.",
		"threat_stars": 4,
		"missions": [
			"res://resources/missions/campaign/mission_10_01.tres",
			"res://resources/missions/campaign/mission_10_02.tres",
			"res://resources/missions/campaign/mission_10_03.tres",
			"res://resources/missions/campaign/mission_10_04.tres",
			"res://resources/missions/campaign/mission_10_05.tres",
			"res://resources/missions/campaign/mission_10_06.tres",
			"res://resources/missions/campaign/mission_10_07.tres"
		]
	},
	{
		"num": 11,
		"name": "OVERRUN QUARANTINE ZONE",
		"location": "Sector 11 - Containment Barrier",
		"desc": "Level 4 quarantine barrier breach. High lethality mutant hordes.",
		"threat_stars": 5,
		"missions": [
			"res://resources/missions/campaign/mission_11_01.tres",
			"res://resources/missions/campaign/mission_11_02.tres",
			"res://resources/missions/campaign/mission_11_03.tres",
			"res://resources/missions/campaign/mission_11_04.tres",
			"res://resources/missions/campaign/mission_11_05.tres",
			"res://resources/missions/campaign/mission_11_06.tres",
			"res://resources/missions/campaign/mission_11_07.tres"
		]
	},
	{
		"num": 12,
		"name": "GROUND ZERO",
		"location": "Sector 12 - Primary Impact Crater",
		"desc": "The origin epicenter of the pathogen. Terminate the Prime Goliath.",
		"threat_stars": 5,
		"missions": [
			"res://resources/missions/campaign/mission_12_01.tres",
			"res://resources/missions/campaign/mission_12_02.tres",
			"res://resources/missions/campaign/mission_12_03.tres",
			"res://resources/missions/campaign/mission_12_04.tres",
			"res://resources/missions/campaign/mission_12_05.tres",
			"res://resources/missions/campaign/mission_12_06.tres",
			"res://resources/missions/campaign/mission_12_07.tres",
			"res://resources/missions/mission_endless.tres"
		]
	}
]

# Legacy mission paths for backward test suite compatibility
var missions = [
	"res://resources/missions/mission_01.tres",
	"res://resources/missions/mission_02.tres",
	"res://resources/missions/mission_03.tres",
	"res://resources/missions/mission_04.tres",
	"res://resources/missions/mission_05.tres",
	"res://resources/missions/mission_06.tres",
	"res://resources/missions/mission_07.tres",
	"res://resources/missions/mission_08.tres",
	"res://resources/missions/mission_09.tres",
	"res://resources/missions/mission_10.tres",
	"res://resources/missions/mission_11.tres",
	"res://resources/missions/mission_12.tres",
	"res://resources/missions/mission_endless.tres"
]

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if briefing_modal and briefing_modal.visible:
			_on_close_briefing_button_pressed()
		else:
			_on_back_button_pressed()

func _ready():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	var initial_cash = save_mgr.data.cash if save_mgr else 0
	if cash_label:
		cash_label.text = "CASH: %d" % initial_cash
	if cash_display and cash_display.has_method("set_cash"):
		cash_display.set_cash(initial_cash, false)
		
	if briefing_modal:
		briefing_modal.visible = false
		
	# Populate list view (guarantees test suite compatibility)
	populate_missions()
	
	if mission_map and mission_map.has_signal("mission_selected"):
		if not mission_map.mission_selected.is_connected(_on_map_mission_selected):
			mission_map.mission_selected.connect(_on_map_mission_selected)
		
	if view_toggle_btn:
		view_toggle_btn.pressed.connect(_on_toggle_view)
		
	if prev_chapter_btn:
		prev_chapter_btn.pressed.connect(_on_prev_chapter_pressed)
	if next_chapter_btn:
		next_chapter_btn.pressed.connect(_on_next_chapter_pressed)
		
	# Auto-detect highest active/unlocked chapter
	current_chapter_idx = _get_initial_chapter_idx()
	setup_chapter(current_chapter_idx)
	
	# Default to Tactical Campaign Map view
	_set_view_mode(false)
	
	print("[%d ms] [MISSION_SELECT] MissionSelect ready (Chapter: %d)." % [Time.get_ticks_msec(), current_chapter_idx + 1])

func is_chapter_unlocked(ch_idx: int) -> bool:
	if ch_idx <= 0:
		return true
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr:
		return true
	# Chapter N is unlocked if Chapter N-1's Capstone Boss (N-1)-7 is completed
	var prev_boss_id = "%d-7" % ch_idx
	return save_mgr.is_mission_completed(prev_boss_id)

func _get_initial_chapter_idx() -> int:
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr:
		return 0
		
	var target_ch = 0
	for i in range(CHAPTERS.size()):
		if not is_chapter_unlocked(i):
			break
		target_ch = i
		# Check if this chapter still has uncompleted missions
		var ch_missions = CHAPTERS[i]["missions"]
		var has_uncleared = false
		for m_path in ch_missions:
			var m_data = load(m_path) as MissionData
			if m_data and not save_mgr.is_mission_completed(m_data.mission_id):
				has_uncleared = true
				break
		if has_uncleared:
			return i
			
	return target_ch

func setup_chapter(ch_idx: int):
	current_chapter_idx = clamp(ch_idx, 0, CHAPTERS.size() - 1)
	var ch_data = CHAPTERS[current_chapter_idx]
	var c_num = ch_data["num"]
	var c_name = ch_data["name"]
	var c_loc = ch_data["location"]
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	var is_unl = is_chapter_unlocked(current_chapter_idx)
	
	var cleared_count = 0
	for m_path in ch_data["missions"]:
		var m = load(m_path) as MissionData
		if m and save_mgr and save_mgr.is_mission_completed(m.mission_id):
			cleared_count += 1
			
	# Update ChapterBar labels
	if chapter_title_label:
		chapter_title_label.text = "CHAPTER %02d: %s" % [c_num, c_name]
		
	if chapter_status_label:
		if not is_unl:
			chapter_status_label.text = "🔒 LOCKED (CLEAR CHAPTER %02d APEX BOSS)" % (c_num - 1)
			chapter_status_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 0.9))
		elif cleared_count >= 7:
			chapter_status_label.text = "AREA: %s  •  STATUS: COMPLETED (7/7) ★★★" % c_loc
			chapter_status_label.add_theme_color_override("font_color", Color(0.2, 0.95, 0.5, 0.95))
		else:
			var stars_str = ""
			for s in range(ch_data.get("threat_stars", 1)):
				stars_str += "★"
			chapter_status_label.text = "AREA: %s  •  PROGRESS: %d/7 CLEARED  •  THREAT: %s" % [c_loc, cleared_count, stars_str]
			chapter_status_label.add_theme_color_override("font_color", Color(0.15, 0.85, 1.0, 0.9))
			
	# Update Navigation buttons
	if prev_chapter_btn:
		prev_chapter_btn.disabled = (current_chapter_idx == 0)
	if next_chapter_btn:
		var has_next = (current_chapter_idx < CHAPTERS.size() - 1)
		var next_unlocked = is_chapter_unlocked(current_chapter_idx + 1) if has_next else false
		next_chapter_btn.disabled = not has_next or not next_unlocked

	# Update Tactical Map
	if mission_map and mission_map.has_method("setup_chapter"):
		mission_map.setup_chapter(ch_data)
	elif mission_map and mission_map.has_method("setup_map"):
		mission_map.setup_map(ch_data["missions"])
		
	_update_quick_play_bar()

func _on_prev_chapter_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"): audio_mgr.play_ui_click()
	if current_chapter_idx > 0:
		setup_chapter(current_chapter_idx - 1)

func _on_next_chapter_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"): audio_mgr.play_ui_click()
	if current_chapter_idx < CHAPTERS.size() - 1 and is_chapter_unlocked(current_chapter_idx + 1):
		setup_chapter(current_chapter_idx + 1)

func _on_toggle_view():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"): audio_mgr.play_ui_click()
	_set_view_mode(not is_list_view_active)

func _set_view_mode(list_active: bool):
	is_list_view_active = list_active
	if mission_map:
		mission_map.visible = not list_active
	if scroll_container:
		scroll_container.visible = list_active
	if view_toggle_btn:
		view_toggle_btn.text = "MAP VIEW" if list_active else "LIST VIEW"

func populate_missions():
	if not mission_list: return
	for child in mission_list.get_children():
		child.queue_free()
		
	for mission_path in missions:
		var data = load(mission_path)
		if data and mission_card_prefab:
			var card = mission_card_prefab.instantiate()
			mission_list.add_child(card)
			card.setup(data)
			if card.has_signal("mission_selected"):
				card.mission_selected.connect(_on_mission_selected)

func _on_map_mission_selected(data: MissionData, _idx: int):
	selected_mission = data

func _on_mission_selected(data: MissionData):
	selected_mission = data
	if not briefing_modal or not data:
		var mission_mgr = get_node_or_null("/root/MissionManager")
		if mission_mgr:
			mission_mgr.start_mission(data)
		return
		
	if briefing_header:
		briefing_header.text = "MISSION: " + data.display_name.to_upper()
	if briefing_location:
		briefing_location.text = "📍 LOCATION: " + (data.location_name if "location_name" in data and data.location_name != "" else "Sector Zone")
	
	var stars_count = data.difficulty_stars if "difficulty_stars" in data else 1
	var stars_str = ""
	for i in range(5):
		stars_str += "★" if i < stars_count else "☆"
	if briefing_difficulty:
		briefing_difficulty.text = "⭐ THREAT LEVEL: " + stars_str
	
	var obj_text = "Eliminate hostiles"
	match data.objective_type:
		MissionData.ObjectiveType.KILL_COUNT:
			obj_text = "Eliminate %d infected across %d waves." % [data.target_count, data.wave_count]
		MissionData.ObjectiveType.SURVIVE_WAVES:
			obj_text = "Survive %d waves of hostile assault." % data.wave_count
		MissionData.ObjectiveType.BOSS_KILL:
			obj_text = "Neutralize Apex Alpha Boss Specimen."
	if briefing_objective:
		briefing_objective.text = "🎯 OBJECTIVE: " + obj_text
	
	if briefing_lore:
		briefing_lore.text = data.description
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	if briefing_loadout:
		var eq_name = "M4A1 Sentinel"
		if save_mgr and save_mgr.has_method("get_equipped_weapon"):
			var eq_id = save_mgr.get_equipped_weapon()
			var entry = WeaponManager.get_weapon_entry(eq_id)
			eq_name = entry.get("display_name", eq_id.to_upper())
		briefing_loadout.text = "🔫 EQUIPPED WEAPON: %s" % eq_name.to_upper()
	
	var is_completed = save_mgr.is_mission_completed(data.mission_id) if save_mgr else false
	var is_unlocked = true
	if data.unlock_requirement_id != "" and save_mgr:
		is_unlocked = save_mgr.is_mission_completed(data.unlock_requirement_id)
		
	if briefing_reward:
		if is_completed:
			briefing_reward.text = "💰 REWARD: %d CASH (CLAIMED)" % data.reward_cash
		else:
			briefing_reward.text = "💰 REWARD: %d CASH (SINGLE-CLAIM)" % data.reward_cash
			
	var deploy_btn = briefing_modal.find_child("DeployButton", true, false)
	if deploy_btn:
		if not is_unlocked:
			deploy_btn.text = "🔒 LOCKED"
			deploy_btn.disabled = true
		elif is_completed:
			deploy_btn.text = "🔄 REPLAY MISSION"
			deploy_btn.disabled = false
		else:
			deploy_btn.text = "▶ START MISSION"
			deploy_btn.disabled = false
			
	briefing_modal.visible = true
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("on_briefing_toggled"):
		audio.on_briefing_toggled(true)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("briefing_opened"):
		event_bus.briefing_opened.emit()

func _on_close_briefing_button_pressed():
	if briefing_modal:
		briefing_modal.visible = false
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("on_briefing_toggled"):
		audio.on_briefing_toggled(false)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("briefing_closed"):
		event_bus.briefing_closed.emit()

func _on_deploy_button_pressed():
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("on_briefing_toggled"):
		audio.on_briefing_toggled(false)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("briefing_closed"):
		event_bus.briefing_closed.emit()
	if not selected_mission: return
	var save_mgr = get_node_or_null("/root/SaveManager")
	if selected_mission.unlock_requirement_id != "" and save_mgr:
		if not save_mgr.is_mission_completed(selected_mission.unlock_requirement_id):
			return
			
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		mission_mgr.start_mission(selected_mission)
	elif selected_mission.scene_path != "":
		get_tree().change_scene_to_file(selected_mission.scene_path)

func _on_back_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"): audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")

func _on_upgrade_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"): audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.UPGRADES)
	get_tree().change_scene_to_file("res://scenes/UI/ArmoryUI.tscn")

func _on_settings_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"): audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.SETTINGS)
	get_tree().change_scene_to_file("res://scenes/UI/SettingsUI.tscn")

func _update_quick_play_bar():
	if not quick_play_bar: return
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	var ch_data = CHAPTERS[current_chapter_idx]
	var found_mission: MissionData = null
	
	# Find next uncompleted mission in this chapter
	for m_path in ch_data["missions"]:
		var m = load(m_path) as MissionData
		if m and save_mgr and not save_mgr.is_mission_completed(m.mission_id):
			found_mission = m
			break
			
	# If all completed in this chapter, select the first mission for replay
	if not found_mission and not ch_data["missions"].is_empty():
		found_mission = load(ch_data["missions"][0]) as MissionData
		
	if found_mission:
		next_quick_mission = found_mission
		if quick_title_label:
			quick_title_label.text = "NEXT MISSION: %s" % found_mission.display_name.to_upper()
		if quick_desc_label:
			var obj = "Eliminate hostiles"
			match found_mission.objective_type:
				MissionData.ObjectiveType.KILL_COUNT:
					obj = "Eliminate %d infected" % found_mission.target_count
				MissionData.ObjectiveType.SURVIVE_WAVES:
					obj = "Survive %d waves" % found_mission.wave_count
				MissionData.ObjectiveType.BOSS_KILL:
					obj = "Neutralize Boss"
			quick_desc_label.text = "🎯 %s  •  💰 Reward: %d CASH" % [obj, found_mission.reward_cash]
		if quick_start_btn:
			var is_comp = save_mgr.is_mission_completed(found_mission.mission_id) if save_mgr else false
			quick_start_btn.text = "🔄 REPLAY MISSION" if is_comp else "▶ START MISSION"

func _on_quick_start_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	if next_quick_mission:
		_on_mission_selected(next_quick_mission)
