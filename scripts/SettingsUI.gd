extends Control

@onready var master_slider = $ScrollContainer/VBoxContainer/AudioSection/Margin/VBox/MasterBox/MasterSlider
@onready var master_val = $ScrollContainer/VBoxContainer/AudioSection/Margin/VBox/MasterBox/MasterVal
@onready var music_slider = $ScrollContainer/VBoxContainer/AudioSection/Margin/VBox/MusicBox/MusicSlider
@onready var music_val = $ScrollContainer/VBoxContainer/AudioSection/Margin/VBox/MusicBox/MusicVal
@onready var sfx_slider = $ScrollContainer/VBoxContainer/AudioSection/Margin/VBox/SFXBox/SFXSlider
@onready var sfx_val = $ScrollContainer/VBoxContainer/AudioSection/Margin/VBox/SFXBox/SFXVal

@onready var sens_slider = $ScrollContainer/VBoxContainer/ControlsSection/Margin/VBox/SensBox/SensSlider
@onready var sens_val = $ScrollContainer/VBoxContainer/ControlsSection/Margin/VBox/SensBox/SensVal
@onready var aim_sens_slider = $ScrollContainer/VBoxContainer/ControlsSection/Margin/VBox/AimSensBox/AimSensSlider
@onready var aim_sens_val = $ScrollContainer/VBoxContainer/ControlsSection/Margin/VBox/AimSensBox/AimSensVal
@onready var invert_check = $ScrollContainer/VBoxContainer/ControlsSection/Margin/VBox/InvertBox/InvertCheck

@onready var quality_option = $ScrollContainer/VBoxContainer/GraphicsSection/Margin/VBox/QualityBox/QualityOption
@onready var privacy_options_section = $ScrollContainer/VBoxContainer/PrivacyOptionsSection
@onready var ad_consent_button = $ScrollContainer/VBoxContainer/PrivacyOptionsSection/Margin/VBox/AdConsentButton
@onready var privacy_options_button = $ScrollContainer/VBoxContainer/PrivacyOptionsSection/Margin/VBox/PrivacyOptionsButton
@onready var privacy_policy_button = $ScrollContainer/VBoxContainer/PrivacyOptionsSection/Margin/VBox/PrivacyPolicyButton

func _ready():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.SETTINGS)
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	var settings = save_mgr.data.settings if save_mgr and save_mgr.data.has("settings") else {}
	
	# Audio initialization
	var m_vol = settings.get("master_volume", 1.0)
	master_slider.value = m_vol
	master_val.text = "%d%%" % int(m_vol * 100)
	
	var mus_vol = settings.get("music_volume", 0.8)
	music_slider.value = mus_vol
	music_val.text = "%d%%" % int(mus_vol * 100)
	
	var sfx_vol = settings.get("sfx_volume", 1.0)
	sfx_slider.value = sfx_vol
	sfx_val.text = "%d%%" % int(sfx_vol * 100)
	
	# Controls initialization
	var sens = settings.get("sensitivity", 0.048)
	sens_slider.value = sens
	sens_val.text = "%.2f" % sens
	
	var aim_sens = settings.get("aim_sensitivity", 0.024)
	aim_sens_slider.value = aim_sens
	aim_sens_val.text = "%.2f" % aim_sens
	
	var inv = settings.get("invert_y", false)
	invert_check.button_pressed = inv
	
	# Graphics initialization
	var q_mgr = get_node_or_null("/root/QualityManager")
	var q_val = save_mgr.data.get("selected_quality", 1) if save_mgr else 1
	if q_mgr:
		q_val = q_mgr.current_quality
	quality_option.selected = q_val
	_configure_privacy_options()
	
	print("[%d ms] [SETTINGS] SettingsUI ready." % Time.get_ticks_msec())

func _configure_privacy_options():
	privacy_options_section.visible = false
	privacy_options_button.visible = false
	if not Engine.has_singleton("SectorZeroAdMob"):
		return
	privacy_options_section.visible = true
	var ads_plugin = Engine.get_singleton("SectorZeroAdMob")
	if ads_plugin.has_signal("privacy_options_requirement_changed"):
		var callback = Callable(self, "_on_privacy_options_requirement_changed")
		if not ads_plugin.is_connected("privacy_options_requirement_changed", callback):
			ads_plugin.connect("privacy_options_requirement_changed", callback)
	if ads_plugin.has_method("is_privacy_options_required"):
		privacy_options_button.visible = ads_plugin.is_privacy_options_required()

func _on_privacy_options_requirement_changed(required: bool):
	privacy_options_button.visible = required

func _on_ad_consent_pressed():
	var ad_manager = get_node_or_null("/root/AdManager")
	if ad_manager and ad_manager.has_method("show_ads_preferences"):
		ad_manager.show_ads_preferences()

func _on_privacy_policy_pressed():
	var ad_manager = get_node_or_null("/root/AdManager")
	if ad_manager and ad_manager.has_method("open_privacy_policy"):
		ad_manager.open_privacy_policy()

func _on_privacy_options_pressed():
	if not Engine.has_singleton("SectorZeroAdMob"):
		return
	var ads_plugin = Engine.get_singleton("SectorZeroAdMob")
	if ads_plugin.has_method("show_privacy_options_form"):
		ads_plugin.show_privacy_options_form()

func _on_master_slider_value_changed(value: float):
	master_val.text = "%d%%" % int(value * 100)
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.set_master_volume(value)
	_save_setting("master_volume", value)

func _on_music_slider_value_changed(value: float):
	music_val.text = "%d%%" % int(value * 100)
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.set_music_volume(value)
	_save_setting("music_volume", value)

func _on_sfx_slider_value_changed(value: float):
	sfx_val.text = "%d%%" % int(value * 100)
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.set_sfx_volume(value)
	_save_setting("sfx_volume", value)

func _on_sens_slider_value_changed(value: float):
	sens_val.text = "%.2f" % value
	_save_setting("sensitivity", value)

func _on_aim_sens_slider_value_changed(value: float):
	aim_sens_val.text = "%.2f" % value
	_save_setting("aim_sensitivity", value)

func _on_invert_check_toggled(button_pressed: bool):
	_save_setting("invert_y", button_pressed)

func _on_quality_option_item_selected(index: int):
	var q_mgr = get_node_or_null("/root/QualityManager")
	if q_mgr:
		q_mgr.apply_quality(index)
	var perf_mgr = get_node_or_null("/root/PerformanceManager")
	if perf_mgr:
		perf_mgr.set_profile(index)
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.data["selected_quality"] = index
		save_mgr.save_game()

func _save_setting(key: String, value):
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr and save_mgr.data.has("settings"):
		save_mgr.data.settings[key] = value
		save_mgr.save_game()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_button_pressed()

func _on_back_button_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr: audio_mgr.play_ui_click()
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		var target_state = game_state_mgr.previous_state
		if target_state == game_state_mgr.State.MAIN_MENU:
			game_state_mgr.change_state(game_state_mgr.State.MAIN_MENU)
			get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
			return
		else:
			game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
			get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")
			return
	get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")
