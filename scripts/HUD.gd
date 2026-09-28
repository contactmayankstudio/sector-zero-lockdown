extends CanvasLayer

@onready var health_bar = $Control/TopBar/Margin/HBox/LeftBox/HBoxHP/HealthBar
@onready var hp_label = $Control/TopBar/Margin/HBox/LeftBox/HBoxHP/HPLabel
@onready var wave_label = $Control/TopBar/Margin/HBox/LeftBox/WaveLabel
@onready var mission_name_label = $Control/TopBar/Margin/HBox/CenterBox/MissionName
@onready var objective_label = $Control/TopBar/Margin/HBox/CenterBox/ObjectiveLabel
@onready var cash_label = $Control/TopBar/Margin/HBox/RightBox/CashLabel
@onready var ammo_label = $Control/TopBar/Margin/HBox/RightBox/AmmoLabel
@onready var pause_button = $Control/TopBar/Margin/HBox/PauseButton
@onready var boss_health_bar = $Control/BossHealthBar
@onready var boss_name_label = $Control/BossHealthBar/BossName

@onready var crosshair = $Control/Crosshair
@onready var hitmarker = $Control/Crosshair/Hitmarker

@onready var virtual_joystick = $Control/VirtualJoystick
@onready var look_area = $Control/LookArea
@onready var fire_button = $Control/FireButton
@onready var reload_button = $Control/ReloadButton
@onready var switch_button = $Control/SwitchButton
@onready var grenade_button = $Control/GrenadeButton
@onready var damage_overlay_node = $Control/DamageOverlay if has_node("Control/DamageOverlay") else null
@onready var directional_damage = $Control/DirectionalDamage if has_node("Control/DirectionalDamage") else null
@onready var claw_scratch_overlay = $Control/ClawScratchOverlay if has_node("Control/ClawScratchOverlay") else null
@onready var blood_splatter_overlay = $Control/BloodSplatterOverlay if has_node("Control/BloodSplatterOverlay") else null
@onready var low_hp_vignette = $Control/LowHPVignette if has_node("Control/LowHPVignette") else null
@onready var heartbeat_player = $HeartbeatPlayer if has_node("HeartbeatPlayer") else ($HeartbeatAudio if has_node("HeartbeatAudio") else null)
@onready var heartbeat_audio = heartbeat_player

@onready var pause_menu = $PauseMenu
@onready var resume_btn = $PauseMenu/Panel/VBox/ResumeBtn
@onready var restart_btn = $PauseMenu/Panel/VBox/RestartBtn
@onready var settings_btn = $PauseMenu/Panel/VBox/SettingsBtn
@onready var exit_btn = $PauseMenu/Panel/VBox/ExitBtn

@onready var confirm_modal = get_node_or_null("PauseMenu/ConfirmModal")
@onready var confirm_title = get_node_or_null("PauseMenu/ConfirmModal/ConfirmPanel/Margin/VBox/ConfirmTitle")
@onready var confirm_desc = get_node_or_null("PauseMenu/ConfirmModal/ConfirmPanel/Margin/VBox/ConfirmDesc")
@onready var cancel_action_btn = get_node_or_null("PauseMenu/ConfirmModal/ConfirmPanel/Margin/VBox/HBox/CancelActionBtn")
@onready var proceed_action_btn = get_node_or_null("PauseMenu/ConfirmModal/ConfirmPanel/Margin/VBox/HBox/ProceedActionBtn")
var pending_confirm_action: String = ""

var player = null
var look_touch_id: int = -1
var fire_touch_id: int = -1
var is_game_over: bool = false
var hitmarker_timer: SceneTreeTimer = null

func _ready():
	add_to_group("hud")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_damage_overlay()
	_connect_controls()
	_connect_pause_menu()
	if get_tree():
		await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player") if get_tree() else null
	
	var input_ctrl = get_tree().get_first_node_in_group("input_controller")
	if not input_ctrl:
		input_ctrl = get_node_or_null("/root/InputController")
	if input_ctrl and input_ctrl.has_signal("pause_pressed"):
		if not input_ctrl.pause_pressed.is_connected(toggle_pause):
			input_ctrl.pause_pressed.connect(toggle_pause)
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr and "data" in save_mgr:
		update_cash(save_mgr.data.cash)
		
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		if not mission_mgr.mission_completed.is_connected(_on_game_over):
			mission_mgr.mission_completed.connect(_on_game_over)
		if not mission_mgr.mission_failed.is_connected(_on_game_over):
			mission_mgr.mission_failed.connect(_on_game_over)
			
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.objective_updated.connect(func(title, _desc, prog, target):
			if target <= 0:
				update_objective(title, "ENDLESS SURVIVAL  •  WAVE %d" % prog)
			else:
				update_objective(title, "Zombies Remaining: %d" % max(0, target - prog))
		)
		event_bus.weapon_fired.connect(func(_w, _c, _m): expand_crosshair())
		event_bus.wave_started.connect(func(wave_num: int, total_waves: int):
			update_wave(wave_num, total_waves)
			_show_wave_banner(wave_num, total_waves, false)
		)
		event_bus.wave_completed.connect(func(wave_num: int):
			_show_wave_banner(wave_num, 0, true)
		)
		if event_bus.has_signal("boss_health_changed"):
			event_bus.boss_health_changed.connect(func(cur_hp: float, max_hp: float):
				if cur_hp > 0.0:
					show_boss_health("APEX MUTANT", max_hp)
					update_boss_health(cur_hp)
				else:
					update_boss_health(0.0)
			)
		if event_bus.has_signal("enemy_killed"):
			event_bus.enemy_killed.connect(_on_enemy_killed)

var damage_overlay: ColorRect
var active_damage_arcs: Array = []
var active_claw_scratches: Array = []
var active_blood_splatters: Array = []
var low_hp_pulse_timer: float = 0.0
var is_low_hp_active: bool = false
var current_player_hp: float = 100.0
var claw_scratch_texture: ImageTexture = null
var previous_health: float = 100.0
var active_threat_markers: Array = []
var _threat_poll_timer: float = 0.0

func _init_damage_overlay():
	if has_node("Control/DamageOverlay"):
		damage_overlay = $Control/DamageOverlay
	else:
		damage_overlay = ColorRect.new()
		damage_overlay.name = "DamageOverlay"
		damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		damage_overlay.color = Color(0.8, 0.0, 0.0, 0.0)
		damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if has_node("Control"):
			$Control.add_child(damage_overlay)
			$Control.move_child(damage_overlay, 0)
	
	_init_directional_damage()
	_init_low_hp_vignette()
	_init_heartbeat_audio()

func _init_blood_splatter_overlay():
	if not blood_splatter_overlay and has_node("Control"):
		if has_node("Control/BloodSplatterOverlay"):
			blood_splatter_overlay = $Control/BloodSplatterOverlay
		else:
			blood_splatter_overlay = Control.new()
			blood_splatter_overlay.name = "BloodSplatterOverlay"
			blood_splatter_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			blood_splatter_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$Control.add_child(blood_splatter_overlay)
	
	if blood_splatter_overlay:
		blood_splatter_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not blood_splatter_overlay.draw.is_connected(_on_blood_splatter_draw):
			blood_splatter_overlay.draw.connect(_on_blood_splatter_draw)

