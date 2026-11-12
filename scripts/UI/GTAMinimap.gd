class_name GTAMinimap
extends Control

## GTA 5 & PUBG Style Circular GPS Radar Minimap
## Ultra-lightweight 2D immediate-mode rendering (Zero 3D render-target overhead).
## Optimized for low-end AMD Kabini APU with gl_compatibility renderer.

@export var radar_radius: float = 64.0
@export var max_world_range: float = 100.0 # meters around player
@export var smooth_rotation: bool = true

var player: Node3D = null
var camera: Camera3D = null

# Colors
const COLOR_BG = Color(0.06, 0.08, 0.12, 0.78)
const COLOR_RIM = Color(0.22, 0.75, 1.0, 0.70)
const COLOR_RING_INNER = Color(0.35, 0.55, 0.75, 0.25)
const COLOR_CROSS = Color(0.35, 0.55, 0.75, 0.20)
const COLOR_NORTH = Color(1.0, 0.40, 0.25, 0.95)
const COLOR_PLAYER = Color(1.0, 0.92, 0.40, 1.0)
const COLOR_ENEMY = Color(1.0, 0.25, 0.25, 0.95)
const COLOR_BIKE = Color(0.25, 0.88, 1.0, 0.95)
const COLOR_CAR = Color(1.0, 0.75, 0.25, 0.95)
const COLOR_AIRDROP = Color(1.0, 0.85, 0.15, 1.0)

var _pulse_timer: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(radar_radius * 2.0 + 12.0, radar_radius * 2.0 + 12.0)
	mouse_filter = MOUSE_FILTER_IGNORE
	call_deferred("_find_player_and_camera")

func _find_player_and_camera() -> void:
	if not is_inside_tree():
		return
	var tree = get_tree()
	if tree:
		player = tree.get_first_node_in_group("player") as Node3D
		camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	if not visible:
		return
	_pulse_timer += delta * 4.0
	
	if not player or not is_instance_valid(player):
		_find_player_and_camera()
	else:
		camera = get_viewport().get_camera_3d()
	
	queue_redraw()

