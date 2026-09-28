extends Control

var tap_count: int = 0
var tap_reset_timer: float = 0.0
var bg_cam: Camera3D = null
var bg_time: float = 0.0

@onready var quit_confirm_modal = get_node_or_null("QuitConfirmModal")
@onready var cash_display = find_child("CashDisplay", true, false)
@onready var cash_label = find_child("CashLabel", true, false)
@onready var audio_toggle_btn = find_child("AudioToggleBtn", true, false)

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_show_quit_confirm_modal()

func _ready():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.MAIN_MENU)
	var banner_mgr = get_node_or_null("/root/BannerAdManager")
	if banner_mgr and banner_mgr.has_method("refresh_current_state"):
		banner_mgr.call_deferred("refresh_current_state")
		
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_location_ambience("airport")
		_update_audio_btn_text()
		
	bg_cam = find_child("BackgroundCamera", true, false)
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	var initial_cash = save_mgr.data.cash if save_mgr and "cash" in save_mgr.data else 0
	
	if cash_label:
		cash_label.text = "CASH: %d" % initial_cash
	if cash_display and cash_display.has_method("set_cash"):
		cash_display.set_cash(initial_cash, false)
	
	# Show player progression & tactical intel
	if save_mgr:
		var hw_label = find_child("HighestWaveLabel", true, false)
		if hw_label:
			var hw = save_mgr.get_highest_wave() if save_mgr.has_method("get_highest_wave") else 0
			hw_label.text = "SURVIVAL RECORD: WAVE %d" % hw if hw > 0 else "SURVIVAL RECORD: UNTESTED"
		
		var ts_label = find_child("TotalStarsLabel", true, false)
		if ts_label:
			var ts = save_mgr.get_total_stars() if save_mgr.has_method("get_total_stars") else 0
			ts_label.text = "★ %d/36 STARS" % ts if ts > 0 else "★ 0/36"
			
		var rank_label = find_child("RankLabel", true, false)
		if rank_label:
			var completed_cnt = save_mgr.data.completed_missions.size() if "completed_missions" in save_mgr.data else 0
			if completed_cnt >= 12:
				rank_label.text = "RANK: APEX COMMANDER"
			elif completed_cnt >= 6:
				rank_label.text = "RANK: VET SPECIALIST IV"
			elif completed_cnt >= 1:
				rank_label.text = "RANK: OPERATOR II"
			else:
				rank_label.text = "RANK: RECRUIT I // READY"
				
		var loadout_label = find_child("ActiveLoadoutLabel", true, false)
		var loadout_cat = find_child("LoadoutCategory", true, false)
		if loadout_label:
			var eq_id = save_mgr.get_equipped_weapon() if save_mgr.has_method("get_equipped_weapon") else "m4a1"
			var entry = WeaponManager.get_weapon_entry(eq_id)
			loadout_label.text = "EQUIPPED: %s" % entry.get("display_name", eq_id.to_upper()).to_upper()
			if loadout_cat:
				loadout_cat.text = "[%s]" % entry.get("subtitle", "Combat Loadout")
				
		var stats_label = find_child("LifetimeStatsLabel", true, false)
		if stats_label:
			var kills = save_mgr.get_total_kills() if save_mgr.has_method("get_total_kills") else 0
			var hs = save_mgr.get_total_headshots() if save_mgr.has_method("get_total_headshots") else 0
			stats_label.text = "CONFIRMED KILLS: %d // HEADSHOTS: %d" % [kills, hs]

	var challenge_mgr = get_node_or_null("/root/ChallengeManager")
	var daily_label = find_child("DailyOpsLabel", true, false)
	if challenge_mgr and daily_label:
		if challenge_mgr.is_completed() and not challenge_mgr.is_claimed():
			challenge_mgr.claim_reward()
		var challenge = challenge_mgr.get_daily_challenge()
		var progress = challenge_mgr.get_progress()
		var target = int(challenge.get("target", 1))
		var state = "CLAIM READY" if challenge_mgr.is_completed() and not challenge_mgr.is_claimed() else ("CLAIMED" if challenge_mgr.is_claimed() else "%d/%d" % [progress, target])
		daily_label.text = "DAILY OPS: %s [%s]" % [challenge.get("title", "FIELD TASK").to_upper(), state]
		
	if quit_confirm_modal:
		quit_confirm_modal.visible = false
		
	_update_rewards_badges()
	print("[%d ms] [MAIN_MENU] MainMenu ready." % Time.get_ticks_msec())

@onready var daily_reward_btn = find_child("DailyRewardButton", true, false)
@onready var lucky_spin_btn = find_child("LuckySpinButton", true, false)

var daily_reward_modal_scene = preload("res://scenes/UI/DailyRewardModal.tscn")
var lucky_spin_modal_scene = preload("res://scenes/UI/LuckySpinModal.tscn")