func _init_low_hp_vignette():
	if not low_hp_vignette and has_node("Control"):
		if has_node("Control/LowHPVignette"):
			low_hp_vignette = $Control/LowHPVignette
		else:
			low_hp_vignette = TextureRect.new()
			low_hp_vignette.name = "LowHPVignette"
			low_hp_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
			low_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
			low_hp_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			low_hp_vignette.stretch_mode = TextureRect.STRETCH_SCALE
			low_hp_vignette.modulate = Color(1, 1, 1, 0)
			$Control.add_child(low_hp_vignette)
	
	if low_hp_vignette:
		low_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not low_hp_vignette.texture:
			var grad = Gradient.new()
			grad.set_color(0, Color(1.0, 0.30, 0.05, 0.0))
			grad.add_point(0.40, Color(1.0, 0.30, 0.05, 0.0))
			grad.add_point(0.72, Color(1.0, 0.24, 0.03, 0.22))
			grad.set_color(1, Color(1.0, 0.18, 0.02, 0.42))
			var grad_tex = GradientTexture2D.new()
			grad_tex.gradient = grad
			grad_tex.fill = GradientTexture2D.FILL_RADIAL
			grad_tex.fill_from = Vector2(0.5, 0.5)
			grad_tex.fill_to = Vector2(0.5, 0.0)
			grad_tex.width = 512
			grad_tex.height = 288
			low_hp_vignette.texture = grad_tex

func _init_heartbeat_audio():
	if not heartbeat_player:
		if has_node("HeartbeatPlayer"):
			heartbeat_player = $HeartbeatPlayer
		elif has_node("HeartbeatAudio"):
			heartbeat_player = $HeartbeatAudio
		else:
			heartbeat_player = AudioStreamPlayer.new()
			heartbeat_player.name = "HeartbeatPlayer"
			heartbeat_player.bus = "SFX"
			heartbeat_player.process_mode = Node.PROCESS_MODE_PAUSABLE
			heartbeat_player.volume_db = -6.0
			add_child(heartbeat_player)
	heartbeat_player.bus = "SFX"
	heartbeat_audio = heartbeat_player
	
	if heartbeat_player and not heartbeat_player.stream:
		var hb_stream = null
		if ResourceLoader.exists("res://audio/player/sfx_heartbeat_loop.wav"):
			hb_stream = load("res://audio/player/sfx_heartbeat_loop.wav")
		if not hb_stream and FileAccess.file_exists("res://audio/player/sfx_heartbeat_loop.wav"):
			hb_stream = _load_wav_stream("res://audio/player/sfx_heartbeat_loop.wav")
		if hb_stream:
			if hb_stream is AudioStreamWAV:
				hb_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			heartbeat_player.stream = hb_stream

func _load_wav_stream(path: String) -> AudioStreamWAV:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	var bytes = file.get_buffer(file.get_length())
	if bytes.size() < 44:
		return null
	
	var stream = AudioStreamWAV.new()
	var channels = bytes.decode_u16(22)
	var sample_rate = bytes.decode_u32(24)
	var bits_per_sample = bytes.decode_u16(34)
	
	stream.stereo = (channels == 2)
	stream.mix_rate = sample_rate
	if bits_per_sample == 16:
		stream.format = AudioStreamWAV.FORMAT_16_BITS
	elif bits_per_sample == 8:
		stream.format = AudioStreamWAV.FORMAT_8_BITS
	
	var offset = 12
	while offset < bytes.size() - 8:
		var chunk_id = bytes.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_len = bytes.decode_u32(offset + 4)
		if chunk_id == "data":
			stream.data = bytes.slice(offset + 8, min(bytes.size(), offset + 8 + chunk_len))
			break
		offset += 8 + chunk_len
	
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / (2 if bits_per_sample == 16 else 1)
	return stream

func _init_directional_damage():
	if not directional_damage and has_node("Control"):
		if has_node("Control/DirectionalDamage"):
			directional_damage = $Control/DirectionalDamage
		else:
			directional_damage = Control.new()
			directional_damage.name = "DirectionalDamage"
			directional_damage.set_anchors_preset(Control.PRESET_FULL_RECT)
			directional_damage.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$Control.add_child(directional_damage)
			$Control.move_child(directional_damage, 1)
	
	if directional_damage:
		if not directional_damage.draw.is_connected(_on_directional_damage_draw):
			directional_damage.draw.connect(_on_directional_damage_draw)

func _init_claw_scratch_overlay():
	if not claw_scratch_overlay and has_node("Control"):
		if has_node("Control/ClawScratchOverlay"):
			claw_scratch_overlay = $Control/ClawScratchOverlay
		else:
			claw_scratch_overlay = Control.new()
			claw_scratch_overlay.name = "ClawScratchOverlay"
			claw_scratch_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			claw_scratch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$Control.add_child(claw_scratch_overlay)
			$Control.move_child(claw_scratch_overlay, 1)
	
	_generate_claw_scratch_texture()
	
	if claw_scratch_overlay:
		if not claw_scratch_overlay.draw.is_connected(_on_claw_scratch_draw):
			claw_scratch_overlay.draw.connect(_on_claw_scratch_draw)

func _generate_claw_scratch_texture():
	var width = 512
	var height = 288
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var rakes = [
		{"origin": Vector2(width * 0.95, height * 0.05), "dir": Vector2(-0.85, 0.52), "length": 180.0, "spacing": 16.0, "claws": 4},
		{"origin": Vector2(width * 0.05, height * 0.35), "dir": Vector2(0.82, 0.58), "length": 140.0, "spacing": 14.0, "claws": 3},
		{"origin": Vector2(width * 0.92, height * 0.92), "dir": Vector2(-0.78, -0.62), "length": 150.0, "spacing": 15.0, "claws": 4}
	]
	
	for rake in rakes:
		var perp = Vector2(-rake.dir.y, rake.dir.x).normalized()
		for c in range(rake.claws):
			var claw_offset = perp * ((c - (rake.claws - 1) * 0.5) * rake.spacing)
			var curr = rake.origin + claw_offset
			var steps = int(rake.length / 3.0)
			for s in range(steps):
				var progress = float(s) / float(steps)
				var thickness = sin(progress * PI) * 4.5 + 1.2
				var jitter = (sin(s * 1.7) * 1.5 + cos(s * 0.8) * 1.2) * (1.0 - progress * 0.5)
				curr += (rake.dir * 3.0) + (perp * jitter)
				
				if s % 7 == 0 and s > 5 and s < steps - 5:
					var drop_pos = curr + perp * (sin(s * 3.1) * 9.0)
					_stamp_blood_drop(img, int(drop_pos.x), int(drop_pos.y), randf_range(1.5, 3.2), Color(0.7, 0.03, 0.03, 0.85))
				
				_paint_scratch_point(img, int(curr.x), int(curr.y), thickness, progress)
	
	claw_scratch_texture = ImageTexture.create_from_image(img)

func _paint_scratch_point(img: Image, cx: int, cy: int, radius: float, progress: float):
	var r_int = int(ceil(radius)) + 1
	var w = img.get_width()
	var h = img.get_height()
	for dy in range(-r_int, r_int + 1):
		for dx in range(-r_int, r_int + 1):
			var px = cx + dx
			var py = cy + dy
			if px >= 0 and px < w and py >= 0 and py < h:
				var dist = sqrt(dx * dx + dy * dy)
				if dist <= radius:
					var norm = dist / radius
					var col = Color(
						lerp(0.95, 0.45, norm),
						lerp(0.12, 0.02, norm),
						lerp(0.10, 0.01, norm),
						lerp(0.95, 0.35, norm) * (1.0 - progress * 0.3)
					)
					var existing = img.get_pixel(px, py)
					img.set_pixel(px, py, existing.blend(col))

func _stamp_blood_drop(img: Image, cx: int, cy: int, radius: float, color: Color):
	var r_int = int(ceil(radius))
	var w = img.get_width()
	var h = img.get_height()
	for dy in range(-r_int, r_int + 1):
		for dx in range(-r_int, r_int + 1):
			var px = cx + dx
			var py = cy + dy
			if px >= 0 and px < w and py >= 0 and py < h:
				if dx * dx + dy * dy <= radius * radius:
					var existing = img.get_pixel(px, py)
					img.set_pixel(px, py, existing.blend(color))


