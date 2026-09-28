extends Control

@onready var title_label = $Center/Panel/VBox/Title
@onready var kills_label = $Center/Panel/VBox/Kills
@onready var headshots_label = $Center/Panel/VBox/Headshots
@onready var accuracy_label = $Center/Panel/VBox/Accuracy
@onready var score_label = $Center/Panel/VBox/Score
@onready var cash_label = $Center/Panel/VBox/CashLabel
@onready var next_button = $Center/Panel/VBox/NextButton
@onready var replay_button = $Center/Panel/VBox/ReplayButton

@onready var armory_button = find_child("ArmoryButton", true, false)
@onready var map_button = find_child("MapButton", true, false)
@onready var grade_label = find_child("GradeLabel", true, false)
@onready var total_cash_label = find_child("TotalCashLabel", true, false)
@onready var double_reward_button = find_child("DoubleRewardButton", true, false)

var last_mission: MissionData = null
var current_bounty: int = 0
var has_doubled_cash: bool = false

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_next_pressed()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		if not mission_mgr.mission_completed.is_connected(_on_mission_completed):
			mission_mgr.mission_completed.connect(_on_mission_completed)
		if not mission_mgr.mission_failed.is_connected(_on_mission_failed):
			mission_mgr.mission_failed.connect(_on_mission_failed)
			
	if armory_button and not armory_button.pressed.is_connected(_on_armory_pressed):
		armory_button.pressed.connect(_on_armory_pressed)
	if map_button and not map_button.pressed.is_connected(_on_map_pressed):
		map_button.pressed.connect(_on_map_pressed)
	if double_reward_button and not double_reward_button.pressed.is_connected(_on_double_cash_pressed):
		double_reward_button.pressed.connect(_on_double_cash_pressed)
		
	hide()

