extends Node

const CONSENT_CONFIG_PATH := "user://admob_consent.cfg"
const CONSENT_SECTION := "ads"
const PRIVACY_POLICY_URL := "https://contactmayankstudio.github.io/sector-zero-lockdown/privacy_policy.html"

var rewarded_ad_unit_id: String = "ca-app-pub-7719493859621460/2646648479"
var is_ad_ready: bool = false
var is_showing_ad: bool = false

signal reward_granted(reward_type: String, extra_data: Dictionary)
signal ad_completed(reward_type: String)
signal ad_failed(reason: String)

var _native_admob = null
var _current_reward_type: String = ""
var _current_extra_data: Dictionary = {}
var _disclosure_layer: CanvasLayer
var _rewarded_retry_timer: Timer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Engine.has_singleton("SectorZeroAdMob"):
		_native_admob = Engine.get_singleton("SectorZeroAdMob")
	if not _native_admob:
		print("[AdManager] Native ads are available only in the Android export; rewards stay disabled here.")
		return

	_connect_native_signals()
	match _load_ads_choice():
		"agree":
			if _native_admob.has_method("request_consent"):
				_native_admob.request_consent()
		"not_now":
			if _native_admob.has_method("disable_ads"):
				_native_admob.disable_ads()
		_:
			call_deferred("_show_ads_disclosure")

func _connect_native_signals():
	_connect_native_signal("consent_ready", _on_consent_ready)
	_connect_native_signal("rewarded_video_loaded", _on_rewarded_video_loaded)
	_connect_native_signal("rewarded_video_failed_to_load", _on_rewarded_video_failed)
	_connect_native_signal("rewarded_video_rewarded", _on_rewarded_video_rewarded)
	_connect_native_signal("rewarded_video_closed", _on_rewarded_video_closed)
	_connect_native_signal("rewarded_video_failed_to_show", _on_rewarded_video_failed)

func _connect_native_signal(signal_name: String, callback: Callable):
	if _native_admob.has_signal(signal_name) and not _native_admob.is_connected(signal_name, callback):
		_native_admob.connect(signal_name, callback)

func show_ads_preferences():
	if _native_admob:
		_show_ads_disclosure()

func open_privacy_policy():
	OS.shell_open(PRIVACY_POLICY_URL)

func _show_ads_disclosure():
	if not _native_admob or is_instance_valid(_disclosure_layer):
		return

	var viewport_size := get_viewport().get_visible_rect().size
	var panel_size := Vector2(
		minf(920.0, maxf(320.0, viewport_size.x - 40.0)),
		minf(620.0, maxf(360.0, viewport_size.y - 32.0))
	)
	_disclosure_layer = CanvasLayer.new()
	_disclosure_layer.layer = 120
	add_child(_disclosure_layer)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.04, 0.94)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_disclosure_layer.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -panel_size.x * 0.5
	panel.offset_right = panel_size.x * 0.5
	panel.offset_top = -panel_size.y * 0.5
	panel.offset_bottom = panel_size.y * 0.5
	panel.custom_minimum_size = panel_size
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.075, 0.095, 1.0)
	panel_style.border_color = Color(0.92, 0.64, 0.18, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(16)
	panel.add_theme_stylebox_override("panel", panel_style)
	backdrop.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	margin.add_child(content)

	var title := Label.new()
	title.text = "ADVERTISING & DATA CHOICES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36, 1.0))
	content.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 290)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	var message := Label.new()
	message.text = "Sector Zero: Lockdown uses Google AdMob for banner and optional rewarded ads. If you agree, Google may receive your IP address (which can estimate your general location), ad interactions such as app launches, taps and video views, diagnostics such as app launch time and SDK performance, and device or advertising identifiers. Google uses these data for advertising, analytics and fraud prevention. Google says the data it collects through this SDK is encrypted in transit.\n\nYour game progress and settings stay on this device. An internet connection is needed for ads. Choose “Not now” to keep playing without ads or related ad-data requests. You can change this choice any time in Settings."
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message.add_theme_font_size_override("font_size", 20)
	scroll.add_child(message)

	var policy_button := LinkButton.new()
	policy_button.text = "READ THE FULL PRIVACY POLICY"
	policy_button.pressed.connect(open_privacy_policy)
	content.add_child(policy_button)

	var agree_button := Button.new()
	agree_button.text = "AGREE AND CONTINUE"
	agree_button.custom_minimum_size = Vector2(0, 56)
	agree_button.pressed.connect(_on_ads_consent_agreed)
	content.add_child(agree_button)

	var decline_button := Button.new()
	decline_button.text = "NOT NOW — CONTINUE WITHOUT ADS"
	decline_button.custom_minimum_size = Vector2(0, 56)
	decline_button.pressed.connect(_on_ads_consent_declined)
	content.add_child(decline_button)

func _close_ads_disclosure():
	if is_instance_valid(_disclosure_layer):
		_disclosure_layer.queue_free()
	_disclosure_layer = null

func _on_ads_consent_agreed():
	_save_ads_choice("agree")
	_close_ads_disclosure()
	if _native_admob and _native_admob.has_method("request_consent"):
		_native_admob.request_consent()