func _connect_controls():
	if virtual_joystick:
		virtual_joystick.visible = true
		virtual_joystick.mouse_filter = Control.MOUSE_FILTER_STOP
		if not virtual_joystick.movement_changed.is_connected(_on_joystick_movement):
			virtual_joystick.movement_changed.connect(_on_joystick_movement)
		
	if fire_button:
		if not fire_button.button_down.is_connected(_on_fire_button_down):
			fire_button.button_down.connect(_on_fire_button_down)
		if not fire_button.button_up.is_connected(_on_fire_button_up):
			fire_button.button_up.connect(_on_fire_button_up)
		if not fire_button.gui_input.is_connected(_on_fire_button_input):
			fire_button.gui_input.connect(_on_fire_button_input)
		
	if reload_button:
		reload_button.pressed.connect(func():
			if get_tree().paused: return
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			if player and player.has_method("_trigger_reload"):
				player._trigger_reload()
		)
		
	if switch_button:
		switch_button.pressed.connect(func():
			if get_tree().paused: return
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			if player and player.has_method("switch_weapon"):
				player.switch_weapon()
		)
		
	if grenade_button:
		grenade_button.pressed.connect(func():
			if get_tree().paused: return
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			if player and player.has_method("throw_grenade"):
				player.throw_grenade()
		)
		
	if look_area:
		look_area.gui_input.connect(_on_look_area_input)
		
	if pause_button:
		pause_button.pressed.connect(func():
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			toggle_pause()
		)

func trigger_damage_effect(intensity: float = 1.0, attacker_pos: Vector3 = Vector3.ZERO):
	if attacker_pos != Vector3.ZERO:
		show_damage_indicator(attacker_pos)
	else:
		show_damage_arc(randf_range(-0.5, 0.5), intensity)

func _on_joystick_movement(vec: Vector2):
	if is_game_over or get_tree().paused: return
	if player and player.has_method("set_virtual_movement"):
		player.set_virtual_movement(vec)

func _on_fire_button_down():
	if is_game_over or get_tree().paused: return
	if player and player.has_method("start_fire"):
		player.start_fire()

func _on_fire_button_up():
	fire_touch_id = -1
	if player and player.has_method("stop_fire"):
		player.stop_fire()

func _on_fire_button_input(event: InputEvent):
	if is_game_over or get_tree().paused: return
	if event is InputEventScreenTouch:
		if event.pressed:
			fire_touch_id = event.index
			if player and player.has_method("start_fire"):
				player.start_fire()
		else:
			if event.index == fire_touch_id:
				fire_touch_id = -1
				if player and player.has_method("stop_fire"):
					player.stop_fire()

func _on_look_area_input(event: InputEvent):
	if is_game_over or get_tree().paused or not player or not player.has_method("rotate_camera"):
		return
		
	if event is InputEventScreenTouch:
		if event.index == fire_touch_id:
			return
		if event.pressed:
			if look_touch_id == -1:
				look_touch_id = event.index
				if player and player.has_method("reset_camera_drag"):
					player.reset_camera_drag()
		else:
			if event.index == look_touch_id or event.is_canceled():
				look_touch_id = -1
				if player and player.has_method("reset_camera_drag"):
					player.reset_camera_drag()
	elif event is InputEventScreenDrag:
		if event.index == fire_touch_id:
			return
		if look_touch_id == -1:
			look_touch_id = event.index
		if event.index == look_touch_id:
			player.rotate_camera(event.relative.x, event.relative.y)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		player.rotate_camera(event.relative.x, event.relative.y)

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if confirm_modal and confirm_modal.visible:
				_on_confirm_cancel()
			else:
				toggle_pause()
			get_viewport().set_input_as_handled()
			return
			
	if event is InputEventScreenTouch and (not event.pressed or event.is_canceled()):
		if event.index == look_touch_id:
			look_touch_id = -1
			if player and player.has_method("reset_camera_drag"):
				player.reset_camera_drag()
		if event.index == fire_touch_id:
			fire_touch_id = -1
			if player and player.has_method("stop_fire"):
				player.stop_fire()
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fire_touch_id = -1
		if player and player.has_method("stop_fire"):
			player.stop_fire()

func show_hitmarker(is_headshot: bool = false):
	if not hitmarker:
		return
	# Tactical COD style: bright white for bodyshot, vibrant crimson for headshot
	var hit_color = Color(1.0, 0.12, 0.18, 1.0) if is_headshot else Color(1.0, 1.0, 1.0, 0.95)
	for child in hitmarker.get_children():
		if child is ColorRect:
			child.color = hit_color
	hitmarker.show()
	
	# Tactical scale punch
	hitmarker.pivot_offset = hitmarker.size / 2.0
	hitmarker.scale = Vector2(1.4, 1.4) if is_headshot else Vector2(1.18, 1.18)
	var tw_scale = create_tween()
	tw_scale.tween_property(hitmarker, "scale", Vector2.ONE, 0.09).set_ease(Tween.EASE_OUT)
	
	# Audible hit confirmation: crisp tick for bodyshots, bone crunch for headshots
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_hit_confirm"):
		audio.play_hit_confirm(is_headshot)
	else:
		_play_hitmarker_sound_fallback(is_headshot)
	
	if is_headshot:
		var lbl = Label.new()
		lbl.text = "CRITICAL HEADSHOT!"
		lbl.add_theme_color_override("font_color", hit_color)
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.set_anchors_preset(Control.PRESET_CENTER)
		lbl.position = Vector2(-70, -60)
		hitmarker.add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", -95.0, 0.45).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.45).set_delay(0.12)
		tw.tween_callback(lbl.queue_free)
	
	var cur_timer = get_tree().create_timer(0.14)
	hitmarker_timer = cur_timer
	await cur_timer.timeout
	if hitmarker_timer == cur_timer and hitmarker:
		hitmarker.hide()

var _cached_hitmarker_player: AudioStreamPlayer = null
var _cached_hitmarker_stream: AudioStream = null
func _play_hitmarker_sound_fallback(_is_headshot: bool):
	if not _cached_hitmarker_player:
		_cached_hitmarker_player = AudioStreamPlayer.new()
		_cached_hitmarker_player.bus = "SFX"
		add_child(_cached_hitmarker_player)
	if not _cached_hitmarker_stream and ResourceLoader.exists("res://audio/ui/sfx_hitmarker_tick.wav"):
		_cached_hitmarker_stream = load("res://audio/ui/sfx_hitmarker_tick.wav")
	if _cached_hitmarker_stream:
		_cached_hitmarker_player.stream = _cached_hitmarker_stream
		_cached_hitmarker_player.play()

var combo_kill_count: int = 0
var last_kill_timestamp: float = 0.0

func _on_enemy_killed(archetype: String, is_headshot: bool, _pos: Vector3):
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_kill_timestamp <= 3.2:
		combo_kill_count += 1
	else:
		combo_kill_count = 1
	last_kill_timestamp = now
	
	if archetype == "boss":
		_show_boss_eliminated_badge()
	elif combo_kill_count >= 2:
		_show_killstreak_badge(combo_kill_count, is_headshot)
	elif is_headshot:
		_show_headshot_badge()