func _on_mission_completed(mission: MissionData):
	last_mission = mission
	var mission_mgr = get_node_or_null("/root/MissionManager")
	var stats = mission_mgr.last_stats if (mission_mgr and "last_stats" in mission_mgr) else {}
	var kills = stats.get("kills", mission.target_count if mission else 0)
	var headshots_val = stats.get("headshots", 0)
	var accuracy = stats.get("accuracy", 80)
	var score = stats.get("score", 0)
	var bounty_awarded = stats.get("bounty_awarded", stats.get("cash", mission.reward_cash if mission else 100))
	var is_first_time = stats.get("first_time_reward", bounty_awarded > 0)
	var stars = stats.get("stars", 1)
	var highest_wave = stats.get("highest_wave", 0)
	
	# Endless mode or Campaign complete result
	if mission and mission.is_endless:
		title_label.text = "SURVIVED TO WAVE %d" % highest_wave
		title_label.modulate = Color(1.0, 0.85, 0.2)
	elif mission and mission.mission_id in ["12-7", "mission_12"]:
		title_label.text = "CAMPAIGN COMPLETE // ENDLESS UNLOCKED"
		title_label.modulate = Color(1.0, 0.85, 0.2)
	else:
		title_label.text = "MISSION COMPLETE"
		title_label.modulate = Color(0.2, 0.95, 0.4)
	
	kills_label.text = "Zombies Eliminated: %d" % kills
	headshots_label.text = "Headshots: %d" % headshots_val
	
	# Star rating display
	var star_text = ""
	for i in range(3):
		star_text += "★" if i < stars else "☆"
	accuracy_label.text = "Accuracy: %d%%  %s" % [accuracy, star_text]
	score_label.text = "Score: %d" % score
	
	# Tactical debriefing grade
	if grade_label:
		var hs_ratio = float(headshots_val) / max(1.0, float(kills))
		if accuracy >= 80 and hs_ratio >= 0.4:
			grade_label.text = "GRADE: S [OUTSTANDING]"
			grade_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		elif accuracy >= 70 or hs_ratio >= 0.25:
			grade_label.text = "GRADE: A [EXCELLENT]"
			grade_label.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
		elif accuracy >= 50:
			grade_label.text = "GRADE: B [EFFECTIVE]"
			grade_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
		else:
			grade_label.text = "GRADE: C [ACCEPTABLE]"
			grade_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	var current_total_cash = save_mgr.data.cash if save_mgr else 0
	if total_cash_label:
		total_cash_label.text = "TOTAL SECTOR CASH: %d" % current_total_cash
	
	current_bounty = bounty_awarded
	has_doubled_cash = false
	if double_reward_button:
		if bounty_awarded > 0:
			double_reward_button.visible = true
			double_reward_button.disabled = false
			double_reward_button.text = "🎬 2X CASH: DOUBLE REWARD (+%d CASH)" % bounty_awarded
		else:
			double_reward_button.visible = false

	if mission and mission.is_endless:
		var best = save_mgr.get_highest_wave() if save_mgr else 0
		cash_label.text = "Cash earned during run  |  Best: Wave %d" % best
	elif not is_first_time or bounty_awarded == 0:
		cash_label.text = "Reward: 0 CASH (CLAIMED)"
	else:
		cash_label.text = "Reward: 0 CASH"
		var tween = create_tween()
		tween.tween_method(func(val: int): cash_label.text = "Reward: +%d CASH" % val, 0, bounty_awarded, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var next_m = mission_mgr.get_next_mission(mission) if (mission_mgr and mission_mgr.has_method("get_next_mission")) else null
	if next_button:
		next_button.visible = true
		if next_m != null:
			next_button.text = "NEXT MISSION ▶"
		else:
			next_button.text = "CONTINUE ▶"
	replay_button.visible = true
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_victory()
		
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	modulate.a = 0.0
	scale = Vector2(0.96, 0.96)
	pivot_offset = size / 2.0
	show()
	var in_tween = create_tween().set_parallel(true)
	in_tween.tween_property(self, "modulate:a", 1.0, 0.22)
	in_tween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var p_node = get_tree().get_first_node_in_group("player")
	if p_node and p_node.get("auto_pilot"):
		get_tree().create_timer(2.5).timeout.connect(func():
			if is_inside_tree() and visible:
				_on_next_pressed()
		)

func _on_mission_failed(mission: MissionData):
	last_mission = mission
	var mission_mgr = get_node_or_null("/root/MissionManager")
	var stats = mission_mgr.last_stats if (mission_mgr and "last_stats" in mission_mgr) else {}
	var kills = stats.get("kills", 0)
	var headshots = stats.get("headshots", 0)
	var accuracy = stats.get("accuracy", 0)
	var score = stats.get("score", 0)
	var highest_wave = stats.get("highest_wave", 0)
	var highest_score = stats.get("highest_score", 0)
	var save_mgr = get_node_or_null("/root/SaveManager")
	var best_wave = save_mgr.get_highest_wave() if save_mgr else highest_wave
	
	if mission and mission.is_endless:
		title_label.text = "RUN ENDED AT WAVE %d" % highest_wave
		score_label.text = "Score: %d  |  Best: %d" % [score, highest_score]
		cash_label.text = "Run reward: +%d CASH  |  Personal best: Wave %d" % [int(stats.get("cash", 0)), best_wave]
	else:
		title_label.text = "MISSION FAILED"
		score_label.text = "Score: %d" % score
		cash_label.text = "Reward: 0 CASH (MISSION FAILED)"
		
	title_label.modulate = Color(1.0, 0.25, 0.2)
	kills_label.text = "Zombies Eliminated: %d" % kills
	headshots_label.text = "Headshots: %d" % headshots
	accuracy_label.text = "Accuracy: %d%%" % accuracy
	
	if grade_label:
		grade_label.text = "GRADE: F [CASUALTY]"
		grade_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
		
	var current_total_cash = save_mgr.data.cash if save_mgr else 0
	if total_cash_label:
		total_cash_label.text = "TOTAL SECTOR CASH: %d" % current_total_cash
	
	current_bounty = int(stats.get("cash", 0)) if mission and mission.is_endless else 0
	has_doubled_cash = false
	if double_reward_button:
		double_reward_button.visible = current_bounty > 0
		double_reward_button.disabled = false
		if current_bounty > 0:
			double_reward_button.text = "WATCH AD TO DOUBLE RUN CASH (+%d)" % current_bounty

	next_button.visible = false
	replay_button.visible = true
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_defeat()
		
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	modulate.a = 0.0
	scale = Vector2(0.96, 0.96)
	pivot_offset = size / 2.0
	show()
	var in_tween = create_tween().set_parallel(true)
	in_tween.tween_property(self, "modulate:a", 1.0, 0.22)
	in_tween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_next_pressed():
	hide()
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr: audio_mgr.play_ui_click()
	
	var mission_mgr = get_node_or_null("/root/MissionManager")
	var next_m = mission_mgr.get_next_mission(last_mission) if (mission_mgr and last_mission and mission_mgr.has_method("get_next_mission")) else null
	if next_m:
		print("[%d ms] [RESULT_UI] Advancing to next mission: %s (%s)" % [Time.get_ticks_msec(), next_m.mission_id, next_m.display_name])
		mission_mgr.start_mission(next_m)
	else:
		var game_state_mgr = get_node_or_null("/root/GameStateManager")
		if game_state_mgr:
			game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
		get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")

func _on_map_pressed():
	hide()
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr: audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
	get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")

func _on_replay_pressed():
	hide()
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr: audio_mgr.play_ui_click()
	
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr and last_mission:
		mission_mgr.start_mission(last_mission)
	else:
		get_tree().reload_current_scene()

func _on_armory_pressed():
	hide()
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr: audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.UPGRADES)
	get_tree().change_scene_to_file("res://scenes/UI/ArmoryUI.tscn")

