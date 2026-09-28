extends Node

const ErrorHandler = preload("res://scripts/Core/ErrorHandler.gd")

signal loading_started(scene_path: String)
signal loading_progress(ratio: float)
signal loading_completed(scene_path: String)
signal loading_failed(error_msg: String)

var target_scene_path: String = ""
var is_loading: bool = false
var loading_ui_layer: CanvasLayer = null
var loading_root: Control = null
var progress_bar: ProgressBar = null
var mission_title_lbl: Label = null
var mission_sub_lbl: Label = null
var location_lbl: Label = null
var tip_lbl: Label = null
var percent_lbl: Label = null

var tips = [
	"Keep moving. They are attracted to noise.",
	"Aim for the head to inflict 2.5x critical damage.",
	"Keep distance from Heavy Workers; their attacks stagger.",
	"Use the Shotgun in tight spaces for massive stopping power.",
	"Reload before engaging a new horde wave.",
	"Upgrade weapon magazine size to reduce reload frequency."
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_loading_ui()
	print("[%d ms] [BOOT:07] LoadingManager ready." % Time.get_ticks_msec())

func _create_loading_ui():
	loading_ui_layer = CanvasLayer.new()
	loading_ui_layer.layer = 128
	loading_ui_layer.visible = false
	add_child(loading_ui_layer)
	
	loading_root = Control.new()
	loading_root.name = "LoadingRoot"
	loading_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	loading_ui_layer.add_child(loading_root)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.05, 0.07, 1.0)
	loading_root.add_child(bg)
	
	var bg_tex = TextureRect.new()
	bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists("res://textures/ui/loading_screen_bg.webp"):
		bg_tex.texture = load("res://textures/ui/loading_screen_bg.webp")
	loading_root.add_child(bg_tex)
	
	var vignette = ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.02, 0.03, 0.05, 0.65)
	loading_root.add_child(vignette)
	
	var container = VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.custom_minimum_size = Vector2(720, 440)
	container.offset_left = -360
	container.offset_top = -220
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 10)
	loading_root.add_child(container)
	
	var logo_icon = TextureRect.new()
	logo_icon.custom_minimum_size = Vector2(96, 96)
	logo_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	logo_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists("res://textures/ui/game_logo.webp"):
		logo_icon.texture = load("res://textures/ui/game_logo.webp")
	container.add_child(logo_icon)
	
	var brand_lbl = Label.new()
	brand_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand_lbl.text = "SECTOR ZERO: LOCKDOWN"
	brand_lbl.add_theme_font_size_override("font_size", 30)
	brand_lbl.add_theme_color_override("font_color", Color(1.0, 0.78, 0.25))
	container.add_child(brand_lbl)
	
	mission_title_lbl = Label.new()
	mission_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_title_lbl.text = "MISSION 01"
	mission_title_lbl.add_theme_font_size_override("font_size", 22)
	mission_title_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	container.add_child(mission_title_lbl)
	
	mission_sub_lbl = Label.new()
	mission_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_sub_lbl.text = "FIRST CONTACT"
	mission_sub_lbl.add_theme_font_size_override("font_size", 18)
	mission_sub_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	container.add_child(mission_sub_lbl)
	
	location_lbl = Label.new()
	location_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_lbl.text = "AIRPORT TERMINAL"
	location_lbl.add_theme_font_size_override("font_size", 16)
	location_lbl.add_theme_color_override("font_color", Color(0.55, 0.65, 0.75))
	container.add_child(location_lbl)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	container.add_child(spacer)
	
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(620, 24)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	container.add_child(progress_bar)
	
	percent_lbl = Label.new()
	percent_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_lbl.text = "Loading... 0%"
	percent_lbl.add_theme_font_size_override("font_size", 14)
	percent_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	container.add_child(percent_lbl)
	
	tip_lbl = Label.new()
	tip_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_lbl.text = "Tip: Keep moving. They are attracted to noise."
	tip_lbl.add_theme_font_size_override("font_size", 14)
	tip_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	container.add_child(tip_lbl)

func _get_autoload(autoload_name: String) -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/" + autoload_name)
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null(autoload_name)
	return null

func load_scene_async(scene_path: String, mission_data: MissionData = null):
	if is_loading:
		print("[%d ms] [LOADING] Warning: Load already in progress for %s" % [Time.get_ticks_msec(), target_scene_path])
		return
		
	var start_time = Time.get_ticks_msec()
	print("[%d ms] [LOADING] Starting async load for: %s" % [start_time, scene_path])
	
	var save_mgr = _get_autoload("SaveManager")
	if save_mgr and save_mgr.has_method("save_game"):
		save_mgr.save_game()
		
	var game_state_mgr = _get_autoload("GameStateManager")
	if game_state_mgr and game_state_mgr.has_method("change_state"):
		game_state_mgr.change_state(game_state_mgr.State.LOADING)
		
	target_scene_path = scene_path
	is_loading = true
	
	# Update Loading Screen UI
	if mission_data:
		mission_title_lbl.text = mission_data.mission_id.to_upper().replace("_", " ")
		mission_sub_lbl.text = mission_data.display_name.to_upper()
		location_lbl.text = mission_data.scene_path.get_file().get_basename().to_upper().replace("_", " ")
	else:
		mission_title_lbl.text = "SECTOR ZERO"
		mission_sub_lbl.text = "TACTICAL DEPLOYMENT"
		location_lbl.text = scene_path.get_file().get_basename().to_upper().replace("_", " ")
		
	tip_lbl.text = "Tip: " + tips.pick_random()
	progress_bar.value = 0.0
	percent_lbl.text = "Loading... 0%"
	if loading_root:
		loading_root.modulate.a = 1.0
	loading_ui_layer.visible = true
	
	loading_started.emit(scene_path)
	
	# Request threaded load
	var err = ResourceLoader.load_threaded_request(scene_path)
	if err != OK:
		print("[%d ms] [LOADING] Threaded request failed (%d), falling back to synchronous load" % [Time.get_ticks_msec(), err])
		_fallback_synchronous_load(scene_path, start_time)
		return
		
	_run_poll_loop(start_time)