func _update_rewards_badges():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr: return
	
	if daily_reward_btn:
		var claimable = save_mgr.is_daily_reward_claimable() if save_mgr.has_method("is_daily_reward_claimable") else false
		if claimable:
			daily_reward_btn.text = "🎁 REWARDS [!]"
			daily_reward_btn.modulate = Color(1.0, 0.95, 0.4)
		else:
			daily_reward_btn.text = "🎁 REWARDS"
			daily_reward_btn.modulate = Color(1.0, 1.0, 1.0)
			
	if lucky_spin_btn:
		var free_spin = save_mgr.is_free_spin_available() if save_mgr.has_method("is_free_spin_available") else false
		if free_spin:
			lucky_spin_btn.text = "🎰 LUCKY SPIN [!]"
			lucky_spin_btn.modulate = Color(0.4, 1.0, 0.6)
		else:
			lucky_spin_btn.text = "🎰 LUCKY SPIN"
			lucky_spin_btn.modulate = Color(1.0, 1.0, 1.0)

func _on_daily_reward_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
		
	var modal = daily_reward_modal_scene.instantiate()
	add_child(modal)
	modal.reward_claimed.connect(func(_amount):
		_refresh_cash_display()
		_update_rewards_badges()
	)
	modal.closed.connect(func():
		_update_rewards_badges()
	)

func _on_lucky_spin_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
		
	var modal = lucky_spin_modal_scene.instantiate()
	add_child(modal)
	modal.reward_won.connect(func(_amount):
		_refresh_cash_display()
		_update_rewards_badges()
	)
	modal.closed.connect(func():
		_update_rewards_badges()
	)

func _refresh_cash_display():
	var save_mgr = get_node_or_null("/root/SaveManager")
	var cur_cash = save_mgr.data.cash if save_mgr and "cash" in save_mgr.data else 0
	if cash_label:
		cash_label.text = "CASH: %d" % cur_cash
	if cash_display and cash_display.has_method("set_cash"):
		cash_display.set_cash(cur_cash, true)

func _process(delta):
	if tap_count > 0:
		tap_reset_timer -= delta
		if tap_reset_timer <= 0:
			tap_count = 0
			
	if bg_cam:
		bg_time += delta
		bg_cam.position.x = sin(bg_time * 0.15) * 0.8
		bg_cam.position.y = 2.2 + sin(bg_time * 0.25) * 0.12
		bg_cam.rotation.y = sin(bg_time * 0.08) * 0.04

func _on_audio_toggle_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("toggle_mute"):
		var is_now_muted = audio_mgr.toggle_mute()
		_update_audio_btn_text()
		if not is_now_muted:
			audio_mgr.play_ui_click()

func _update_audio_btn_text():
	if not audio_toggle_btn: return
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("is_muted"):
		if audio_mgr.is_muted():
			audio_toggle_btn.text = "🔇 AUDIO: OFF"
			audio_toggle_btn.modulate = Color(1, 0.4, 0.4)
		else:
			audio_toggle_btn.text = "🔊 AUDIO: ON"
			audio_toggle_btn.modulate = Color(0, 0.9, 1)

func _on_start_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
	get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")

func _on_upgrades_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.UPGRADES)
	get_tree().change_scene_to_file("res://scenes/UI/ArmoryUI.tscn")

func _on_settings_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.SETTINGS)
	get_tree().change_scene_to_file("res://scenes/UI/SettingsUI.tscn")

func _on_quit_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	_show_quit_confirm_modal()

func _show_quit_confirm_modal():
	if quit_confirm_modal:
		quit_confirm_modal.modulate.a = 0.0
		quit_confirm_modal.visible = true
		var tw = create_tween()
		tw.tween_property(quit_confirm_modal, "modulate:a", 1.0, 0.18)
	else:
		get_tree().quit()

func _on_quit_cancel_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	if quit_confirm_modal:
		var tw = create_tween()
		tw.tween_property(quit_confirm_modal, "modulate:a", 0.0, 0.15)
		tw.tween_callback(func(): quit_confirm_modal.visible = false)

func _on_quit_confirm_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	get_tree().quit()

func _on_survival_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	
	var endless_mission = load("res://resources/missions/mission_endless.tres") as MissionData
	if endless_mission:
		var mission_mgr = get_node_or_null("/root/MissionManager")
		if mission_mgr:
			mission_mgr.start_mission(endless_mission)
		else:
			get_tree().change_scene_to_file(endless_mission.scene_path)

func _on_daily_ops_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/UI/DailyOps.tscn")

# Hidden diagnostics tap trigger (5-tap version label)
func _on_version_label_gui_input(event):
	var pressed = false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
		
	if pressed:
		tap_count += 1
		tap_reset_timer = 2.0
		if tap_count >= 5:
			tap_count = 0
			var perf_mgr = get_node_or_null("/root/PerformanceManager")
			if perf_mgr:
				perf_mgr.toggle_diagnostics()