func _show_killstreak_badge(count: int, is_headshot: bool):
	var badge_title = ""
	var badge_color = Color(1.0, 0.84, 0.0, 1.0)
	var bonus_pts = 50
	
	match count:
		2:
			badge_title = "DOUBLE KILL!"
			badge_color = Color(1.0, 0.84, 0.0, 1.0)
			bonus_pts = 50
		3:
			badge_title = "TRIPLE KILL!"
			badge_color = Color(1.0, 0.55, 0.0, 1.0)
			bonus_pts = 100
		4:
			badge_title = "QUAD KILL!"
			badge_color = Color(1.0, 0.25, 0.05, 1.0)
			bonus_pts = 150
		5:
			badge_title = "RAMPAGE!"
			badge_color = Color(1.0, 0.1, 0.2, 1.0)
			bonus_pts = 250
		_:
			badge_title = "UNSTOPPABLE! x%d" % count
			badge_color = Color(1.0, 0.05, 0.4, 1.0)
			bonus_pts = 350
			
	if is_headshot:
		bonus_pts += 50
		badge_title += " [HEADSHOT]"
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr and save_mgr.has_method("add_cash"):
		save_mgr.add_cash(bonus_pts)
		
	_create_badge_node(badge_title, "+%d PTS" % bonus_pts, badge_color, is_headshot, count)

func _show_headshot_badge():
	_create_badge_node("HEADSHOT", "+50 BONUS", Color(1.0, 0.2, 0.25, 1.0), true, 1)

func _show_boss_eliminated_badge():
	_create_badge_node("BOSS ELIMINATED!", "+1000 REWARD", Color(1.0, 0.85, 0.1, 1.0), false, 5)

func _create_badge_node(title: String, subtitle: String, main_color: Color, is_headshot: bool, pitch_mult: int = 1):
	if not has_node("Control"):
		return
	var control = $Control
	
	# Tactical Kill Badge Container
	var badge = PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.07, 0.10, 0.88)
	style.border_color = main_color
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 1
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	badge.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	badge.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.text = title
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_color_override("font_color", main_color)
	title_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title_lbl.add_theme_constant_override("shadow_offset_x", 2)
	title_lbl.add_theme_constant_override("shadow_offset_y", 2)
	title_lbl.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = subtitle
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.9))
	sub_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(sub_lbl)
	
	control.add_child(badge)
	
	var vp_size = control.size
	if vp_size == Vector2.ZERO and get_viewport():
		vp_size = get_viewport().get_visible_rect().size
	if vp_size == Vector2.ZERO:
		vp_size = Vector2(1280, 720)
		
	badge.reset_size()
	var target_x = (vp_size.x - badge.size.x) * 0.5
	var target_y = vp_size.y * 0.20
	badge.position = Vector2(target_x, target_y)
	badge.pivot_offset = badge.size * 0.5
	badge.scale = Vector2(1.35, 1.35)
	
	# Crisp audio tick/feedback (reuse cached player)
	if not _cached_hitmarker_player:
		_cached_hitmarker_player = AudioStreamPlayer.new()
		_cached_hitmarker_player.bus = "SFX"
		add_child(_cached_hitmarker_player)
	if not _cached_hitmarker_stream and ResourceLoader.exists("res://audio/ui/sfx_hitmarker_tick.wav"):
		_cached_hitmarker_stream = load("res://audio/ui/sfx_hitmarker_tick.wav")
	if _cached_hitmarker_stream:
		_cached_hitmarker_player.stream = _cached_hitmarker_stream
		_cached_hitmarker_player.pitch_scale = clamp(1.05 + float(pitch_mult) * 0.12, 1.1, 1.85)
		_cached_hitmarker_player.play()
		
	var tw = create_tween()
	tw.tween_property(badge, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.75)
	tw.tween_property(badge, "position:y", target_y - 30.0, 0.45).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(badge, "modulate:a", 0.0, 0.45).set_ease(Tween.EASE_IN)
	tw.tween_callback(badge.queue_free)

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if confirm_modal and confirm_modal.visible:
			_on_confirm_cancel()
		else:
			toggle_pause()

func _connect_pause_menu():
	if resume_btn:
		resume_btn.pressed.connect(func():
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			toggle_pause()
		)
	if restart_btn:
		restart_btn.pressed.connect(func():
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			_prompt_confirm("restart")
		)
	if settings_btn:
		settings_btn.pressed.connect(func():
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			_on_settings_pressed()
		)
	if exit_btn:
		exit_btn.pressed.connect(func():
			var audio = get_node_or_null("/root/AudioManager")
			if audio: audio.play_ui_click()
			_prompt_confirm("exit")
		)
	if cancel_action_btn:
		cancel_action_btn.pressed.connect(_on_confirm_cancel)
	if proceed_action_btn:
		proceed_action_btn.pressed.connect(_on_confirm_proceed)
		
	var dimmer = get_node_or_null("PauseMenu/Dimmer")
	if dimmer:
		dimmer.gui_input.connect(func(event: InputEvent):
			if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
				if confirm_modal and confirm_modal.visible:
					_on_confirm_cancel()
		)

func _prompt_confirm(action: String):
	pending_confirm_action = action
	if not confirm_modal:
		if action == "restart":
			_execute_restart()
		elif action == "exit":
			_execute_exit()
		return
		
	if action == "restart":
		if confirm_title: confirm_title.text = "RESTART MISSION?"
		if confirm_desc: confirm_desc.text = "Restart current operation from Wave 1? Wave progress will be lost."
	elif action == "exit":
		if confirm_title: confirm_title.text = "ABANDON OPERATION?"
		if confirm_desc: confirm_desc.text = "Return to Sector Zero tactical campaign map? Progress will be lost."
		
	confirm_modal.visible = true

func _on_confirm_cancel():
	var audio = get_node_or_null("/root/AudioManager")
	if audio: audio.play_ui_click()
	pending_confirm_action = ""
	if confirm_modal:
		confirm_modal.visible = false

func _on_confirm_proceed():
	var audio = get_node_or_null("/root/AudioManager")
	if audio: audio.play_ui_click()
	if confirm_modal:
		confirm_modal.visible = false
	if pending_confirm_action == "restart":
		_execute_restart()
	elif pending_confirm_action == "exit":
		_execute_exit()
	pending_confirm_action = ""

var _last_pause_toggle_msec: int = 0

func toggle_pause():
	if is_game_over:
		return
	var now = Time.get_ticks_msec()
	if now - _last_pause_toggle_msec < 350:
		return
	_last_pause_toggle_msec = now
		
	var should_pause = not get_tree().paused
	get_tree().paused = should_pause
	
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		if should_pause:
			game_state_mgr.current_state = game_state_mgr.State.PAUSED
			if game_state_mgr.has_signal("pause_toggled"):
				game_state_mgr.pause_toggled.emit(true)
		else:
			game_state_mgr.current_state = game_state_mgr.State.GAMEPLAY
			if game_state_mgr.has_signal("pause_toggled"):
				game_state_mgr.pause_toggled.emit(false)
			
	if pause_menu:
		pause_menu.visible = should_pause
	if pause_button:
		pause_button.text = "▶" if should_pause else "||"
		
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	look_touch_id = -1
	fire_touch_id = -1
	if player:
		if player.has_method("reset_camera_drag"):
			player.reset_camera_drag()
		if player.has_method("stop_fire"):
			player.stop_fire()
		if player.has_method("set_virtual_movement"):
			player.set_virtual_movement(Vector2.ZERO)

func _on_game_over(_m = null):
	is_game_over = true
	is_low_hp_active = false
	if heartbeat_player and heartbeat_player.playing:
		heartbeat_player.stop()
	if low_hp_vignette:
		low_hp_vignette.modulate.a = 0.0
	if pause_menu:
		pause_menu.visible = false
	if pause_button:
		pause_button.disabled = true
	look_touch_id = -1
	fire_touch_id = -1
	if has_node("Control"):
		$Control.visible = false
	if virtual_joystick:
		virtual_joystick.visible = false