func _on_ads_consent_declined():
	_save_ads_choice("not_now")
	_close_ads_disclosure()
	is_ad_ready = false
	if is_showing_ad:
		is_showing_ad = false
		ad_failed.emit("Ads were turned off in privacy settings.")
	_current_reward_type = ""
	_current_extra_data.clear()
	var banner_manager = get_node_or_null("/root/BannerAdManager")
	if banner_manager:
		banner_manager.hide_banner()
	if _native_admob and _native_admob.has_method("disable_ads"):
		_native_admob.disable_ads()
	_on_consent_ready(false)

func _load_ads_choice() -> String:
	var config := ConfigFile.new()
	if config.load(CONSENT_CONFIG_PATH) != OK:
		return ""
	return str(config.get_value(CONSENT_SECTION, "choice", ""))

func _save_ads_choice(choice: String):
	var config := ConfigFile.new()
	config.load(CONSENT_CONFIG_PATH)
	config.set_value(CONSENT_SECTION, "choice", choice)
	var err := config.save(CONSENT_CONFIG_PATH)
	if err != OK:
		push_warning("[AdManager] Couldn't save the advertising choice (error %d)." % err)

func set_ad_unit_id(new_id: String):
	rewarded_ad_unit_id = new_id
	if _native_admob and _native_admob.has_method("load_rewarded_video") and _native_admob.can_request_ads():
		_native_admob.load_rewarded_video(rewarded_ad_unit_id)

func show_rewarded_ad(reward_type: String = "cash", extra_data: Dictionary = {}):
	if is_showing_ad:
		ad_failed.emit("A rewarded ad is already open.")
		return
	if not _native_admob or not _native_admob.has_method("show_rewarded_video"):
		ad_failed.emit("Rewarded ads are unavailable on this device.")
		return
	if not _native_admob.can_request_ads():
		ad_failed.emit("Ads are off or unavailable until the required privacy choices are complete.")
		return
	if not is_ad_ready:
		_request_rewarded_video()
		ad_failed.emit("A rewarded ad is loading. Please try again shortly.")
		return

	_current_reward_type = reward_type
	_current_extra_data = extra_data.duplicate(true)
	is_showing_ad = true
	is_ad_ready = false
	_native_admob.show_rewarded_video()

func _on_consent_ready(can_request: bool):
	if not can_request:
		is_ad_ready = false
		var banner_manager = get_node_or_null("/root/BannerAdManager")
		if banner_manager:
			banner_manager.hide_banner()
		return
	_request_rewarded_video()
	var banner_manager = get_node_or_null("/root/BannerAdManager")
	if banner_manager:
		banner_manager.refresh_current_state()

func _request_rewarded_video():
	if _native_admob and _native_admob.has_method("load_rewarded_video") and _native_admob.can_request_ads():
		_native_admob.load_rewarded_video(rewarded_ad_unit_id)

func _schedule_rewarded_retry():
	if not is_inside_tree() or not _native_admob:
		return
	if not _rewarded_retry_timer:
		_rewarded_retry_timer = Timer.new()
		_rewarded_retry_timer.one_shot = true
		_rewarded_retry_timer.wait_time = 8.0
		_rewarded_retry_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		_rewarded_retry_timer.timeout.connect(_request_rewarded_video)
		add_child(_rewarded_retry_timer)
	_rewarded_retry_timer.start()

func _on_rewarded_video_loaded():
	is_ad_ready = true
	if _rewarded_retry_timer:
		_rewarded_retry_timer.stop()

func _on_rewarded_video_failed(reason: String):
	is_ad_ready = false
	_schedule_rewarded_retry()
	if is_showing_ad:
		is_showing_ad = false
		_current_reward_type = ""
		_current_extra_data.clear()
		ad_failed.emit(reason)

func _on_rewarded_video_closed():
	if is_showing_ad:
		is_showing_ad = false
		_current_reward_type = ""
		_current_extra_data.clear()
		ad_failed.emit("The ad closed before Google confirmed the reward.")
		_schedule_rewarded_retry()

func _on_rewarded_video_rewarded():
	if not is_showing_ad:
		return
	var reward_type := _current_reward_type
	var extra_data := _current_extra_data.duplicate(true)
	var reward_applied := _apply_reward()
	is_showing_ad = false
	if reward_applied:
		reward_granted.emit(reward_type, extra_data)
		ad_completed.emit(reward_type)
	else:
		ad_failed.emit("The ad finished, but the reward could not be applied. Please try again.")
	_current_reward_type = ""
	_current_extra_data.clear()

func _apply_reward() -> bool:
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr:
		return false

	match _current_reward_type:
		"unlock_gun":
			var weapon_id = str(_current_extra_data.get("weapon_id", ""))
			if weapon_id == "":
				return false
			var unlocked = WeaponManager.unlock_weapon(weapon_id, save_mgr)
			if not unlocked and not WeaponManager.is_weapon_owned(weapon_id, save_mgr):
				return false
			return save_mgr.set_equipped_weapon(WeaponManager.resolve_weapon_id(weapon_id))
		"rent_gun":
			var weapon_id = str(_current_extra_data.get("weapon_id", ""))
			if weapon_id != "" and save_mgr.has_method("rent_weapon"):
				return save_mgr.rent_weapon(weapon_id, 1)
		"double_cash", "cash":
			var default_amount = 500 if _current_reward_type == "cash" else 0
			var amount = int(_current_extra_data.get("amount", default_amount))
			if amount > 0 and save_mgr.has_method("add_cash"):
				save_mgr.add_cash(amount)
				return true
	return false
