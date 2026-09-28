extends Node

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var ambience_volume: float = 0.7

var sounds = {
	"ui_click": "res://audio/ui/sfx_ui_click.wav",
	"victory": "res://audio/ui/sfx_victory.wav",
	"defeat": "res://audio/ui/sfx_defeat.wav",
	"footstep": "res://audio/player/sfx_footstep.wav",
	"hit_body": "res://audio/ui/sfx_hitmarker_tick.wav",
	"hit_headshot": "res://audio/ui/sfx_hitmarker_tick.wav",
	"slowmo_enter": "res://audio/ui/sfx_slowmo_enter.wav",
	"slowmo_exit": "res://audio/ui/sfx_slowmo_exit.wav"
}

var ambience_paths = {
	"ambience_airport": "res://audio/ambience/sfx_ambience_airport.wav",
	"ambience_metro": "res://audio/ambience/sfx_ambience_metro.wav",
	"horror_drone": "res://audio/ambience/sfx_horror_drone.tres"
}

var bg_player: AudioStreamPlayer = null
var horror_drone_player: AudioStreamPlayer = null
var combat_music_player: AudioStreamPlayer = null
var is_combat_music_active: bool = false
var current_ambience_key: String = ""

var is_paused: bool = false
var is_briefing_open: bool = false
var is_ducked: bool = false

func _load_audio(base_path: String, fallback_path: String = "") -> AudioStream:
	var clean_path = base_path.trim_suffix(".wav").trim_suffix(".tres")
	var tres_path = clean_path + ".tres"
	var wav_path = clean_path + ".wav"
	if ResourceLoader.exists(tres_path):
		var s = load(tres_path)
		if s: return s
	if ResourceLoader.exists(wav_path):
		var s = load(wav_path)
		if s: return s
	if ResourceLoader.exists(base_path):
		var s = load(base_path)
		if s: return s
	if fallback_path != "":
		var clean_fb = fallback_path.trim_suffix(".wav").trim_suffix(".tres")
		var f_tres = clean_fb + ".tres"
		var f_wav = clean_fb + ".wav"
		if ResourceLoader.exists(f_tres):
			var s = load(f_tres)
			if s: return s
		if ResourceLoader.exists(f_wav):
			var s = load(f_wav)
			if s: return s
		if ResourceLoader.exists(fallback_path):
			return load(fallback_path)
	return null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Ensure default bus layout is active if running in standalone/test harnesses
	_ensure_bus_layout()
	
	_load_saved_volumes()
	apply_volumes()
	
	bg_player = AudioStreamPlayer.new()
	bg_player.bus = "Ambience"
	bg_player.volume_db = 0.0
	add_child(bg_player)
	
	horror_drone_player = AudioStreamPlayer.new()
	horror_drone_player.name = "HorrorDronePlayer"
	horror_drone_player.bus = "Ambience"
	horror_drone_player.volume_db = -12.0
	add_child(horror_drone_player)
	
	combat_music_player = AudioStreamPlayer.new()
	combat_music_player.name = "CombatMusicPlayer"
	combat_music_player.bus = "Music"
	combat_music_player.volume_db = -1.5
	add_child(combat_music_player)
	combat_music_player.finished.connect(_on_combat_music_finished)
	
	_connect_signals()
	call_deferred("_connect_signals")
	call_deferred("_load_saved_volumes")
	
	print("[%d ms] [BOOT:03] AudioManager ready." % Time.get_ticks_msec())

func _load_saved_volumes():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr and save_mgr.data.has("settings"):
		var s = save_mgr.data.settings
		master_volume = s.get("master_volume", master_volume)
		music_volume = s.get("music_volume", music_volume)
		sfx_volume = s.get("sfx_volume", sfx_volume)
		ambience_volume = s.get("ambience_volume", ambience_volume)
		apply_volumes()