func _on_restart_pressed():
	_prompt_confirm("restart")

func _execute_restart():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.resume_game()
	else:
		get_tree().paused = false
		
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr and mission_mgr.current_mission:
		mission_mgr.start_mission(mission_mgr.current_mission)
	else:
		get_tree().reload_current_scene()

func _on_settings_pressed():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.resume_game()
		game_state_mgr.change_state(game_state_mgr.State.SETTINGS)
	else:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/SettingsUI.tscn")

func _on_exit_pressed():
	_prompt_confirm("exit")

func _execute_exit():
	var game_state_mgr = get_node_or_null("/root/GameStateManager")
	if game_state_mgr:
		game_state_mgr.resume_game()
		game_state_mgr.change_state(game_state_mgr.State.MISSION_SELECT)
	else:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/MissionSelect.tscn")

var crosshair_spread: float = 0.0

func _process(delta):
	if crosshair and not is_game_over:
		crosshair_spread = lerp(crosshair_spread, 0.0, 10.0 * delta)
		var base_scale = 1.0 + crosshair_spread
		crosshair.scale = Vector2(base_scale, base_scale)
	
	# Update active directional damage indicator arcs
	if active_damage_arcs.size() > 0:
		for i in range(active_damage_arcs.size() - 1, -1, -1):
			active_damage_arcs[i]["life"] -= delta
			if active_damage_arcs[i]["life"] <= 0.0:
				active_damage_arcs.remove_at(i)
		if directional_damage:
			directional_damage.queue_redraw()
	
	# Update active off-screen threat indicators (~12 times a second)
	_threat_poll_timer += delta
	if _threat_poll_timer >= 0.08:
		_threat_poll_timer = 0.0
		_update_threat_indicators()
	
	# Update active claw scratch overlays
	if active_claw_scratches.size() > 0:
		for i in range(active_claw_scratches.size() - 1, -1, -1):
			active_claw_scratches[i]["life"] -= delta
			if active_claw_scratches[i]["life"] <= 0.0:
				active_claw_scratches.remove_at(i)
		if claw_scratch_overlay:
			claw_scratch_overlay.queue_redraw()
	
	# Update active blood splatters (2.5s dissipation lifecycle)
	if active_blood_splatters.size() > 0:
		for i in range(active_blood_splatters.size() - 1, -1, -1):
			var s = active_blood_splatters[i]
			s["life"] -= delta
			for cluster in s["clusters"]:
				for drop in cluster["droplets"]:
					drop["offset"].y += drop["drip_speed"] * delta * (s["life"] / s["max_life"])
				for strk in cluster["streaks"]:
					strk["cur_length"] = min(strk["max_length"], strk["cur_length"] + strk["drip_speed"] * delta)
			if s["life"] <= 0.0:
				active_blood_splatters.remove_at(i)
		if blood_splatter_overlay:
			blood_splatter_overlay.queue_redraw()
	
	# Update Low-HP Pulsing Red Screen Vignette and Heartbeat Audio (< 30 HP)
	var is_low_hp = (current_player_hp < 30.0) and (current_player_hp > 0.0) and (not is_game_over)
	if is_low_hp:
		low_hp_pulse_timer += delta
		# Physiological cardiac double-pulse at ~75 BPM (0.8s cycle)
		var cycle = fmod(low_hp_pulse_timer, 0.8)
		var pulse = 0.0
		if cycle < 0.20:
			pulse = sin((cycle / 0.20) * PI) # Primary systolic contraction (lub)
		elif cycle >= 0.25 and cycle < 0.42:
			pulse = sin(((cycle - 0.25) / 0.17) * PI) * 0.72 # Secondary diastolic rebound (dub)
		
		# Severity: increases as health drops from 29 down to 0
		var severity = clamp((30.0 - current_player_hp) / 30.0, 0.0, 1.0)
		var base_alpha = lerp(0.08, 0.15, severity)
		var peak_alpha = lerp(0.30, 0.42, severity)
		var target_vignette_alpha = base_alpha + (peak_alpha - base_alpha) * pulse
		
		if low_hp_vignette:
			low_hp_vignette.modulate.a = lerp(low_hp_vignette.modulate.a, target_vignette_alpha, clamp(16.0 * delta, 0.0, 1.0))
		
		# Audio management
		is_low_hp_active = true
		if heartbeat_player and heartbeat_player.stream:
			heartbeat_player.volume_db = lerp(-12.0, -3.0, severity)
			if not heartbeat_player.playing:
				heartbeat_player.play()
	else:
		# Health recovered (>= 30 HP), or player dead / mission finished -> Subside
		if is_low_hp_active:
			is_low_hp_active = false
		low_hp_pulse_timer = 0.0
		if low_hp_vignette and low_hp_vignette.modulate.a > 0.001:
			low_hp_vignette.modulate.a = move_toward(low_hp_vignette.modulate.a, 0.0, 2.5 * delta)
		if heartbeat_player and heartbeat_player.playing:
			heartbeat_player.volume_db = move_toward(heartbeat_player.volume_db, -40.0, 60.0 * delta)
			if heartbeat_player.volume_db <= -39.0:
				heartbeat_player.stop()

func expand_crosshair():
	crosshair_spread = min(crosshair_spread + 0.35, 1.5)

func update_health(value: float, max_val: float = 100.0):
	current_player_hp = value
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = value
	if hp_label:
		hp_label.text = " " + str(int(value)) + " HP"
	
	previous_health = value
	
	if damage_overlay:
		damage_overlay.color.a = 0.0



func update_ammo(current: int, total: int, weapon_name: String = "", next_weapon: String = ""):
	if ammo_label:
		if weapon_name != "":
			ammo_label.text = weapon_name.to_upper() + ": " + str(current) + " / " + str(total)
		else:
			ammo_label.text = str(current) + " / " + str(total)
	if switch_button and next_weapon != "":
		switch_button.text = "NEXT:\n" + next_weapon.to_upper()

func update_objective(title: String, detail: String = ""):
	if mission_name_label:
		mission_name_label.text = title.to_upper()
	if objective_label:
		objective_label.text = detail if detail != "" else title

func update_cash(value: int):
	if cash_label:
		cash_label.text = "CASH: " + str(value)

func update_wave(value: int, total: int = 3):
	if wave_label:
		if total <= 0:
			# Endless mode - no total
			wave_label.text = "WAVE: %d" % value
			wave_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		else:
			wave_label.text = "WAVE: %d / %d" % [value, total]
			wave_label.remove_theme_color_override("font_color")
		
		# Wave transition flash effect
		if value > 1:
			wave_label.pivot_offset = wave_label.size / 2.0
			var tw = create_tween()
			tw.tween_property(wave_label, "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_BACK)
			tw.tween_property(wave_label, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT)

var wave_banner_panel: PanelContainer = null
var wave_banner_title: Label = null
var wave_banner_subtitle: Label = null
var wave_banner_tween: Tween = null

func _setup_wave_banner():
	if wave_banner_panel: return
	
	wave_banner_panel = PanelContainer.new()
	wave_banner_panel.name = "WaveBannerPanel"
	wave_banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wave_banner_panel.custom_minimum_size = Vector2(480, 80)
	wave_banner_panel.pivot_offset = Vector2(240, 40)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.10, 0.90)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.75, 0.2, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 25
	style.content_margin_right = 25
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	wave_banner_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	wave_banner_panel.add_child(vbox)
	
	wave_banner_title = Label.new()
	wave_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_banner_title.add_theme_font_size_override("font_size", 28)
	wave_banner_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(wave_banner_title)
	
	wave_banner_subtitle = Label.new()
	wave_banner_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_banner_subtitle.add_theme_font_size_override("font_size", 14)
	wave_banner_subtitle.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	vbox.add_child(wave_banner_subtitle)
	
	wave_banner_panel.modulate.a = 0.0
	wave_banner_panel.visible = false
	
	if has_node("Control"):
		$Control.add_child(wave_banner_panel)
	else:
		add_child(wave_banner_panel)

