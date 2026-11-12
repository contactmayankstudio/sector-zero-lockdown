class_name MissionMap
extends Control

signal mission_selected(data: MissionData, idx: int)

@export var node_scene: PackedScene = preload("res://scenes/UI/Components/MissionNode.tscn")

@onready var map_canvas = $MapCanvas
@onready var route_layer = $MapCanvas/RouteLayer
@onready var node_container = $MapCanvas/NodeContainer
@onready var info_panel = $MissionInfoPanel

const MissionNodeClass = preload("res://scripts/UI/Components/MissionNode.gd")

var mission_nodes: Array = []
var selected_node = null
var current_chapter: Dictionary = {}

# Drag & Pan state
var is_dragging: bool = false
var drag_start_mouse: Vector2 = Vector2.ZERO
var drag_start_cam: Vector2 = Vector2.ZERO
var current_zoom: float = 1.0
const MIN_ZOOM: float = 0.75
const MAX_ZOOM: float = 1.35

const MAP_WIDTH: float = 1500.0
const MAP_HEIGHT: float = 750.0

# Dynamic 7-Node Chapter Progression Layout
const CHAPTER_NODE_POSITIONS = {
	1: Vector2(160, 310), # Sub-mission 1: Patrol / First Breach
	2: Vector2(320, 200), # Sub-mission 2: Wave Survival
	3: Vector2(490, 160), # Sub-mission 3: Timed Outbreak / Rush
	4: Vector2(660, 260), # Sub-mission 4: Heavy / Runner Hunt
	5: Vector2(830, 380), # Sub-mission 5: Supply Cache Defense
	6: Vector2(1000, 280), # Sub-mission 6: Quarantine Cleansing
	7: Vector2(1180, 190), # Sub-mission 7: Capstone Apex Boss (larger, red highlight)
	8: Vector2(1350, 330)  # Sub-mission 8: Special Outpost (Endless Mode on Chapter 12)
}

const CHAPTER_ROUTE_CONNECTIONS = [
	[1, 2],
	[2, 3],
	[3, 4],
	[4, 5],
	[5, 6],
	[6, 7],
	[7, 8] # Chapter 12 only
]

# Legacy 13-node positions for backward compatibility
const NODE_POSITIONS = {
	1: Vector2(160, 200),   # M1: Airport Terminal
	2: Vector2(300, 160),   # M2: Airport Service Road
	3: Vector2(440, 290),   # M3: Railway Station
	4: Vector2(580, 210),   # M4: Dark Industrial North
	5: Vector2(740, 150),   # M5: Power Grid Defense
	6: Vector2(540, 450),   # M6: Apartment Complex
	7: Vector2(700, 480),   # M7: Apartment Towers
	8: Vector2(880, 430),   # M8: Night City Street
	9: Vector2(920, 220),   # M9: Terminal Lockdown
	10: Vector2(1040, 320), # M10: Chemical Plant Purge
	11: Vector2(1100, 480), # M11: Subway Station Holdout
	12: Vector2(1240, 260), # M12: Final Stand Ground Zero
	13: Vector2(360, 490)   # Endless Outpost
}

const ROUTE_CONNECTIONS = [
	[1, 2], [2, 3], [3, 4], [4, 5], [3, 6], [6, 7], [7, 8],
	[5, 9], [8, 10], [9, 10], [10, 11], [10, 12], [11, 12], [3, 13]
]

const ZONE_AREAS = [
	{"name": "SECTOR ALPHA // AIRPORT COMPLEX", "rect": Rect2(100, 90, 280, 200)},
	{"name": "SECTOR BRAVO // RAILWAY JUNCTION", "rect": Rect2(380, 220, 160, 180)},
	{"name": "SECTOR CHARLIE // INDUSTRIAL GRID", "rect": Rect2(550, 90, 300, 210)},
	{"name": "SECTOR DELTA // URBAN RESIDENTIAL", "rect": Rect2(480, 370, 460, 220)},
	{"name": "SECTOR ECHO // CHEMICAL REFINERY", "rect": Rect2(870, 150, 240, 240)},
	{"name": "SECTOR OMEGA // GROUND ZERO (BOSS)", "rect": Rect2(1150, 170, 180, 220)},
	{"name": "SECTOR PERIMETER // OUTPOST SURVIVAL", "rect": Rect2(280, 430, 180, 160)}
]

