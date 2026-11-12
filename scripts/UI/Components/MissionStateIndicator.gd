class_name MissionStateIndicator
extends PanelContainer

enum State {
	LOCKED,
	UNLOCKED,
	COMPLETED,
	BOSS
}

@onready var icon_label = $Margin/HBox/IconLabel
@onready var status_label = $Margin/HBox/StatusLabel
@onready var stars_label = $Margin/HBox/StarsLabel

var current_state: State = State.LOCKED

func set_state(state: State, stars: int = 0, req_text: String = ""):
	current_state = state
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if not style:
		style = StyleBoxFlat.new()
		style.corner_radius_top_left = 3
		style.corner_radius_top_right = 3
		style.corner_radius_bottom_right = 3
		style.corner_radius_bottom_left = 3
		
	match state:
		State.COMPLETED:
			style.bg_color = Color(0.04, 0.18, 0.12, 0.9)
			style.border_color = Color(0.2, 0.9, 0.45, 0.9)
			icon_label.text = "✓"
			icon_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
			status_label.text = "CLEARED"
			status_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.8))
			stars_label.visible = true
			var s_text = ""
			for i in range(3):
				s_text += "★" if i < stars else "☆"
			stars_label.text = s_text
			stars_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
			
		State.UNLOCKED:
			style.bg_color = Color(0.08, 0.14, 0.22, 0.9)
			style.border_color = Color(0.0, 0.75, 1.0, 0.9)
			icon_label.text = "●"
			icon_label.add_theme_color_override("font_color", Color(0.0, 0.85, 1.0))
			status_label.text = "READY"
			status_label.add_theme_color_override("font_color", Color(0.8, 0.95, 1.0))
			stars_label.visible = false
			
		State.LOCKED:
			style.bg_color = Color(0.08, 0.09, 0.11, 0.85)
			style.border_color = Color(0.35, 0.38, 0.42, 0.6)
			icon_label.text = "⚿"
			icon_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
			status_label.text = ("REQ: " + req_text) if req_text != "" else "LOCKED"
			status_label.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
			stars_label.visible = false
			
		State.BOSS:
			style.bg_color = Color(0.22, 0.05, 0.05, 0.92)
			style.border_color = Color(1.0, 0.25, 0.25, 0.95)
			icon_label.text = "⚠"
			icon_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
			status_label.text = "BOSS TARGET"
			status_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.6))
			stars_label.visible = false

	add_theme_stylebox_override("panel", style)