func _show_wave_banner(wave_num: int, total_waves: int, is_cleared: bool):
	_setup_wave_banner()
	if not wave_banner_panel: return
	
	var title_text = ""
	var subtitle_text = ""
	var border_col = Color(1.0, 0.75, 0.2)
	var title_col = Color(1.0, 0.85, 0.2)
	
	if is_cleared:
		title_text = "WAVE %d CLEARED!" % wave_num
		subtitle_text = "PREPARE FOR NEXT ASSAULT..."
		border_col = Color(0.2, 0.9, 0.4, 0.9)
		title_col = Color(0.3, 1.0, 0.5)
	else:
		if total_waves > 0 and wave_num >= total_waves:
			title_text = "FINAL WAVE: %d / %d" % [wave_num, total_waves]
			subtitle_text = "WARNING: MAXIMUM THREAT - ELIMINATE ALL TARGETS!"
			border_col = Color(1.0, 0.2, 0.2, 0.9)
			title_col = Color(1.0, 0.3, 0.3)
		elif total_waves > 0:
			title_text = "WAVE %d / %d" % [wave_num, total_waves]
			subtitle_text = "HOSTILES INCOMING - DEFEND CONCOURSE"
			border_col = Color(1.0, 0.75, 0.15, 0.9)
			title_col = Color(1.0, 0.85, 0.2)
		else:
			title_text = "WAVE %d" % wave_num
			subtitle_text = "ENDLESS HORDE - SURVIVE AS LONG AS YOU CAN"
			border_col = Color(1.0, 0.75, 0.15, 0.9)
			title_col = Color(1.0, 0.85, 0.2)
			
	wave_banner_title.text = title_text
	wave_banner_title.add_theme_color_override("font_color", title_col)
	wave_banner_subtitle.text = subtitle_text
	
	var style = wave_banner_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style.border_color = border_col
		
	if has_node("Control"):
		var vp_size = $Control.size
		wave_banner_panel.position = Vector2((vp_size.x - 480) * 0.5, vp_size.y * 0.20)
		
	wave_banner_panel.visible = true
	wave_banner_panel.scale = Vector2(0.7, 0.7)
	wave_banner_panel.modulate.a = 0.0
	
	if wave_banner_tween and wave_banner_tween.is_valid():
		wave_banner_tween.kill()
		
	wave_banner_tween = create_tween()
	wave_banner_tween.tween_property(wave_banner_panel, "scale", Vector2(1.05, 1.05), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	wave_banner_tween.parallel().tween_property(wave_banner_panel, "modulate:a", 1.0, 0.2)
	wave_banner_tween.tween_property(wave_banner_panel, "scale", Vector2(1.0, 1.0), 0.1)
	wave_banner_tween.tween_interval(2.2)
	wave_banner_tween.tween_property(wave_banner_panel, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	wave_banner_tween.tween_callback(func():
		if is_instance_valid(wave_banner_panel):
			wave_banner_panel.visible = false
	)

func show_boss_health(b_name: String, max_hp: float):
	if boss_health_bar:
		boss_health_bar.max_value = max_hp
		boss_health_bar.value = max_hp
		if boss_name_label:
			boss_name_label.text = "BOSS: " + b_name.to_upper()
		boss_health_bar.show()

func update_boss_health(value: float):
	if boss_health_bar:
		boss_health_bar.value = value
		if value <= 0:
			boss_health_bar.hide()

func show_damage_indicator(from_world_pos: Vector3 = Vector3.ZERO):
	var angle = 0.0
	if from_world_pos != Vector3.ZERO and player and is_instance_valid(player):
		var cam = player.get_node_or_null("Camera3D")
		if not cam and player.has_node("Head/Camera3D"):
			cam = player.get_node("Head/Camera3D")
		if cam:
			var cam_fwd = -cam.global_transform.basis.z
			cam_fwd.y = 0.0
			cam_fwd = cam_fwd.normalized()
			var cam_right = cam.global_transform.basis.x
			cam_right.y = 0.0
			cam_right = cam_right.normalized()
			
			var to_source = (from_world_pos - player.global_position)
			to_source.y = 0.0
			if to_source.length_squared() > 0.001:
				to_source = to_source.normalized()
				var forward_dot = cam_fwd.dot(to_source)
				var right_dot = cam_right.dot(to_source)
				angle = atan2(right_dot, forward_dot)
	elif player and is_instance_valid(player):
		var zombies = get_tree().get_nodes_in_group("zombies")
		var p_pos = player.global_position
		var closest_dist = INF
		var closest_pos = Vector3.ZERO
		for z in zombies:
			if is_instance_valid(z) and not z.get("is_dead"):
				var d = z.global_position.distance_squared_to(p_pos)
				if d < closest_dist:
					closest_dist = d
					closest_pos = z.global_position
		if closest_dist < 400.0:
			show_damage_indicator(closest_pos)
			return
		angle = randf_range(-0.5, 0.5)
	
	show_damage_arc(angle)

func show_damage_arc(angle_rad: float, intensity: float = 1.0):
	var arc = {
		"angle": angle_rad,
		"life": 1.25,
		"max_life": 1.25,
		"intensity": clamp(intensity, 0.5, 1.5)
	}
	active_damage_arcs.append(arc)
	if directional_damage:
		directional_damage.queue_redraw()

func trigger_damage_indicator(from_world_pos: Vector3 = Vector3.ZERO):
	show_damage_indicator(from_world_pos)

func trigger_claw_scratch(intensity: float = 1.0):
	var vp_size = get_viewport().get_visible_rect().size if get_viewport() else Vector2(1280.0, 720.0)
	if vp_size == Vector2.ZERO:
		vp_size = Vector2(1280.0, 720.0)
	
	var corner = randi() % 4
	var scratch = {
		"life": 0.9,
		"max_life": 0.9,
		"intensity": clamp(intensity, 0.6, 1.5),
		"lines": [],
		"droplets": []
	}
	
	var num_claws = 3 + (randi() % 2)
	var start_origin = Vector2.ZERO
	var slash_dir = Vector2.ZERO
	var rake_span = 75.0
	
	match corner:
		0:
			start_origin = Vector2(randf_range(20.0, 150.0), randf_range(10.0, 80.0))
			slash_dir = Vector2(randf_range(0.6, 0.9), randf_range(0.4, 0.8)).normalized()
		1:
			start_origin = Vector2(vp_size.x - randf_range(20.0, 150.0), randf_range(10.0, 80.0))
			slash_dir = Vector2(-randf_range(0.6, 0.9), randf_range(0.4, 0.8)).normalized()
		2:
			start_origin = Vector2(randf_range(20.0, 150.0), vp_size.y - randf_range(20.0, 100.0))
			slash_dir = Vector2(randf_range(0.6, 0.9), -randf_range(0.4, 0.8)).normalized()
		3:
			start_origin = Vector2(vp_size.x - randf_range(20.0, 150.0), vp_size.y - randf_range(20.0, 100.0))
			slash_dir = Vector2(-randf_range(0.6, 0.9), -randf_range(0.4, 0.8)).normalized()
	
	var perp = Vector2(-slash_dir.y, slash_dir.x)
	var slash_len = randf_range(200.0, 310.0)
	
	for c in range(num_claws):
		var offset = perp * ((c - (num_claws - 1) * 0.5) * (rake_span / float(num_claws)))
		var pt = start_origin + offset
		var pts = PackedVector2Array()
		pts.append(pt)
		var segments = 14
		for seg in range(segments):
			var step = slash_len / float(segments)
			var jitter = perp * randf_range(-4.0, 4.0)
			pt += slash_dir * step + jitter
			pts.append(pt)
			if seg % 3 == 0 and randf() > 0.4:
				scratch["droplets"].append({
					"pos": pt + perp * randf_range(-12.0, 12.0),
					"radius": randf_range(1.5, 3.5)
				})
		scratch["lines"].append(pts)
	
	active_claw_scratches.append(scratch)
	if claw_scratch_overlay:
		claw_scratch_overlay.queue_redraw()

func show_claw_scratch(intensity: float = 1.0):
	trigger_claw_scratch(intensity)

func _update_threat_indicators():
	active_threat_markers.clear()
	if is_game_over or not player or not is_instance_valid(player):
		if directional_damage and active_damage_arcs.is_empty():
			directional_damage.queue_redraw()
		return
	
	var cam: Camera3D = player.get_node_or_null("Camera3D")
	if not cam and player.has_node("Head/Camera3D"):
		cam = player.get_node("Head/Camera3D")
	if not cam:
		return
	
	var vp = get_viewport()
	if not vp:
		return
	var vp_size = vp.get_visible_rect().size
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		vp_size = Vector2(1280.0, 720.0)
	var center = vp_size * 0.5
	var margin = 48.0
	var half_w = center.x - margin
	var half_h = center.y - margin
	
	var cam_gt = cam.global_transform
	var cam_pos = cam_gt.origin
	var cam_fwd = -cam_gt.basis.z
	var cam_right = cam_gt.basis.x
	var cam_up = cam_gt.basis.y
	
	var zombies = get_tree().get_nodes_in_group("zombies")
	if zombies.is_empty():
		if directional_damage and not active_damage_arcs.is_empty():
			directional_damage.queue_redraw()
		return
	
	var candidate_threats = []
	for z in zombies:
		if not is_instance_valid(z):
			continue
		if z.get("is_dead") == true:
			continue
		var z_pos = z.global_position + Vector3(0.0, 1.2, 0.0)
		var to_z = z_pos - cam_pos
		var dist = to_z.length()
		if dist > 35.0 or dist < 0.2:
			continue
		
		var z_fwd_dot = cam_fwd.dot(to_z)
		var is_behind = (z_fwd_dot <= 0.1)
		var is_off_screen = false
		var screen_pt = Vector2.ZERO
		
		if not is_behind:
			screen_pt = cam.unproject_position(z_pos)
			if screen_pt.x >= 70.0 and screen_pt.x <= vp_size.x - 70.0 and screen_pt.y >= 70.0 and screen_pt.y <= vp_size.y - 70.0:
				continue # Directly in player's field of view
			else:
				is_off_screen = true
		else:
			is_off_screen = true
		
		if is_off_screen:
			var dir_2d = Vector2.ZERO
			if is_behind:
				var x_dot = cam_right.dot(to_z)
				var y_dot = cam_up.dot(to_z)
				dir_2d = Vector2(x_dot, -y_dot)
				if dir_2d.length_squared() < 0.001:
					dir_2d = Vector2(0, 1)
				else:
					dir_2d = dir_2d.normalized()
			else:
				dir_2d = (screen_pt - center).normalized()
			
			var scale_x = abs(half_w / dir_2d.x) if abs(dir_2d.x) > 0.0001 else 999999.0
			var scale_y = abs(half_h / dir_2d.y) if abs(dir_2d.y) > 0.0001 else 999999.0
			var edge_pos = center + dir_2d * min(scale_x, scale_y)
			
			var archetype = str(z.get("archetype")) if "archetype" in z else "normal"
			var is_boss = (archetype == "boss")
			
			candidate_threats.append({
				"dist": dist,
				"dir": dir_2d,
				"pos": edge_pos,
				"is_boss": is_boss,
				"archetype": archetype
			})
	
	candidate_threats.sort_custom(func(a, b): return a.dist < b.dist)
	if candidate_threats.size() > 6:
		candidate_threats = candidate_threats.slice(0, 6)
	
	active_threat_markers = candidate_threats
	if directional_damage:
		directional_damage.queue_redraw()

func _on_directional_damage_draw():
	if not directional_damage: return
	var center = directional_damage.size * 0.5
	if center == Vector2.ZERO:
		center = get_viewport().get_visible_rect().size * 0.5 if get_viewport() else Vector2(640.0, 360.0)
	
	var base_radius = clamp(min(center.x, center.y) * 0.38, 90.0, 180.0)
	var half_span = deg_to_rad(30.0)
	
	for arc in active_damage_arcs:
		var progress = arc.life / arc.max_life
		var alpha = clamp(progress * arc.intensity, 0.0, 1.0)
		if alpha <= 0.001: continue
		
		var theta = arc.angle - PI * 0.5
		var start_rad = theta - half_span
		var end_rad = theta + half_span
		
		directional_damage.draw_arc(center, base_radius + 4.0, start_rad, end_rad, 28, Color(0.9, 0.02, 0.02, 0.35 * alpha), 18.0, true)
		directional_damage.draw_arc(center, base_radius, start_rad, end_rad, 28, Color(1.0, 0.12, 0.12, 0.88 * alpha), 9.0, true)
		directional_damage.draw_arc(center, base_radius - 1.0, theta - half_span * 0.45, theta + half_span * 0.45, 16, Color(1.0, 0.5, 0.5, 0.95 * alpha), 3.0, true)
		
		var chevron_dist = base_radius + 15.0
		var tip = center + Vector2(cos(theta), sin(theta)) * (chevron_dist + 12.0)
		var left_wing = center + Vector2(cos(theta - 0.14), sin(theta - 0.14)) * (chevron_dist - 3.0)
		var right_wing = center + Vector2(cos(theta + 0.14), sin(theta + 0.14)) * (chevron_dist - 3.0)
		var inner_notch = center + Vector2(cos(theta), sin(theta)) * (chevron_dist + 3.0)
		directional_damage.draw_colored_polygon(PackedVector2Array([tip, left_wing, inner_notch, right_wing]), Color(1.0, 0.22, 0.22, 0.95 * alpha))
	
	# Draw off-screen threat chevrons and distance tags
	var default_font = directional_damage.get_theme_default_font()
	if not default_font:
		default_font = ThemeDB.fallback_font
	
	for threat in active_threat_markers:
		var edge_pos: Vector2 = threat.pos
		var dir: Vector2 = threat.dir
		var dist: float = threat.dist
		var is_boss: bool = threat.is_boss
		
		var col: Color
		var marker_size: float = 14.0
		var alpha: float = clamp(1.15 - (dist / 32.0), 0.35, 1.0)
		
		if is_boss:
			col = Color(1.0, 0.18, 0.38, alpha)
			marker_size = 18.0
		elif dist < 8.0:
			col = Color(1.0, 0.15, 0.15, alpha)
		elif threat.archetype == "fast":
			col = Color(1.0, 0.60, 0.10, alpha)
		else:
			col = Color(0.95, 0.35, 0.20, alpha)
		
		var perp = Vector2(-dir.y, dir.x)
		var tip = edge_pos + dir * marker_size
		var wing1 = edge_pos - dir * (marker_size * 0.5) + perp * (marker_size * 0.75)
		var wing2 = edge_pos - dir * (marker_size * 0.5) - perp * (marker_size * 0.75)
		var notch = edge_pos - dir * (marker_size * 0.1)
		
		directional_damage.draw_colored_polygon(PackedVector2Array([tip, wing1, notch, wing2]), col)
		directional_damage.draw_polyline(PackedVector2Array([wing1, tip, wing2]), Color(1, 1, 1, alpha * 0.7), 2.0, true)
		
		var text_offset = -dir * 22.0
		var text_pos = edge_pos + text_offset + Vector2(-20, 5)
		var label_str = ("BOSS %dm" % int(dist)) if is_boss else ("%dm" % int(dist))
		if default_font:
			directional_damage.draw_string(default_font, text_pos, label_str, HORIZONTAL_ALIGNMENT_CENTER, 40, 11, col)

func _on_claw_scratch_draw():
	if not claw_scratch_overlay: return
	var vp_rect = Rect2(Vector2.ZERO, claw_scratch_overlay.size)
	if vp_rect.size == Vector2.ZERO:
		vp_rect = get_viewport().get_visible_rect() if get_viewport() else Rect2(0, 0, 1280, 720)
	
	if claw_scratch_texture and active_claw_scratches.size() > 0:
		var max_alpha = 0.0
		for s in active_claw_scratches:
			max_alpha = max(max_alpha, (s.life / s.max_life) * s.intensity)
		claw_scratch_overlay.draw_texture_rect(claw_scratch_texture, vp_rect, false, Color(1.0, 1.0, 1.0, clamp(max_alpha * 0.85, 0.0, 1.0)))
	
	for scratch in active_claw_scratches:
		var progress = scratch.life / scratch.max_life
		var alpha = clamp(progress * scratch.intensity, 0.0, 1.0)
		if alpha <= 0.001: continue
		
		for line in scratch.lines:
			if line.size() >= 2:
				claw_scratch_overlay.draw_polyline(line, Color(0.35, 0.01, 0.01, 0.85 * alpha), 9.0, true)
				claw_scratch_overlay.draw_polyline(line, Color(0.90, 0.06, 0.06, 0.95 * alpha), 5.0, true)
				claw_scratch_overlay.draw_polyline(line, Color(1.0, 0.45, 0.45, 0.80 * alpha), 2.0, true)
		
		for drop in scratch.droplets:
			claw_scratch_overlay.draw_circle(drop.pos, drop.radius, Color(0.85, 0.05, 0.05, 0.90 * alpha))

func trigger_blood_splatter(intensity: float = 1.0):
	if not blood_splatter_overlay:
		_init_blood_splatter_overlay()
	
	var vp_size = Vector2(1280.0, 720.0)
	if get_viewport():
		var v_rect = get_viewport().get_visible_rect().size
		if v_rect.x > 0 and v_rect.y > 0:
			vp_size = v_rect
	
	var splatter = {
		"life": 2.5,
		"max_life": 2.5,
		"intensity": clamp(intensity, 0.7, 2.5),
		"clusters": []
	}
	
	var num_clusters = randi_range(2, 4)
	for _c in range(num_clusters):
		# Distribute splatters across screen margins and upper/side visual fields
		var center_pos = Vector2(
			randf_range(vp_size.x * 0.06, vp_size.x * 0.94),
			randf_range(vp_size.y * 0.06, vp_size.y * 0.88)
		)
		var cluster_radius = randf_range(18.0, 38.0) * splatter["intensity"]
		var cluster = {
			"pos": center_pos,
			"radius": cluster_radius,
			"sub_blobs": [],
			"droplets": [],
			"streaks": []
		}
		
		# Organic coagulated sub-blobs around cluster center
		var num_blobs = randi_range(2, 4)
		for _b in range(num_blobs):
			var b_angle = randf() * TAU
			var b_dist = randf_range(0.0, cluster_radius * 0.5)
			cluster["sub_blobs"].append({
				"offset": Vector2(cos(b_angle), sin(b_angle)) * b_dist,
				"radius": randf_range(cluster_radius * 0.45, cluster_radius * 0.85)
			})
		
		# Satellite droplets
		var num_drops = randi_range(6, 12)
		for _d in range(num_drops):
			var angle = randf() * TAU
			var dist = randf_range(cluster_radius * 0.5, cluster_radius * 2.4)
			cluster["droplets"].append({
				"offset": Vector2(cos(angle), sin(angle)) * dist,
				"radius": randf_range(2.0, 5.5) * splatter["intensity"],
				"drip_speed": randf_range(10.0, 26.0) # Downward gravity creep
			})
		
		# Gravity drip streaks / runny dribbles running down the screen
		if _c == 0 or randf() > 0.25:
			var num_streaks = randi_range(1, 3)
			for _s in range(num_streaks):
				cluster["streaks"].append({
					"offset_x": randf_range(-cluster_radius * 0.65, cluster_radius * 0.65),
					"cur_length": 0.0,
					"max_length": randf_range(28.0, 85.0) * splatter["intensity"],
					"drip_speed": randf_range(24.0, 55.0),
					"width": randf_range(2.0, 4.2)
				})
		
		splatter["clusters"].append(cluster)
	
	active_blood_splatters.append(splatter)
	if blood_splatter_overlay:
		blood_splatter_overlay.queue_redraw()

func _on_blood_splatter_draw():
	if not blood_splatter_overlay or active_blood_splatters.is_empty():
		return
	
	for s in active_blood_splatters:
		var progress = s["life"] / s["max_life"]
		# Full opacity for first 0.5s (progress >= 0.8), then smooth cubic ease-out fade over remaining 2.0s
		var alpha_factor = 1.0 if progress >= 0.80 else pow(progress / 0.80, 1.3)
		var alpha = clamp(alpha_factor * s["intensity"], 0.0, 1.0)
		if alpha <= 0.001:
			continue
		
		var dark_blood = Color(0.32, 0.02, 0.02, 0.90 * alpha)
		var vivid_blood = Color(0.82, 0.05, 0.05, 0.95 * alpha)
		var highlight = Color(1.0, 0.45, 0.45, 0.65 * alpha)
		
		for cluster in s["clusters"]:
			var base_pos = cluster["pos"]
			
			# Central impact blotch and sub-blobs
			blood_splatter_overlay.draw_circle(base_pos, cluster["radius"], dark_blood)
			blood_splatter_overlay.draw_circle(base_pos, cluster["radius"] * 0.78, vivid_blood)
			for blob in cluster["sub_blobs"]:
				var bpos = base_pos + blob["offset"]
				blood_splatter_overlay.draw_circle(bpos, blob["radius"], dark_blood)
				blood_splatter_overlay.draw_circle(bpos, blob["radius"] * 0.75, vivid_blood)
			blood_splatter_overlay.draw_circle(base_pos + Vector2(-2, -2), cluster["radius"] * 0.28, highlight)
			
			# Downward runny streaks
			for strk in cluster["streaks"]:
				var p1 = base_pos + Vector2(strk["offset_x"], cluster["radius"] * 0.35)
				var p2 = p1 + Vector2(0, strk["cur_length"])
				blood_splatter_overlay.draw_line(p1, p2, dark_blood, strk["width"] + 1.6, true)
				blood_splatter_overlay.draw_line(p1, p2, vivid_blood, strk["width"], true)
				blood_splatter_overlay.draw_circle(p2, strk["width"] * 0.95, vivid_blood)
			
			# Satellite droplets
			for drop in cluster["droplets"]:
				var dpos = base_pos + drop["offset"]
				blood_splatter_overlay.draw_circle(dpos, drop["radius"], dark_blood)
				blood_splatter_overlay.draw_circle(dpos, drop["radius"] * 0.75, vivid_blood)
				blood_splatter_overlay.draw_circle(dpos + Vector2(-0.8, -0.8), drop["radius"] * 0.32, highlight)