func _connect_signals():
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm:
		if gsm.has_signal("state_changed") and not gsm.state_changed.is_connected(_on_game_state_changed):
			gsm.state_changed.connect(_on_game_state_changed)
		if gsm.has_signal("pause_toggled") and not gsm.pause_toggled.is_connected(_on_pause_toggled):
			gsm.pause_toggled.connect(_on_pause_toggled)
			
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		if event_bus.has_signal("briefing_opened") and not event_bus.briefing_opened.is_connected(_on_briefing_opened):
			event_bus.briefing_opened.connect(_on_briefing_opened)
		if event_bus.has_signal("briefing_closed") and not event_bus.briefing_closed.is_connected(_on_briefing_closed):
			event_bus.briefing_closed.connect(_on_briefing_closed)
		if event_bus.has_signal("wave_started") and not event_bus.wave_started.is_connected(_on_wave_started):
			event_bus.wave_started.connect(_on_wave_started)
		if event_bus.has_signal("wave_completed") and not event_bus.wave_completed.is_connected(_on_wave_completed):
			event_bus.wave_completed.connect(_on_wave_completed)
		if event_bus.has_signal("mission_finished") and not event_bus.mission_finished.is_connected(_on_mission_finished):
			event_bus.mission_finished.connect(_on_mission_finished)

func _on_wave_started(_w, _t):
	play_combat_music()

func _on_wave_completed(_w):
	stop_combat_music(0.8)

func _on_mission_finished(_id, _s):
	stop_combat_music(0.5)

func _on_combat_music_finished():
	if is_combat_music_active and combat_music_player:
		combat_music_player.play()

func _ensure_bus_layout():
	if AudioServer.get_bus_index("SFX") == -1 or AudioServer.get_bus_index("Ambience") == -1:
		if ResourceLoader.exists("res://default_bus_layout.tres"):
			var layout = load("res://default_bus_layout.tres")
			if layout is AudioBusLayout:
				AudioServer.set_bus_layout(layout)

func _on_game_state_changed(_old_state, new_state):
	var gsm = get_node_or_null("/root/GameStateManager")
	if not gsm: return
	if new_state == gsm.State.GAMEPLAY:
		play_horror_drone(-12.0)
	elif new_state in [gsm.State.MAIN_MENU, gsm.State.MISSION_SELECT]:
		stop_horror_drone()

func _on_pause_toggled(paused: bool):
	is_paused = paused
	set_ducking(is_paused or is_briefing_open)

func _on_briefing_opened():
	on_briefing_toggled(true)

func _on_briefing_closed():
	on_briefing_toggled(false)

func on_briefing_toggled(opened: bool):
	is_briefing_open = opened
	set_ducking(is_paused or is_briefing_open)

func set_ducking(ducked: bool):
	is_ducked = ducked
	var music_idx = AudioServer.get_bus_index("Music")
	var amb_idx = AudioServer.get_bus_index("Ambience")
	var duck_offset = -12.0 if ducked else 0.0
	var cutoff = 800.0 if ducked else 20000.0
	
	if music_idx != -1:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume) + duck_offset)
		if AudioServer.get_bus_effect_count(music_idx) > 0:
			var eff = AudioServer.get_bus_effect(music_idx, 0)
			if eff is AudioEffectLowPassFilter:
				eff.cutoff_hz = cutoff
			AudioServer.set_bus_effect_enabled(music_idx, 0, ducked)
			
	if amb_idx != -1:
		AudioServer.set_bus_volume_db(amb_idx, linear_to_db(ambience_volume) + duck_offset)
		if AudioServer.get_bus_effect_count(amb_idx) > 0:
			var eff = AudioServer.get_bus_effect(amb_idx, 0)
			if eff is AudioEffectLowPassFilter:
				eff.cutoff_hz = cutoff
			AudioServer.set_bus_effect_enabled(amb_idx, 0, ducked)

func toggle_mute() -> bool:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		var muted = AudioServer.is_bus_mute(master_idx)
		AudioServer.set_bus_mute(master_idx, not muted)
		return not muted
	return false

func is_muted() -> bool:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		return AudioServer.is_bus_mute(master_idx)
	return false

func play_sfx(sound_name: String):
	if sounds.has(sound_name):
		var stream_path = sounds[sound_name]
		var stream = _load_audio(stream_path)
		if not stream:
			return
		var p = AudioStreamPlayer.new()
		p.stream = stream
		p.bus = "SFX"
		add_child(p)
		p.finished.connect(func(): p.queue_free())
		p.play()

func play_hit_confirm(is_headshot: bool = false):
	if is_headshot:
		play_sfx("hit_headshot")
	else:
		play_sfx("hit_body")

func play_slowmo_enter():
	play_sfx("slowmo_enter")

