extends Control

signal closed
signal reward_won(amount: int)

@onready var wheel_node = $Panel/Margin/VBox/WheelContainer/Wheel
@onready var pointer_node = $Panel/Margin/VBox/WheelContainer/Pointer
@onready var spin_button = $Panel/Margin/VBox/SpinButton
@onready var close_button = $Panel/Margin/VBox/TopBar/CloseButton
@onready var result_label = $Panel/Margin/VBox/ResultLabel
@onready var status_label = $Panel/Margin/VBox/StatusLabel

const SPIN_COST = 500

const SLICES = [
	{"label": "₹100", "cash": 100, "weight": 30, "color": Color(0.12, 0.16, 0.22)},
	{"label": "₹250", "cash": 250, "weight": 25, "color": Color(0.08, 0.20, 0.28)},
	{"label": "₹400", "cash": 400, "weight": 18, "color": Color(0.12, 0.16, 0.22)},
	{"label": "₹600", "cash": 600, "weight": 12, "color": Color(0.08, 0.20, 0.28)},
	{"label": "₹800", "cash": 800, "weight": 8, "color": Color(0.24, 0.10, 0.15)},
	{"label": "₹2,500\nJACKPOT", "cash": 2500, "weight": 2, "color": Color(0.45, 0.35, 0.05)},
	{"label": "₹1,200\nSUPPLY", "cash": 1200, "weight": 5, "color": Color(0.24, 0.10, 0.15)},
	{"label": "₹300", "cash": 300, "weight": 20, "color": Color(0.08, 0.20, 0.28)}
]

var is_spinning: bool = false
var current_angle: float = 0.0
var last_tick_slice: int = -1

func _ready():
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if spin_button:
		spin_button.pressed.connect(_on_spin_pressed)
	if wheel_node and not wheel_node.draw.is_connected(_on_wheel_draw):
		wheel_node.draw.connect(_on_wheel_draw)
	update_button_state()

func update_button_state():
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr: return
	
	var is_free = save_mgr.is_free_spin_available()
	var current_cash = save_mgr.data.cash if "cash" in save_mgr.data else 0
	
	if is_free:
		spin_button.text = "🎰 FREE DAILY SPIN"
		spin_button.disabled = false
		status_label.text = "TODAY'S FREE LUCKY SPIN IS READY!"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		if current_cash >= SPIN_COST:
			spin_button.text = "SPIN AGAIN (₹%d CASH)" % SPIN_COST
			spin_button.disabled = false
			status_label.text = "FREE SPIN USED. SPIN AGAIN FOR ₹%d CASH." % SPIN_COST
			status_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		else:
			spin_button.text = "SPIN (NEED ₹%d CASH)" % SPIN_COST
			spin_button.disabled = true
			status_label.text = "INSUFFICIENT FUNDS. NEXT FREE SPIN TOMORROW."
			status_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))

func _on_spin_pressed():
	if is_spinning: return
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	if not save_mgr: return
	
	var is_free = save_mgr.is_free_spin_available()
	if not is_free:
		if not save_mgr.spend_cash(SPIN_COST):
			update_button_state()
			return
			
	is_spinning = true
	spin_button.disabled = true
	result_label.text = "SPINNING FOR COMBAT SUPPLY..."
	result_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	
	# Select winning slice using weights
	var total_weight = 0
	for s in SLICES:
		total_weight += s.weight
	var r = randi() % total_weight
	var win_idx = 0
	var accum = 0
	for i in range(SLICES.size()):
		accum += SLICES[i].weight
		if r < accum:
			win_idx = i
			break
			
	_start_wheel_animation(win_idx, is_free)

func _start_wheel_animation(win_idx: int, is_free: bool):
	var slice_deg = 360.0 / float(SLICES.size()) # 45 degrees
	# In our drawing, slice 0 is at [0, 45] deg. Top needle is at 270 deg (-90 deg from right).
	# To make slice win_idx land under the top needle (270 deg):
	# (wheel_rotation + slice_center) % 360 = 270
	var slice_center = (win_idx * slice_deg) + (slice_deg * 0.5)
	var target_deg = 270.0 - slice_center
	# Add 6 to 9 full rotations for anticipation
	var full_spins = randi_range(6, 9) * 360.0
	var final_rotation = current_angle + full_spins + (target_deg - fmod(current_angle, 360.0))
	if final_rotation <= current_angle + full_spins:
		final_rotation += 360.0
		
	# Animate with cubic ease out
	var tw = create_tween()
	tw.tween_method(_animate_rotation, current_angle, final_rotation, 4.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func(): _on_spin_finished(win_idx, is_free))

