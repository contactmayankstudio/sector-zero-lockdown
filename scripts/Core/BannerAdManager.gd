extends Node

const TEST_BANNER_ID := "ca-app-pub-3940256099942544/6300978111"
const PROD_BANNER_ID := "ca-app-pub-7719493859621460/8812601577"

var banner_ad_unit_id: String = TEST_BANNER_ID
var is_banner_visible: bool = false
@export var is_test_mode: bool = true

var _native_admob = null
var _simulated_banner_layer: CanvasLayer = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if is_test_mode:
		banner_ad_unit_id = TEST_BANNER_ID
	else:
		banner_ad_unit_id = PROD_BANNER_ID

	if Engine.has_singleton("SectorZeroAdMob"):
		_native_admob = Engine.get_singleton("SectorZeroAdMob")

	if _native_admob and _native_admob.has_method("init_banner"):
		_native_admob.init_banner(banner_ad_unit_id, is_test_mode)
	else:
		print("[BannerAdManager] Native banners not detected. Simulated AdMob Test Banner is ACTIVE (Unit: %s)" % banner_ad_unit_id)

	call_deferred("_connect_state_listener")

func set_ad_unit_id(new_id: String):
	banner_ad_unit_id = new_id
	if _native_admob and _native_admob.has_method("load_banner"):
		_native_admob.load_banner(banner_ad_unit_id, is_test_mode)

func _connect_state_listener():
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm and gsm.has_signal("state_changed"):
		var callback = Callable(self, "_on_game_state_changed")
		if not gsm.state_changed.is_connected(callback):
			gsm.state_changed.connect(callback)
		_on_game_state_changed(gsm.current_state, gsm.current_state)

func _on_game_state_changed(_old_state, new_state):
	if _should_show_for_state(new_state):
		show_banner()
	else:
		hide_banner()

func _should_show_for_state(state) -> bool:
	var gsm = get_node_or_null("/root/GameStateManager")
	if not gsm:
		return false
	return state in [
		gsm.State.MAIN_MENU,
		gsm.State.MISSION_SELECT,
		gsm.State.MISSION_COMPLETE,
		gsm.State.MISSION_FAILED,
		gsm.State.UPGRADES,
		gsm.State.SETTINGS
	]

func refresh_current_state():
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm:
		_on_game_state_changed(gsm.current_state, gsm.current_state)

func show_banner():
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm and not _should_show_for_state(gsm.current_state):
		hide_banner()
		return
	if is_banner_visible:
		return

	is_banner_visible = true
	if _native_admob and _native_admob.has_method("show_banner"):
		_native_admob.show_banner()
	else:
		_show_simulated_banner()

func hide_banner():
	if not is_banner_visible:
		return
	is_banner_visible = false
	if _native_admob and _native_admob.has_method("hide_banner"):
		_native_admob.hide_banner()
	_hide_simulated_banner()

func _show_simulated_banner():
	if is_instance_valid(_simulated_banner_layer):
		return
	_simulated_banner_layer = CanvasLayer.new()
	_simulated_banner_layer.layer = 110
	add_child(_simulated_banner_layer)

	var bar = PanelContainer.new()
	bar.anchor_left = 0.5
	bar.anchor_right = 0.5
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_left = -160
	bar.offset_right = 160
	bar.offset_top = -54
	bar.offset_bottom = -4
	bar.custom_minimum_size = Vector2(320, 50)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.09, 0.95)
	style.border_color = Color(0.2, 0.5, 0.9, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("panel", style)
	_simulated_banner_layer.add_child(bar)

	var lbl = Label.new()
	lbl.text = "🎯 [Google AdMob Test Banner 320x50]\nUnit: %s" % banner_ad_unit_id
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0))
	bar.add_child(lbl)

func _hide_simulated_banner():
	if is_instance_valid(_simulated_banner_layer):
		_simulated_banner_layer.queue_free()
		_simulated_banner_layer = null
