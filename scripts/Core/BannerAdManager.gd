extends Node

var banner_ad_unit_id: String = "ca-app-pub-7719493859621460/8812601577"
var is_banner_visible: bool = false
var is_test_mode: bool = false

var _native_admob = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Engine.has_singleton("SectorZeroAdMob"):
		_native_admob = Engine.get_singleton("SectorZeroAdMob")

	if _native_admob and _native_admob.has_method("init_banner"):
		_native_admob.init_banner(banner_ad_unit_id, is_test_mode)
	else:
		print("[BannerAdManager] Native banners are available only in the Android export; no simulated banner is shown.")

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

func hide_banner():
	if not is_banner_visible:
		return
	is_banner_visible = false
	if _native_admob and _native_admob.has_method("hide_banner"):
		_native_admob.hide_banner()
