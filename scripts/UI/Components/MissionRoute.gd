class_name MissionRoute
extends Line2D

@export var route_color_cleared: Color = Color(0.1, 0.85, 0.45, 0.85)
@export var route_color_active: Color = Color(0.0, 0.75, 1.0, 0.8)
@export var route_color_locked: Color = Color(0.2, 0.28, 0.35, 0.4)

func set_route_state(is_cleared: bool, is_active: bool):
	if is_cleared:
		default_color = route_color_cleared
		width = 3.0
	elif is_active:
		default_color = route_color_active
		width = 2.5
	else:
		default_color = route_color_locked
		width = 1.5
