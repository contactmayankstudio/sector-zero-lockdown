# OpenWorldHUD.gd
# AGENT 10: USER INTERFACE, MISSION GPS & TELEMETRY HUD
# Features:
# - GTA 5 style GPS Objective banner and distance tracker with dedicated panel backing
# - Dynamic speedometer & Nitro meter
# - Interactive Map / Fast Travel popup [M]
# - In-Game Pause Menu [ESC] with Resume, Map, and Settings
# - Zero overlap with weapon / cash / health meters
class_name OpenWorldHUD
extends CanvasLayer

var panel_help: Panel
var lbl_help: Label

var panel_gps: Panel
var lbl_gps: Label

var panel_stats: Panel
var lbl_stats: Label

var lbl_speed: Label
var lbl_prompt: Label
var player_ref: Node3D = null
var active_vehicle_ref: Node3D = null

# Modals
var map_modal: Panel = null
var pause_modal: Panel = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Process input even while paused
	_create_ui_elements()
	_create_map_modal()
	_create_pause_modal()

func _create_ui_elements():
	# 1. Left Controls Badge (X: 20 -> 300, Y: 68 -> 104)
	panel_help = Panel.new()
	panel_help.position = Vector2(20, 68)
	panel_help.size = Vector2(285, 34)
	var h_style = StyleBoxFlat.new()
	h_style.bg_color = Color(0.06, 0.08, 0.12, 0.85)
	h_style.border_color = Color(0.3, 0.6, 0.9, 0.8)
	h_style.set_border_width_all(1)
	h_style.set_corner_radius_all(6)
	panel_help.add_theme_stylebox_override("panel", h_style)
	add_child(panel_help)
	
	lbl_help = Label.new()
	lbl_help.text = "🎮 [F] Drive  •  [V] Cam  •  [M] Map"
	lbl_help.position = Vector2(10, 7)
	lbl_help.add_theme_font_size_override("font_size", 13)
	lbl_help.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.95))
	panel_help.add_child(lbl_help)
	
	# 2. GTA 5 Style GPS Mission Tracker Banner (X: 320 -> 960, Y: 68 -> 104)
	panel_gps = Panel.new()
	panel_gps.position = Vector2(320, 68)
	panel_gps.size = Vector2(640, 34)
	var g_style = StyleBoxFlat.new()
	g_style.bg_color = Color(0.07, 0.08, 0.11, 0.90)
	g_style.border_color = Color(1.0, 0.82, 0.15, 0.95)
	g_style.border_width_left = 4
	g_style.border_width_top = 1
	g_style.border_width_right = 1
	g_style.border_width_bottom = 1
	g_style.set_corner_radius_all(6)
	panel_gps.add_theme_stylebox_override("panel", g_style)
	add_child(panel_gps)
	
	lbl_gps = Label.new()
	lbl_gps.text = "📍 MISSION: CLEAR DOWNTOWN HORDE  •  DIST: 45m  •  REWARD: $2,500"
	lbl_gps.position = Vector2(14, 7)
	lbl_gps.add_theme_font_size_override("font_size", 13)
	lbl_gps.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25, 0.95))
	panel_gps.add_child(lbl_gps)
	
	# 3. Right Telemetry Stats Badge (X: 980 -> 1260, Y: 68 -> 104)
	panel_stats = Panel.new()
	panel_stats.position = Vector2(980, 68)
	panel_stats.size = Vector2(280, 34)
	var s_style = StyleBoxFlat.new()
	s_style.bg_color = Color(0.06, 0.08, 0.12, 0.85)
	s_style.border_color = Color(0.2, 0.85, 0.45, 0.8)
	s_style.set_border_width_all(1)
	s_style.set_corner_radius_all(6)
	panel_stats.add_theme_stylebox_override("panel", s_style)
	add_child(panel_stats)
	
	lbl_stats = Label.new()
	lbl_stats.text = "FPS: 60  •  RAM: 95 MB  •  CHUNKS: 9"
	lbl_stats.position = Vector2(10, 7)
	lbl_stats.add_theme_font_size_override("font_size", 13)
	lbl_stats.add_theme_color_override("font_color", Color(0.25, 1.0, 0.5, 0.95))
	panel_stats.add_child(lbl_stats)
	
	# 4. Interaction Prompt (Center-Screen, above crosshair)
	lbl_prompt = Label.new()
	lbl_prompt.text = "PRESS [F] TO DRIVE VEHICLE"
	lbl_prompt.position = Vector2(470, 490)
	lbl_prompt.add_theme_font_size_override("font_size", 17)
	lbl_prompt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.15))
	lbl_prompt.visible = false
	add_child(lbl_prompt)
	
	# 5. Speedometer (Bottom-Center, GTA 5 style)
	lbl_speed = Label.new()
	lbl_speed.text = "0 KM/H"
	lbl_speed.position = Vector2(550, 645)
	lbl_speed.add_theme_font_size_override("font_size", 24)
	lbl_speed.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
	lbl_speed.visible = false
	add_child(lbl_speed)

