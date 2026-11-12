class_name MissionInfoPanel
extends PanelContainer

signal deploy_requested(mission_data: MissionData)
signal armory_requested()
signal panel_closed()

@onready var mission_num_label = $Margin/VBox/HeaderHBox/MissionNumLabel
@onready var title_label = $Margin/VBox/HeaderHBox/TitleLabel
@onready var close_btn = $Margin/VBox/HeaderHBox/CloseBtn

@onready var location_label = $Margin/VBox/InfoGrid/LocationLabel
@onready var threat_label = $Margin/VBox/InfoGrid/ThreatLabel
@onready var objective_label = $Margin/VBox/InfoGrid/ObjectiveLabel
@onready var intel_label = $Margin/VBox/InfoGrid/IntelLabel
@onready var best_result_label = $Margin/VBox/InfoGrid/BestResultLabel
@onready var reward_label = $Margin/VBox/InfoGrid/RewardLabel
@onready var equipped_label = get_node_or_null("Margin/VBox/InfoGrid/EquippedLabel")

@onready var deploy_button = $Margin/VBox/ActionHBox/DeployButton
@onready var armory_button = $Margin/VBox/ActionHBox/ArmoryButton

var current_mission: MissionData = null

func _ready():
	visible = false
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
	if deploy_button:
		deploy_button.pressed.connect(_on_deploy_pressed)
	if armory_button:
		armory_button.pressed.connect(_on_armory_pressed)

func show_mission(data: MissionData, idx: int):
	current_mission = data
	var save_mgr = get_node_or_null("/root/SaveManager")
	
	# Show equipped weapon
	if equipped_label:
		var eq_name = "M4A1 Sentinel"
		if save_mgr and save_mgr.has_method("get_equipped_weapon"):
			var eq_id = save_mgr.get_equipped_weapon()
			var entry = WeaponManager.get_weapon_entry(eq_id)
			eq_name = entry.get("display_name", eq_id.to_upper())
		equipped_label.text = "🔫 EQUIPPED: " + eq_name.to_upper()
	
	if "is_endless" in data and data.is_endless:
		mission_num_label.text = "SPECIAL MODE"
		title_label.text = "ENDLESS HORDE SURVIVAL"
		location_label.text = "📍 LOCATION: Sector Quarantine Perimeter"
		objective_label.text = "🎯 OBJECTIVE: Survive Infinite Hostile Waves"
		intel_label.text = "🧟 ENEMIES: All Mutated Bioforms"
		threat_label.text = "⭐ DIFFICULTY: MAXIMUM (INFINITE WAVES)"
		
		var best_w = save_mgr.get_highest_wave() if save_mgr and save_mgr.has_method("get_highest_wave") else 0
		var best_s = save_mgr.get_highest_score() if save_mgr and save_mgr.has_method("get_highest_score") else 0
		best_result_label.text = "🏆 RECORD: Wave %d (Score: %d)" % [best_w, best_s]
		reward_label.text = "💰 REWARD: +15 CASH per Kill"
		
		var unlocked = save_mgr.is_endless_unlocked() if save_mgr else true
		if unlocked:
			deploy_button.text = "▶ START SURVIVAL"
			deploy_button.disabled = false
		else:
			deploy_button.text = "🔒 LOCKED (CLEAR 12-7 BOSS)"
			deploy_button.disabled = true
	else:
		var mid_str = data.mission_id
		if mid_str != "" and "-" in mid_str:
			mission_num_label.text = "MISSION %s" % mid_str
		else:
			mission_num_label.text = "MISSION %02d" % idx
		title_label.text = data.display_name.to_upper()
		
		var loc = data.location_name if ("location_name" in data and data.location_name != "") else "Sector Zero"
		location_label.text = "📍 LOCATION: " + loc
		
		var stars_count = data.difficulty_stars if "difficulty_stars" in data else 1
		var stars_str = ""
		for i in range(5):
			stars_str += "★" if i < stars_count else "☆"
		threat_label.text = "⭐ DIFFICULTY: " + stars_str
		
		var obj_text = "Eliminate hostiles"
		match data.objective_type:
			MissionData.ObjectiveType.KILL_COUNT:
				obj_text = "Eliminate %d infected across %d waves" % [data.target_count, data.wave_count]
			MissionData.ObjectiveType.SURVIVE_WAVES:
				obj_text = "Survive %d waves of hostile assault" % data.wave_count
			MissionData.ObjectiveType.BOSS_KILL:
				obj_text = "Neutralize Apex Alpha Boss Specimen"
		objective_label.text = "🎯 OBJECTIVE: " + obj_text
		
		# Build enemy types string
		var enemy_types = []
		if "spawn_config" in data and data.spawn_config is Array:
			for sc in data.spawn_config:
				if sc is Dictionary and sc.has("type"):
					enemy_types.append(sc["type"].capitalize())
		intel_label.text = "🧟 ENEMIES: " + (", ".join(enemy_types) if not enemy_types.is_empty() else "Normal, Fast Runners")
		
		var is_comp = save_mgr.is_mission_completed(data.mission_id) if save_mgr else false
		var is_unlocked = true
		if data.unlock_requirement_id != "" and save_mgr:
			is_unlocked = save_mgr.is_mission_completed(data.unlock_requirement_id)
			
		var stars_earned = save_mgr.get_mission_stars(data.mission_id) if save_mgr and save_mgr.has_method("get_mission_stars") else 0
		var stars_display = ""
		for i in range(3):
			stars_display += "★" if i < stars_earned else "☆"
		best_result_label.text = "🏆 RECORD: " + (("Cleared (" + stars_display + ")") if is_comp else "Not Completed")
		
		if is_comp:
			reward_label.text = "💰 REWARD: %d CASH (CLAIMED)" % data.reward_cash
			deploy_button.text = "🔄 REPLAY MISSION"
			deploy_button.disabled = false
		elif is_unlocked:
			reward_label.text = "💰 REWARD: %d CASH" % data.reward_cash
			deploy_button.text = "▶ START MISSION"
			deploy_button.disabled = false
		else:
			reward_label.text = "💰 REWARD: %d CASH" % data.reward_cash
			var req = data.unlock_requirement_id
			if req != "":
				deploy_button.text = "🔒 LOCKED (CLEAR %s)" % req
			else:
				deploy_button.text = "🔒 LOCKED"
			deploy_button.disabled = true
			
	# Smooth entrance animation
	visible = true
	modulate.a = 0.0
	position.y += 25
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	tw.tween_property(self, "position:y", position.y - 25, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_deploy_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	if current_mission:
		deploy_requested.emit(current_mission)

func _on_armory_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	armory_requested.emit()

func _on_close_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.15)
	await tw.finished
	visible = false
	panel_closed.emit()