func _ready():
	if route_layer:
		route_layer.draw.connect(_on_route_layer_draw)
	if info_panel:
		info_panel.deploy_requested.connect(_on_deploy_requested)
		info_panel.armory_requested.connect(_on_armory_requested)
		info_panel.panel_closed.connect(_on_panel_closed)
		info_panel.visible = false
	
	call_deferred("_center_on_initial_mission")

func setup_chapter(chapter_dict: Dictionary):
	current_chapter = chapter_dict
	var missions: Array = chapter_dict.get("missions", [])
	
	for c in node_container.get_children():
		c.queue_free()
	mission_nodes.clear()
	
	var c_num = chapter_dict.get("num", 1)
	
	for idx in range(1, missions.size() + 1):
		var mission_path = missions[idx - 1]
		var data = load(mission_path) as MissionData
		if not data:
			continue
			
		var pos = CHAPTER_NODE_POSITIONS.get(idx, Vector2(120 + idx * 150, 260))
		var node = node_scene.instantiate() as MissionNode
		node_container.add_child(node)
		node.setup(data, idx, pos)
		
		# Boss styling for Capstone sub-mission 7
		if idx == 7 or data.objective_type == MissionData.ObjectiveType.BOSS_KILL:
			node.is_boss = true
			node._apply_visuals()
			
		node.node_selected.connect(_on_node_selected)
		mission_nodes.append(node)
		
	if route_layer:
		route_layer.queue_redraw()
		
	call_deferred("_center_on_initial_mission")

func setup_map(missions: Array):
	current_chapter = {}
	for c in node_container.get_children():
		c.queue_free()
	mission_nodes.clear()
	
	var is_chapter_scale = (missions.size() <= 8)
	
	for idx in range(1, missions.size() + 1):
		var mission_path = missions[idx - 1]
		var data = load(mission_path) as MissionData
		if not data:
			continue
			
		var pos = CHAPTER_NODE_POSITIONS.get(idx, Vector2(100 + idx * 140, 260)) if is_chapter_scale else NODE_POSITIONS.get(idx, Vector2(100 + idx * 80, 300))
		var node = node_scene.instantiate() as MissionNode
		node_container.add_child(node)
		node.setup(data, idx, pos)
		if is_chapter_scale and idx == 7:
			node.is_boss = true
			node._apply_visuals()
		node.node_selected.connect(_on_node_selected)
		mission_nodes.append(node)
		
	if route_layer:
		route_layer.queue_redraw()

func _on_node_selected(node, data: MissionData):
	if selected_node and selected_node != node:
		selected_node.set_selected(false)
		
	selected_node = node
	node.set_selected(true)
	
	if info_panel:
		info_panel.show_mission(data, node.mission_index)
		_pan_to_node(node)
		
	mission_selected.emit(data, node.mission_index)

func _pan_to_node(node):
	var target_x = -node.position.x * current_zoom + 320
	var target_y = -node.position.y * current_zoom + 340
	_clamp_and_tween_canvas(Vector2(target_x, target_y))

func _center_on_initial_mission():
	var target_node = null
	for n in mission_nodes:
		if n.is_unlocked and not n.is_completed:
			target_node = n
			break
	if not target_node and not mission_nodes.is_empty():
		target_node = mission_nodes[0]
		
	if target_node:
		_on_node_selected(target_node, target_node.mission_data)

func _on_deploy_requested(data: MissionData):
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		mission_mgr.start_mission(data)
	elif data.scene_path != "":
		get_tree().change_scene_to_file(data.scene_path)