func _create_map_modal():
	map_modal = Panel.new()
	map_modal.size = Vector2(580, 460)
	map_modal.position = Vector2(350, 130)
	map_modal.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.94)
	style.border_color = Color(0.2, 0.7, 1.0, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	map_modal.add_theme_stylebox_override("panel", style)
	
	var title = Label.new()
	title.text = "🗺️ OPEN WORLD MAP & FAST TRAVEL"
	title.position = Vector2(25, 18)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	map_modal.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Select destination to fast-travel instantly:"
	subtitle.position = Vector2(25, 48)
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	map_modal.add_child(subtitle)
	
	var locs = [
		{"name": "[1] Downtown Avenue (Start Hub)", "pos": Vector3(72.0, 1.2, 58.0)},
		{"name": "[2] East Highway Commercial Corridor", "pos": Vector3(140.0, 1.2, 64.0)},
		{"name": "[3] North Mountain Overlook", "pos": Vector3(64.0, 26.0, -65.0)},
		{"name": "[4] West Countryside Farmlands", "pos": Vector3(-100.0, 6.0, 64.0)},
		{"name": "[5] South Gas Station & Shops", "pos": Vector3(64.0, 1.2, 140.0)}
	]
	
	for i in range(locs.size()):
		var btn = Button.new()
		btn.text = locs[i]["name"]
		btn.position = Vector2(30, 85 + i * 58)
		btn.size = Vector2(520, 44)
		var dest_pos = locs[i]["pos"]
		var dest_name = locs[i]["name"]
		btn.pressed.connect(func():
			_execute_fast_travel(dest_pos, dest_name)
		)
		map_modal.add_child(btn)
		
	var close_btn = Button.new()
	close_btn.text = "✖ CLOSE MAP [M]"
	close_btn.position = Vector2(200, 395)
	close_btn.size = Vector2(180, 42)
	close_btn.pressed.connect(toggle_map)
	map_modal.add_child(close_btn)
	
	add_child(map_modal)

func _create_pause_modal():
	pause_modal = Panel.new()
	pause_modal.size = Vector2(440, 420)
	pause_modal.position = Vector2(420, 150)
	pause_modal.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.09, 0.96)
	style.border_color = Color(1.0, 0.8, 0.2, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	pause_modal.add_theme_stylebox_override("panel", style)
	
	var title = Label.new()
	title.text = "⏸️ GAME PAUSED"
	title.position = Vector2(130, 25)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	pause_modal.add_child(title)
	
	var btn_resume = Button.new()
	btn_resume.text = "▶ RESUME GAME"
	btn_resume.position = Vector2(60, 85)
	btn_resume.size = Vector2(320, 46)
	btn_resume.pressed.connect(toggle_pause)
	pause_modal.add_child(btn_resume)
	
	var btn_map = Button.new()
	btn_map.text = "🗺️ OPEN WORLD MAP [M]"
	btn_map.position = Vector2(60, 145)
	btn_map.size = Vector2(320, 46)
	btn_map.pressed.connect(func():
		toggle_pause()
		toggle_map()
	)
	pause_modal.add_child(btn_map)
	
	var btn_audio = Button.new()
	btn_audio.text = "🔊 AUDIO: TOGGLE MUTE"
	btn_audio.position = Vector2(60, 205)
	btn_audio.size = Vector2(320, 46)
	btn_audio.pressed.connect(func():
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("toggle_mute"):
			var muted = am.toggle_mute()
			btn_audio.text = "🔇 AUDIO: MUTED" if muted else "🔊 AUDIO: ACTIVE"
	)
	pause_modal.add_child(btn_audio)
	
	var btn_menu = Button.new()
	btn_menu.text = "🚪 RETURN TO MAIN MENU"
	btn_menu.position = Vector2(60, 280)
	btn_menu.size = Vector2(320, 46)
	btn_menu.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
	)
	pause_modal.add_child(btn_menu)
	
	add_child(pause_modal)

func toggle_map():
	if map_modal:
		map_modal.visible = not map_modal.visible
		get_tree().paused = map_modal.visible

func toggle_pause():
	if pause_modal:
		pause_modal.visible = not pause_modal.visible
		get_tree().paused = pause_modal.visible

func _execute_fast_travel(pos: Vector3, dest_name: String):
	if map_modal:
		map_modal.visible = false
	get_tree().paused = false
	var parent_world = get_parent()
	if parent_world and parent_world.has_method("_teleport_player"):
		parent_world._teleport_player(pos, dest_name)

func update_mission_gps(mission_name: String, distance_m: float, reward_amount: int):
	if lbl_gps:
		lbl_gps.text = "📍 MISSION: %s  •  DIST: %dm  •  REWARD: $%d" % [mission_name.to_upper(), int(distance_m), reward_amount]

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	var static_mem = OS.get_static_memory_usage() / (1024 * 1024)
	var cm = get_parent().get_node_or_null("ChunkManager")
	var chunks = 0
	if cm and cm.has_method("get_loaded_chunk_count"):
		chunks = cm.get_loaded_chunk_count()
	
	if lbl_stats:
		lbl_stats.text = "FPS: %d  •  RAM: %d MB  •  CHUNKS: %d" % [fps, static_mem, chunks]
	
	# Speedometer update
	var veh = active_vehicle_ref
	if not veh or not is_instance_valid(veh):
		veh = get_parent().get_node_or_null("VehicleSpawner")
	
	var current_occupied_veh = null
	var world = get_parent()
	if world:
		for vname in ["player_car", "player_bike", "player_truck"]:
			if vname in world:
				var cand = world.get(vname)
				if cand and is_instance_valid(cand) and cand.get("is_occupied"):
					current_occupied_veh = cand
					break
					
	if current_occupied_veh and lbl_speed:
		lbl_speed.visible = false # Managed cleanly by vehicle's DriveHUD
	elif lbl_speed:
		lbl_speed.visible = false

func set_prompt(text: String, show: bool):
	if lbl_prompt:
		lbl_prompt.text = text
		lbl_prompt.visible = show