func play_slowmo_exit():
	play_sfx("slowmo_exit")

func play_combat_music():
	if not combat_music_player: return
	is_combat_music_active = true
	if not combat_music_player.stream:
		var s = _load_audio("res://audio/music/bgm_combat_loop.wav")
		if s: combat_music_player.stream = s
	if combat_music_player.stream and not combat_music_player.playing:
		combat_music_player.volume_db = -24.0
		combat_music_player.play()
		var tw = create_tween()
		tw.tween_property(combat_music_player, "volume_db", -1.5, 1.2).set_ease(Tween.EASE_OUT)

func stop_combat_music(fade_dur: float = 1.0):
	is_combat_music_active = false
	if combat_music_player and combat_music_player.playing:
		var tw = create_tween()
		tw.tween_property(combat_music_player, "volume_db", -36.0, fade_dur)
		tw.tween_callback(combat_music_player.stop)

func play_sound_3d(stream: AudioStream, pos: Vector3, max_dist: float = 25.0):
	if not stream: return
	var p = AudioStreamPlayer3D.new()
	p.stream = stream
	p.bus = "SFX"
	p.max_distance = max_dist
	p.global_position = pos
	get_tree().root.add_child(p)
	p.finished.connect(func(): p.queue_free())
	p.play()

func play_ui_click():
	play_sfx("ui_click")

func play_victory():
	play_sfx("victory")
	duck_ambience(0.2, 3.0)

func play_defeat():
	play_sfx("defeat")
	duck_ambience(0.2, 3.0)

func play_ambience(stream_path: String):
	if bg_player:
		var s = _load_audio(stream_path) if not ResourceLoader.exists(stream_path) else load(stream_path)
		if s:
			bg_player.stream = s
			bg_player.volume_db = 0.0
			bg_player.play()

func play_location_ambience(location_name: String):
	var key = "ambience_airport"
	if "metro" in location_name.to_lower() or "railway" in location_name.to_lower():
		key = "ambience_metro"
	elif "train" in location_name.to_lower():
		key = "ambience_metro"
		
	if current_ambience_key != key and ambience_paths.has(key):
		current_ambience_key = key
		if not bg_player:
			bg_player = AudioStreamPlayer.new()
			bg_player.bus = "Ambience"
			bg_player.volume_db = 0.0
			add_child(bg_player)
		var s = _load_audio(ambience_paths[key]) if not ResourceLoader.exists(ambience_paths[key]) else load(ambience_paths[key])
		if s:
			bg_player.stream = s
			bg_player.volume_db = 0.0
			bg_player.play()

func duck_ambience(factor: float, duration: float):
	if not bg_player: return
	var ducked_db = linear_to_db(clamp(factor, 0.001, 1.0))
	var tween = create_tween()
	tween.tween_property(bg_player, "volume_db", ducked_db, 0.2)
	tween.tween_interval(duration)
	tween.tween_property(bg_player, "volume_db", 0.0, 0.5)

func play_horror_drone(vol_db: float = -12.0):
	if not horror_drone_player:
		horror_drone_player = AudioStreamPlayer.new()
		horror_drone_player.name = "HorrorDronePlayer"
		horror_drone_player.bus = "Ambience"
		add_child(horror_drone_player)
	if not horror_drone_player.stream:
		var s = _load_audio("res://audio/ambience/sfx_horror_drone")
		if s:
			if s is AudioStreamWAV:
				s.loop_mode = AudioStreamWAV.LOOP_FORWARD
			horror_drone_player.stream = s
	horror_drone_player.volume_db = vol_db
	if not horror_drone_player.playing and horror_drone_player.stream:
		horror_drone_player.play()

func stop_horror_drone():
	if horror_drone_player and horror_drone_player.playing:
		horror_drone_player.stop()

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("Master")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(master_volume))

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("Music")
	if idx != -1:
		var offset = -12.0 if is_ducked else 0.0
		AudioServer.set_bus_volume_db(idx, linear_to_db(music_volume) + offset)

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("SFX")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(sfx_volume))

func set_ambience_volume(value: float):
	ambience_volume = clamp(value, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("Ambience")
	var offset = -12.0 if is_ducked else 0.0
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(ambience_volume) + offset)

func apply_volumes():
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	set_ambience_volume(ambience_volume)
	set_ducking(is_ducked)