func _on_armory_requested():
	get_tree().change_scene_to_file("res://scenes/UI/ArmoryUI.tscn")

func _on_panel_closed():
	if selected_node:
		selected_node.set_selected(false)
		selected_node = null

func _on_route_layer_draw():
	if not route_layer: return
	
	var save_mgr = get_node_or_null("/root/SaveManager")
	
	if not current_chapter.is_empty():
		# 1. Draw Chapter Operations Zone
		var c_num = current_chapter.get("num", 1)
		var c_name = current_chapter.get("name", "SECTOR ZONE")
		var c_loc = current_chapter.get("location", "Perimeter")
		
		var zone_rect = Rect2(100, 90, 1300, 360)
		route_layer.draw_rect(zone_rect, Color(0.04, 0.08, 0.12, 0.45), true)
		route_layer.draw_rect(zone_rect, Color(0.12, 0.28, 0.42, 0.35), false, 1.5)
		
		# Corner brackets
		var cl = 16.0
		var c_col = Color(0.0, 0.75, 1.0, 0.5)
		route_layer.draw_line(zone_rect.position, zone_rect.position + Vector2(cl, 0), c_col, 2.0)
		route_layer.draw_line(zone_rect.position, zone_rect.position + Vector2(0, cl), c_col, 2.0)
		route_layer.draw_line(zone_rect.end, zone_rect.end - Vector2(cl, 0), c_col, 2.0)
		route_layer.draw_line(zone_rect.end, zone_rect.end - Vector2(0, cl), c_col, 2.0)
		
		# Header text
		var header = "CHAPTER %02d: %s" % [c_num, c_name]
		route_layer.draw_string(ThemeDB.fallback_font, zone_rect.position + Vector2(16, 22), header, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.35, 0.85, 1.0, 0.95))
		route_layer.draw_string(ThemeDB.fallback_font, zone_rect.position + Vector2(16, 40), "📍 AREA: %s" % c_loc, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.75, 0.85, 0.95, 0.75))
		
		# Draw routes between chapter nodes
		for conn in CHAPTER_ROUTE_CONNECTIONS:
			var n1_idx = conn[0]
			var n2_idx = conn[1]
			if n1_idx > mission_nodes.size() or n2_idx > mission_nodes.size():
				continue
			if not CHAPTER_NODE_POSITIONS.has(n1_idx) or not CHAPTER_NODE_POSITIONS.has(n2_idx):
				continue
				
			var node1 = mission_nodes[n1_idx - 1]
			var node2 = mission_nodes[n2_idx - 1]
			
			var p1 = CHAPTER_NODE_POSITIONS[n1_idx] + Vector2(31, 31)
			var p2 = CHAPTER_NODE_POSITIONS[n2_idx] + Vector2(31, 31)
			
			var n1_cleared = node1.is_completed
			var n2_cleared = node2.is_completed
			
			if n1_cleared and n2_cleared:
				route_layer.draw_line(p1, p2, Color(0.1, 0.85, 0.45, 0.85), 3.0, true)
			elif n1_cleared:
				route_layer.draw_line(p1, p2, Color(0.0, 0.75, 1.0, 0.8), 2.5, true)
				var mid = (p1 + p2) * 0.5
				route_layer.draw_circle(mid, 3.5, Color(0.0, 0.85, 1.0, 0.9))
			else:
				_draw_dashed_line(p1, p2, Color(0.2, 0.28, 0.35, 0.4), 1.5, 8.0, 6.0)
		return
		
	# Legacy Sector Zone boundaries & routes
	for zone in ZONE_AREAS:
		var rect: Rect2 = zone["rect"]
		route_layer.draw_rect(rect, Color(0.04, 0.08, 0.12, 0.45), true)
		route_layer.draw_rect(rect, Color(0.12, 0.28, 0.42, 0.35), false, 1.5)
		var cl = 12.0
		var c_col = Color(0.0, 0.75, 1.0, 0.45)
		route_layer.draw_line(rect.position, rect.position + Vector2(cl, 0), c_col, 2.0)
		route_layer.draw_line(rect.position, rect.position + Vector2(0, cl), c_col, 2.0)
		route_layer.draw_line(rect.end, rect.end - Vector2(cl, 0), c_col, 2.0)
		route_layer.draw_line(rect.end, rect.end - Vector2(0, cl), c_col, 2.0)
		route_layer.draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, 16), zone["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.35, 0.65, 0.85, 0.7))

	for conn in ROUTE_CONNECTIONS:
		var n1_idx = conn[0]
		var n2_idx = conn[1]
		if not NODE_POSITIONS.has(n1_idx) or not NODE_POSITIONS.has(n2_idx):
			continue
		
		var p1 = NODE_POSITIONS[n1_idx] + Vector2(31, 31)
		var p2 = NODE_POSITIONS[n2_idx] + Vector2(31, 31)
		
		var n1_mid = "mission_%02d" % n1_idx if n1_idx <= 12 else "mission_endless"
		var n2_mid = "mission_%02d" % n2_idx if n2_idx <= 12 else "mission_endless"
		
		var n1_cleared = save_mgr.is_mission_completed(n1_mid) if save_mgr else false
		var n2_cleared = save_mgr.is_mission_completed(n2_mid) if save_mgr else false
		
		if n1_cleared and n2_cleared:
			route_layer.draw_line(p1, p2, Color(0.1, 0.85, 0.45, 0.85), 3.0, true)
		elif n1_cleared:
			route_layer.draw_line(p1, p2, Color(0.0, 0.75, 1.0, 0.8), 2.5, true)
			var mid = (p1 + p2) * 0.5
			route_layer.draw_circle(mid, 3.5, Color(0.0, 0.85, 1.0, 0.9))
		else:
			_draw_dashed_line(p1, p2, Color(0.2, 0.28, 0.35, 0.4), 1.5, 8.0, 6.0)

func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float, dash_len: float, gap_len: float):
	var dir = (to - from).normalized()
	var total_dist = from.distance_to(to)
	var cur_dist = 0.0
	while cur_dist < total_dist:
		var end_dist = min(cur_dist + dash_len, total_dist)
		route_layer.draw_line(from + dir * cur_dist, from + dir * end_dist, color, width)
		cur_dist += dash_len + gap_len

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_mouse = event.position
				drag_start_cam = map_canvas.position
			else:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_mouse
		_clamp_and_set_position(drag_start_cam + delta)
	elif event is InputEventScreenDrag:
		_clamp_and_set_position(map_canvas.position + event.relative)