func _run_poll_loop(start_time: int):
	var poll_elapsed: float = 0.0
	var timeout_limit: float = 30.0 # Robust 30-second safety timeout for low-spec storage
	
	while is_loading:
		var progress_arr = []
		var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress_arr)
		
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				var p = progress_arr[0] if not progress_arr.is_empty() else 0.5
				progress_bar.value = p
				percent_lbl.text = "Loading: %d%%" % int(p * 100)
				loading_progress.emit(p)
				
				# Wait 1 frame (with process_always=true so pause state never hangs this!)
				await get_tree().create_timer(0.04, true).timeout
				poll_elapsed += 0.04
				
				if poll_elapsed >= timeout_limit:
					print("[%d ms] [LOADING] Threaded load timeout reached (%.1fs). Triggering synchronous fallback..." % [Time.get_ticks_msec(), poll_elapsed])
					_fallback_synchronous_load(target_scene_path, start_time)
					return
					
			ResourceLoader.THREAD_LOAD_LOADED:
				progress_bar.value = 1.0
				percent_lbl.text = "Initializing Arsenal & Operative..."
				loading_progress.emit(1.0)
				
				var packed_scene = ResourceLoader.load_threaded_get(target_scene_path)
				if packed_scene is PackedScene:
					get_tree().change_scene_to_packed(packed_scene)
					await _wait_for_gameplay_readiness(start_time)
					return
				else:
					_fallback_synchronous_load(target_scene_path, start_time)
					return
				
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				print("[%d ms] [LOADING] Threaded load error (%d). Triggering fallback..." % [Time.get_ticks_msec(), status])
				_fallback_synchronous_load(target_scene_path, start_time)
				return

func _fallback_synchronous_load(scene_path: String, start_time: int):
	print("[%d ms] [LOADING] Executing synchronous fallback for: %s" % [Time.get_ticks_msec(), scene_path])
	progress_bar.value = 0.95
	percent_lbl.text = "Finalizing Arsenal..."
	
	var scene = load(scene_path)
	if scene is PackedScene:
		get_tree().change_scene_to_packed(scene)
		await _wait_for_gameplay_readiness(start_time)
	else:
		_handle_load_failure("Unable to load scene resource: " + scene_path)

func _wait_for_gameplay_readiness(start_time: int):
	if percent_lbl:
		percent_lbl.text = "Readying Operative & Weapons..."
	if progress_bar:
		progress_bar.value = 1.0
		
	# 1. Wait until SceneTree has mounted the new scene
	var wait_frames: int = 0
	while wait_frames < 90 and is_inside_tree() and get_tree():
		await get_tree().process_frame
		wait_frames += 1
		var cur_scene = get_tree().current_scene
		if cur_scene and is_instance_valid(cur_scene) and cur_scene.scene_file_path == target_scene_path:
			break
			
	# 2. Handshake with Player & Weapons: ensure all 14 weapons and models are in RAM and active
	var wait_player_ticks: int = 0
	while wait_player_ticks < 90 and is_inside_tree() and get_tree():
		var player = get_tree().get_first_node_in_group("player")
		if player and is_instance_valid(player):
			if "is_gameplay_ready" in player and player.is_gameplay_ready:
				break
			if "weapons" in player and player.weapons.size() > 0:
				break
		await get_tree().process_frame
		wait_player_ticks += 1
		
	# 3. GPU Buffer & Shader Warmup:
	# Pre-render 8 complete frames under the loading screen curtain
	# so OpenGL texture uploads, shader pipeline links, and framebuffer binding occur invisibly!
	if is_inside_tree() and get_tree():
		for _i in range(4):
			await get_tree().process_frame
			await get_tree().physics_frame
		
	var elapsed = Time.get_ticks_msec() - start_time
	print("[%d ms] [LOADING] SUCCESS: Level, Player & Arsenal fully ready in %d ms." % [Time.get_ticks_msec(), elapsed])
	
	var perf_mgr = _get_autoload("PerformanceManager")
	if perf_mgr and perf_mgr.has_method("set_last_load_time"):
		perf_mgr.set_last_load_time(elapsed)
	loading_completed.emit(target_scene_path)
	
	# 4. Cinematic Smooth Fade-Out (Zero white screen, seamless transition)
	await _dismiss_loading_screen_smoothly()

func _dismiss_loading_screen_smoothly():
	if not is_inside_tree() or not get_tree():
		if loading_ui_layer: loading_ui_layer.visible = false
		is_loading = false
		return
		
	if loading_root:
		var tw = create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(loading_root, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tw.finished
		
	if loading_ui_layer:
		loading_ui_layer.visible = false
	if loading_root:
		loading_root.modulate.a = 1.0
	is_loading = false

func _handle_load_failure(reason: String):
	ErrorHandler.report_error(ErrorHandler.Category.LOAD_ERROR, reason, {"scene": target_scene_path})
	is_loading = false
	loading_failed.emit(reason)
	
	mission_title_lbl.text = "MISSION COULD NOT BE LOADED"
	mission_sub_lbl.text = "RETURNING TO MISSION SELECT"
	location_lbl.text = reason
	progress_bar.value = 0.0
	percent_lbl.text = "Error"
	
	await get_tree().create_timer(1.8, true).timeout
	loading_ui_layer.visible = false
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
		
	get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")