func _draw() -> void:
	var center = size * 0.5
	var r = radar_radius
	
	# 1. Dark Glass Radar Background
	draw_circle(center, r, COLOR_BG)
	
	# 2. Concentric Distance Grid Rings
	draw_arc(center, r * 0.33, 0.0, TAU, 24, COLOR_RING_INNER, 1.0)
	draw_arc(center, r * 0.66, 0.0, TAU, 32, COLOR_RING_INNER, 1.0)
	draw_arc(center, r, 0.0, TAU, 48, COLOR_RIM, 2.0)
	
	# 3. Crosshair Axes
	draw_line(center - Vector2(r, 0), center + Vector2(r, 0), COLOR_CROSS, 1.0)
	draw_line(center - Vector2(0, r), center + Vector2(0, r), COLOR_CROSS, 1.0)
	
	if not player or not is_instance_valid(player):
		return
		
	# Determine current yaw angle (Camera or Player)
	var cam_yaw = 0.0
	if camera and is_instance_valid(camera):
		cam_yaw = camera.global_rotation.y
	else:
		cam_yaw = player.global_rotation.y
		
	var player_pos = player.global_position
	
	# 4. North Indicator 'N' on outer rim
	# World North is -Z (angle 0 corresponds to -Z in our projection)
	# When camera rotates by cam_yaw, North appears at -cam_yaw
	var north_angle = -cam_yaw - PI * 0.5
	var north_pos = center + Vector2(cos(north_angle), sin(north_angle)) * (r - 9.0)
	draw_string(ThemeDB.fallback_font, north_pos + Vector2(-4.0, 4.0), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, COLOR_NORTH)
	
	# 5. Draw Enemies (Zombies)
	var tree = get_tree()
	if tree:
		var enemies = tree.get_nodes_in_group("enemies")
		for e in enemies:
			if is_instance_valid(e) and e is Node3D:
				var e_pos = e.global_position
				var dx = e_pos.x - player_pos.x
				var dz = e_pos.z - player_pos.z
				
				# Rotate delta relative to camera heading so Forward is UP (-Y on 2D)
				var d2 = Vector2(dx, dz).rotated(cam_yaw)
				# In 2D: X is right, Y is down. In 3D: X is right, Z is back (+Z is down)
				var radar_vec = Vector2(d2.x, d2.y) * (r / max_world_range)
				
				var is_clamped = false
				if radar_vec.length() > r - 5.0:
					radar_vec = radar_vec.normalized() * (r - 5.0)
					is_clamped = true
					
				var blip_pos = center + radar_vec
				var blip_rad = 3.5 if not is_clamped else 2.5
				var col = COLOR_ENEMY
				if not is_clamped and radar_vec.length() < r * 0.25:
					# Close range danger pulse!
					blip_rad += sin(_pulse_timer) * 0.8
					col = Color(1.0, 0.45, 0.45)
					
				draw_circle(blip_pos, blip_rad, col)

		# 6. Draw Vehicles (Hayabusa Bike & Sedan Car)
		var bikes = tree.get_nodes_in_group("bikes")
		for b in bikes:
			if is_instance_valid(b) and b is Node3D and b != player.get_parent():
				var b_pos = b.global_position
				var d2 = Vector2(b_pos.x - player_pos.x, b_pos.z - player_pos.z).rotated(cam_yaw)
				var radar_vec = Vector2(d2.x, d2.y) * (r / max_world_range)
				if radar_vec.length() > r - 6.0:
					radar_vec = radar_vec.normalized() * (r - 6.0)
				var pos = center + radar_vec
				draw_circle(pos, 4.0, COLOR_BIKE)
				draw_string(ThemeDB.fallback_font, pos + Vector2(-3.0, 3.5), "B", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color.WHITE)

		var cars = tree.get_nodes_in_group("drivable_cars")
		for c in cars:
			if is_instance_valid(c) and c is Node3D:
				var c_pos = c.global_position
				var d2 = Vector2(c_pos.x - player_pos.x, c_pos.z - player_pos.z).rotated(cam_yaw)
				var radar_vec = Vector2(d2.x, d2.y) * (r / max_world_range)
				if radar_vec.length() > r - 6.0:
					radar_vec = radar_vec.normalized() * (r - 6.0)
				var pos = center + radar_vec
				draw_circle(pos, 4.0, COLOR_CAR)
				draw_string(ThemeDB.fallback_font, pos + Vector2(-3.0, 3.5), "C", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color.BLACK)

		# 7. Draw Airdrop Crates
		var airdrops = tree.get_nodes_in_group("airdrops")
		for ad in airdrops:
			if is_instance_valid(ad) and ad is Node3D:
				var ad_pos = ad.global_position
				var d2 = Vector2(ad_pos.x - player_pos.x, ad_pos.z - player_pos.z).rotated(cam_yaw)
				var radar_vec = Vector2(d2.x, d2.y) * (r / max_world_range)
				if radar_vec.length() > r - 6.0:
					radar_vec = radar_vec.normalized() * (r - 6.0)
				var pos = center + radar_vec
				# Pulsing star crate
				var a_size = 5.0 + sin(_pulse_timer * 1.5) * 1.5
				draw_rect(Rect2(pos - Vector2(a_size * 0.5, a_size * 0.5), Vector2(a_size, a_size)), COLOR_AIRDROP)
				draw_rect(Rect2(pos - Vector2(a_size * 0.5, a_size * 0.5), Vector2(a_size, a_size)), Color.RED, false, 1.0)

	# 8. Center Player Chevron / Arrow (Pointing UP)
	var arrow_pts = PackedVector2Array([
		center + Vector2(0.0, -8.0),   # Tip (Forward)
		center + Vector2(-6.0, 6.0),   # Bottom Left
		center + Vector2(0.0, 3.0),    # Center Indent
		center + Vector2(6.0, 6.0)     # Bottom Right
	])
	draw_colored_polygon(arrow_pts, COLOR_PLAYER)
	draw_polyline(arrow_pts, Color(0.1, 0.1, 0.1, 0.8), 1.2)