func zoom_in():
	_set_zoom(min(current_zoom + 0.15, MAX_ZOOM))

func zoom_out():
	_set_zoom(max(current_zoom - 0.15, MIN_ZOOM))

func _set_zoom(new_zoom: float):
	current_zoom = new_zoom
	var tw = create_tween().set_parallel(true)
	tw.tween_property(map_canvas, "scale", Vector2(current_zoom, current_zoom), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_clamp_and_tween_canvas(map_canvas.position)

func _clamp_and_set_position(pos: Vector2):
	var min_x = -MAP_WIDTH * current_zoom + size.x * 0.5
	var max_x = size.x * 0.5
	var min_y = -MAP_HEIGHT * current_zoom + size.y * 0.5
	var max_y = size.y * 0.5
	map_canvas.position = Vector2(clamp(pos.x, min_x, max_x), clamp(pos.y, min_y, max_y))

func _clamp_and_tween_canvas(target_pos: Vector2):
	var min_x = -MAP_WIDTH * current_zoom + size.x * 0.5
	var max_x = size.x * 0.5
	var min_y = -MAP_HEIGHT * current_zoom + size.y * 0.5
	var max_y = size.y * 0.5
	var cl_pos = Vector2(clamp(target_pos.x, min_x, max_x), clamp(target_pos.y, min_y, max_y))
	var tw = create_tween()
	tw.tween_property(map_canvas, "position", cl_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