func _on_double_cash_pressed():
	if has_doubled_cash or current_bounty <= 0:
		return
		
	var ad_mgr = get_node_or_null("/root/AdManager")
	if not ad_mgr:
		return
		
	var bonus = current_bounty
	var fail_cb: Callable
	var cb = func(rtype: String, _data: Dictionary):
		if ad_mgr.ad_failed.is_connected(fail_cb):
			ad_mgr.ad_failed.disconnect(fail_cb)
		if rtype == "double_cash":
			has_doubled_cash = true
			var save_mgr = get_node_or_null("/root/SaveManager")
			var new_total = save_mgr.data.cash if save_mgr else 0
			if double_reward_button:
				double_reward_button.disabled = true
				double_reward_button.text = "✓ 2X CASH CLAIMED (+%d BONUS)" % bonus
			if cash_label:
				cash_label.text = "Reward: +%d CASH (2X DOUBLED!)" % (bonus * 2)
				cash_label.modulate = Color(1.0, 0.85, 0.2)
			if total_cash_label:
				total_cash_label.text = "TOTAL SECTOR CASH: %d" % new_total
			var audio_mgr = get_node_or_null("/root/AudioManager")
			if audio_mgr and audio_mgr.has_method("play_ui_click"):
				audio_mgr.play_ui_click()

	if not ad_mgr.reward_granted.is_connected(cb):
		ad_mgr.reward_granted.connect(cb, CONNECT_ONE_SHOT)
	fail_cb = func(reason: String):
		if ad_mgr.reward_granted.is_connected(cb):
			ad_mgr.reward_granted.disconnect(cb)
		if double_reward_button:
			double_reward_button.disabled = false
			double_reward_button.text = "WATCH AD TO DOUBLE CASH"
		print("[RESULT_UI] Rewarded ad unavailable: ", reason)
	if not ad_mgr.ad_failed.is_connected(fail_cb):
		ad_mgr.ad_failed.connect(fail_cb, CONNECT_ONE_SHOT)

	ad_mgr.show_rewarded_ad("double_cash", {"amount": current_bounty})