func _animate_rotation(val: float):
	current_angle = val
	if wheel_node:
		wheel_node.rotation_degrees = val
		
	# Ticking sound when crossing slice threshold
	var cur_slice = int(floor(val / (360.0 / float(SLICES.size()))))
	if cur_slice != last_tick_slice:
		last_tick_slice = cur_slice
		_play_tick_sound()

func _play_tick_sound():
	var s_path = "res://audio/ui/sfx_hitmarker_tick.wav"
	if ResourceLoader.exists(s_path):
		var p = AudioStreamPlayer.new()
		p.stream = load(s_path)
		p.pitch_scale = randf_range(1.15, 1.35)
		p.bus = "SFX"
		add_child(p)
		p.finished.connect(p.queue_free)
		p.play()

func _on_spin_finished(win_idx: int, is_free: bool):
	is_spinning = false
	var won_slice = SLICES[win_idx]
	var cash = won_slice.cash
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.record_spin_reward(cash, is_free)
		
	# Victory fanfare
	var s_path = "res://audio/ui/sfx_victory.wav"
	if ResourceLoader.exists(s_path):
		var p = AudioStreamPlayer.new()
		p.stream = load(s_path)
		p.bus = "SFX"
		add_child(p)
		p.finished.connect(p.queue_free)
		p.play()
		
	result_label.text = "★ CONGRATULATIONS! WON %s!" % won_slice.label.replace("\n", " ")
	result_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	
	var tw = create_tween()
	tw.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(result_label, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN)
	
	reward_won.emit(cash)
	update_button_state()

func _on_close_pressed():
	if is_spinning: return
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_ui_click"):
		audio.play_ui_click()
	closed.emit()
	queue_free()

func _on_wheel_draw():
	if not wheel_node: return
	var center = wheel_node.size * 0.5
	var radius = min(center.x, center.y) - 4.0
	var num_slices = SLICES.size()
	var step_rad = TAU / float(num_slices)
	
	# Draw outer rim
	wheel_node.draw_circle(center, radius + 3.0, Color(0.85, 0.65, 0.15, 0.95))
	wheel_node.draw_circle(center, radius + 1.0, Color(0.05, 0.07, 0.1, 1.0))
	
	for i in range(num_slices):
		var start_rad = i * step_rad
		var end_rad = (i + 1) * step_rad
		var s_data = SLICES[i]
		
		# Draw slice arc
		var pts = PackedVector2Array([center])
		var segments = 16
		for s in range(segments + 1):
			var a = start_rad + (end_rad - start_rad) * (float(s) / float(segments))
			pts.append(center + Vector2(cos(a), sin(a)) * radius)
		wheel_node.draw_colored_polygon(pts, s_data.color)
		
		# Divider line
		var div_pt = center + Vector2(cos(start_rad), sin(start_rad)) * radius
		wheel_node.draw_line(center, div_pt, Color(0.85, 0.65, 0.15, 0.8), 2.0, true)
		
		# Slice label
		var mid_rad = (start_rad + end_rad) * 0.5
		var text_pos = center + Vector2(cos(mid_rad), sin(mid_rad)) * (radius * 0.65)
		var text_color = Color(1.0, 0.9, 0.3) if i == 5 else Color(0.9, 0.95, 1.0)
		wheel_node.draw_string(ThemeDB.fallback_font, text_pos + Vector2(-22, 5), s_data.label.split("\n")[0], HORIZONTAL_ALIGNMENT_CENTER, -1, 13, text_color)
		
	# Center metallic hub
	wheel_node.draw_circle(center, radius * 0.22, Color(0.85, 0.65, 0.15, 1.0))
	wheel_node.draw_circle(center, radius * 0.18, Color(0.08, 0.1, 0.14, 1.0))
	wheel_node.draw_circle(center, radius * 0.08, Color(0.85, 0.65, 0.15, 1.0))
