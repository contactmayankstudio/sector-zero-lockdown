class_name MissionNode
extends Control

signal node_selected(node: MissionNode, data: MissionData)

@export var pulse_speed: float = 2.4

@onready var button = $Button
@onready var num_label = $Button/NumLabel
@onready var status_icon = $Button/StatusIcon
@onready var selection_ring = $SelectionRing
@onready var title_tag = $TitleTag
@onready var stars_container = $StarsContainer

var mission_data: MissionData = null
var mission_index: int = 1
var is_unlocked: bool = false
var is_completed: bool = false
var is_boss: bool = false
var is_selected: bool = false
var earned_stars: int = 0

var base_pos: Vector2 = Vector2.ZERO
var pulse_time: float = 0.0

func _ready():
	pivot_offset = size / 2.0
	if button:
		button.pressed.connect(_on_pressed)
	if selection_ring:
		selection_ring.visible = false

func setup(data: MissionData, idx: int, pos: Vector2):
	mission_data = data
	mission_index = idx
	position = pos
	base_pos = pos
	
	is_boss = (data.objective_type == MissionData.ObjectiveType.BOSS_KILL or idx == 12 or idx == 6)
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		is_completed = save_mgr.is_mission_completed(data.mission_id)
		earned_stars = save_mgr.get_mission_stars(data.mission_id) if save_mgr.has_method("get_mission_stars") else 0
		if data.unlock_requirement_id != "":
			is_unlocked = save_mgr.is_mission_completed(data.unlock_requirement_id)
		else:
			is_unlocked = true
	else:
		is_unlocked = true
		is_completed = false
		
	_apply_visuals()

func _apply_visuals():
	if not button: return
	
	if "is_endless" in mission_data and mission_data.is_endless:
		num_label.text = "∞"
		title_tag.text = "OUTPOST"
	else:
		num_label.text = "%02d" % mission_index
		title_tag.text = mission_data.display_name.to_upper()
		
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_right = 28
	style.corner_radius_bottom_left = 28
	style.shadow_size = 8
	
	if is_boss:
		custom_minimum_size = Vector2(76, 76)
		size = Vector2(76, 76)
		pivot_offset = size / 2.0
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		
		if is_completed:
			style.bg_color = Color(0.08, 0.22, 0.16, 0.95)
			style.border_color = Color(0.2, 0.95, 0.5, 1.0)
			status_icon.text = "✓"
			status_icon.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		elif is_unlocked:
			style.bg_color = Color(0.35, 0.08, 0.08, 0.95)
			style.border_color = Color(1.0, 0.25, 0.25, 1.0)
			status_icon.text = "⚠"
			status_icon.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		else:
			style.bg_color = Color(0.12, 0.12, 0.14, 0.9)
			style.border_color = Color(0.4, 0.25, 0.25, 0.7)
			status_icon.text = "🔒"
			status_icon.add_theme_color_override("font_color", Color(0.6, 0.5, 0.5))
	else:
		custom_minimum_size = Vector2(62, 62)
		size = Vector2(62, 62)
		pivot_offset = size / 2.0
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		
		if is_completed:
			style.bg_color = Color(0.06, 0.18, 0.14, 0.95)
			style.border_color = Color(0.2, 0.85, 0.5, 0.95)
			style.shadow_color = Color(0.1, 0.6, 0.3, 0.4)
			status_icon.text = "✓"
			status_icon.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		elif is_unlocked:
			style.bg_color = Color(0.08, 0.16, 0.25, 0.95)
			style.border_color = Color(0.0, 0.75, 1.0, 1.0)
			style.shadow_color = Color(0.0, 0.5, 0.9, 0.4)
			status_icon.text = ""
		else:
			style.bg_color = Color(0.07, 0.08, 0.1, 0.88)
			style.border_color = Color(0.25, 0.3, 0.35, 0.6)
			style.shadow_color = Color(0, 0, 0, 0.3)
			status_icon.text = "🔒"
			status_icon.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
			
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_stylebox_override("disabled", style)
	button.disabled = false # Tapping locked nodes allows viewing mission requirements in info panel!
	
	# Update stars row
	if stars_container:
		if is_completed and earned_stars > 0:
			stars_container.visible = true
			var s_text = ""
			for i in range(3):
				s_text += "★" if i < earned_stars else "☆"
			var s_lbl = stars_container.get_node_or_null("StarsLabel")
			if s_lbl:
				s_lbl.text = s_text
		else:
			stars_container.visible = false

func _process(delta):
	# Gentle pulsing for active/unlocked nodes that haven't been completed yet
	if is_unlocked and not is_completed:
		pulse_time += delta * pulse_speed
		var p = (sin(pulse_time) + 1.0) * 0.5
		var glow_scale = lerp(1.0, 1.08, p)
		scale = Vector2(glow_scale, glow_scale)
	elif is_selected:
		scale = Vector2(1.1, 1.1)

func set_selected(selected: bool):
	is_selected = selected
	if selection_ring:
		selection_ring.visible = selected
		if selected:
			var tw = create_tween().set_loops()
			selection_ring.rotation = 0.0
			tw.tween_property(selection_ring, "rotation", TAU, 4.0)

func _on_pressed():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	node_selected.emit(self, mission_data)
