# RoadGenerator.gd
# AGENT 3: REALISTIC ROAD GENERATION & HIGHWAY INFRASTRUCTURE
# Builds multi-lane asphalt highways, authentic road markings (yellow center, dashed lanes, crosswalks),
# dark concrete curbs, sidewalk park benches, utility poles, parking bays, and traffic props.
class_name RoadGenerator
extends RefCounted

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")
const WorldMaterialManager = preload("res://scripts/World/WorldMaterialManager.gd")

const ROAD_WIDTH: float = 14.0 # 4-lane highway / city avenue
const SIDEWALK_WIDTH: float = 3.6
const CURB_WIDTH: float = 0.28
const CURB_HEIGHT: float = 0.22

static var barrier_prefab: PackedScene = null
static var cone_prefab: PackedScene = null
static var sign_prefab: PackedScene = null
static var parked_car_prefab: PackedScene = null

static func _init_props():
	if barrier_prefab == null:
		barrier_prefab = load("res://scenes/environments/props/ConcreteBarrierA.scn")
		cone_prefab = load("res://scenes/environments/props/TrafficCone.scn")
		sign_prefab = load("res://scenes/environments/props/RoadSignWorks.scn")
		parked_car_prefab = load("res://assets/3d/vehicles/sedan.glb")

static func build_chunk_roads(chunk_node: Node3D, coord: Vector2i, region_type: int):
	_init_props()
	var size = OpenWorldConfig.CHUNK_SIZE
	
	# East-West Highway runs at local z = 64.0 when coord.y == 0
	var has_ew_road = (coord.y == 0)
	# North-South Avenue runs at local x = 64.0 when coord.x == 0
	var has_ns_road = (coord.x == 0)
	
	if has_ew_road:
		_build_road_segment(chunk_node, Vector3(0.0, 0.080, 64.0), Vector3(size, 0.080, 64.0), true, region_type)
		_build_road_markings(chunk_node, Vector3(0.0, 0.090, 64.0), Vector3(size, 0.090, 64.0), true, coord.x == 0)
		_build_curbs(chunk_node, Vector3(size * 0.5, 0.080, 64.0), size, true, coord.x == 0)
		_build_sidewalks(chunk_node, Vector3(size * 0.5, 0.080, 64.0), size, true, coord.x == 0)
		_build_streetlights(chunk_node, 64.0, size, true)
		_build_sidewalk_benches(chunk_node, Vector3(size * 0.5, 0.080, 64.0), size, true, coord.x == 0)
		if coord.x == 0:
			_build_parking_bays(chunk_node, 64.0, true)
		else:
			_build_electricity_poles(chunk_node, 64.0, size, true)
		
	if has_ns_road:
		_build_road_segment(chunk_node, Vector3(64.0, 0.082, 0.0), Vector3(64.0, 0.082, size), false, region_type)
		_build_road_markings(chunk_node, Vector3(64.0, 0.092, 0.0), Vector3(64.0, 0.092, size), false, coord.y == 0)
		_build_curbs(chunk_node, Vector3(64.0, 0.082, size * 0.5), size, false, coord.y == 0)
		_build_sidewalks(chunk_node, Vector3(64.0, 0.082, size * 0.5), size, false, coord.y == 0)
		_build_streetlights(chunk_node, 64.0, size, false)
		_build_sidewalk_benches(chunk_node, Vector3(64.0, 0.082, size * 0.5), size, false, coord.y == 0)
		if coord.y == 0:
			_build_parking_bays(chunk_node, 64.0, false)
		else:
			_build_electricity_poles(chunk_node, 64.0, size, false)
		
	# Place Highway props in suburban and highway chunks
	if has_ew_road and coord.x != 0:
		_build_highway_barriers(chunk_node, 64.0, size, true)
		_place_highway_props(chunk_node)
		
	if has_ns_road and coord.y != 0:
		_build_highway_barriers(chunk_node, 64.0, size, false)

static func _build_road_segment(chunk_node: Node3D, start_pos: Vector3, end_pos: Vector3, is_horizontal: bool, _region_type: int):
	var length = (end_pos - start_pos).length()
	var mid_point = (start_pos + end_pos) * 0.5
	
	var road_mesh = BoxMesh.new()
	if is_horizontal:
		road_mesh.size = Vector3(length, 0.3, ROAD_WIDTH)
	else:
		road_mesh.size = Vector3(ROAD_WIDTH, 0.3, length)
		
	var road_inst = MeshInstance3D.new()
	road_inst.mesh = road_mesh
	road_inst.material_override = WorldMaterialManager.get_road_material()
	road_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	road_inst.position = mid_point - Vector3(0.0, 0.1, 0.0)
	chunk_node.add_child(road_inst)
	
	# Solid Box Collision
	var sb = StaticBody3D.new()
	sb.collision_layer = 1
	var col = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = road_mesh.size
	col.shape = box_shape
	sb.add_child(col)
	road_inst.add_child(sb)

static func _build_curbs(chunk_node: Node3D, center: Vector3, length: float, is_horizontal: bool, has_crossroads: bool = false):
	var curb_mat = WorldMaterialManager.get_curb_material()
	var curb_offset = ROAD_WIDTH * 0.5 + CURB_WIDTH * 0.5
	
	var segments = []
	if has_crossroads:
		var half_gap = 12.0
		var seg_len = (length * 0.5) - half_gap
		segments.append({"center_offset": -(half_gap + seg_len * 0.5), "length": seg_len})
		segments.append({"center_offset": (half_gap + seg_len * 0.5), "length": seg_len})
	else:
		segments.append({"center_offset": 0.0, "length": length})
	
	for side in [-1.0, 1.0]:
		for seg in segments:
			var c_mesh = BoxMesh.new()
			var c_inst = MeshInstance3D.new()
			var s_len = seg["length"]
			var s_off = seg["center_offset"]
			if is_horizontal:
				c_mesh.size = Vector3(s_len, CURB_HEIGHT, CURB_WIDTH)
				c_inst.position = center + Vector3(s_off, CURB_HEIGHT * 0.5 - 0.04, side * curb_offset)
			else:
				c_mesh.size = Vector3(CURB_WIDTH, CURB_HEIGHT, s_len)
				c_inst.position = center + Vector3(side * curb_offset, CURB_HEIGHT * 0.5 - 0.04, s_off)
				
			c_inst.mesh = c_mesh
			c_inst.material_override = curb_mat
			c_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			chunk_node.add_child(c_inst)

static func _build_road_markings(chunk_node: Node3D, start_pos: Vector3, end_pos: Vector3, is_horizontal: bool, has_crossroads: bool):
	var length = (end_pos - start_pos).length()
	var mid_point = (start_pos + end_pos) * 0.5
	var y_line = start_pos.y + 0.01
	
	var mat_yellow = WorldMaterialManager.get_yellow_line_material()
	var mat_white = WorldMaterialManager.get_white_line_material()
	
	var segments = []
	if has_crossroads:
		var half_gap = 11.5
		var seg_len = (length * 0.5) - half_gap
		segments.append({"center_offset": -(half_gap + seg_len * 0.5), "length": seg_len})
		segments.append({"center_offset": (half_gap + seg_len * 0.5), "length": seg_len})
	else:
		segments.append({"center_offset": 0.0, "length": length})
	
	# 1. Double Solid Yellow Center Line (0.14m width, 0.12m gap)
	for offset in [-0.12, 0.12]:
		for seg in segments:
			var y_mesh = BoxMesh.new()
			var y_inst = MeshInstance3D.new()
			y_inst.material_override = mat_yellow
			y_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var s_len = seg["length"]
			var s_off = seg["center_offset"]
			if is_horizontal:
				y_mesh.size = Vector3(s_len, 0.015, 0.14)
				y_inst.position = mid_point + Vector3(s_off, y_line, offset)
			else:
				y_mesh.size = Vector3(0.14, 0.015, s_len)
				y_inst.position = mid_point + Vector3(offset, y_line, s_off)
			y_inst.mesh = y_mesh
			chunk_node.add_child(y_inst)
		
	# 2. White Solid Shoulder Lines at Road Edges (+- 6.6m)
	for side in [-6.6, 6.6]:
		for seg in segments:
			var s_mesh = BoxMesh.new()
			var s_inst = MeshInstance3D.new()
			s_inst.material_override = mat_white
			s_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var s_len = seg["length"]
			var s_off = seg["center_offset"]
			if is_horizontal:
				s_mesh.size = Vector3(s_len, 0.015, 0.18)
				s_inst.position = mid_point + Vector3(s_off, y_line, side)
			else:
				s_mesh.size = Vector3(0.18, 0.015, s_len)
				s_inst.position = mid_point + Vector3(side, y_line, s_off)
			s_inst.mesh = s_mesh
			chunk_node.add_child(s_inst)
		
	# 3. White Dashed Lane Dividers (3.5m from center) - Batched with MultiMesh
	var dash_length = 3.5
	var dash_gap = 3.5
	var period = dash_length + dash_gap
	var num_dashes = int(length / period)
	
	var dash_transforms: Array[Transform3D] = []
	for lane in [-3.5, 3.5]:
		for d in range(num_dashes):
			var d_center = d * period + dash_length * 0.5 - length * 0.5
			# Skip center if crossroads
			if has_crossroads and abs(d_center) < 10.0:
				continue
			var pos = mid_point + Vector3(d_center, y_line, lane) if is_horizontal else mid_point + Vector3(lane, y_line, d_center)
			dash_transforms.append(Transform3D(Basis(), pos))
			
	if not dash_transforms.is_empty():
		var d_mesh = BoxMesh.new()
		d_mesh.size = Vector3(dash_length, 0.015, 0.15) if is_horizontal else Vector3(0.15, 0.015, dash_length)
		var mm_dash = MultiMesh.new()
		mm_dash.transform_format = MultiMesh.TRANSFORM_3D
		mm_dash.mesh = d_mesh
		mm_dash.instance_count = dash_transforms.size()
		for i in range(dash_transforms.size()):
			mm_dash.set_instance_transform(i, dash_transforms[i])
		var mm_dash_inst = MultiMeshInstance3D.new()
		mm_dash_inst.multimesh = mm_dash
		mm_dash_inst.material_override = mat_white
		mm_dash_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		chunk_node.add_child(mm_dash_inst)
			
	# 4. Zebra Crosswalks and Traffic Lights at intersection
	if has_crossroads:
		_build_crosswalk(chunk_node, mid_point, is_horizontal)
		if is_horizontal:
			_build_traffic_lights(chunk_node, mid_point)

static func _build_traffic_lights(chunk_node: Node3D, center: Vector3):
	var corners = [
		Vector3(11.2, 0.0, 11.2),
		Vector3(-11.2, 0.0, 11.2),
		Vector3(11.2, 0.0, -11.2),
		Vector3(-11.2, 0.0, -11.2)
	]
	
	var pole_mat = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.24, 0.25, 0.28)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.4
	
	var box_mat = StandardMaterial3D.new()
	box_mat.albedo_color = Color(0.12, 0.12, 0.12)
	box_mat.roughness = 0.6
	
	var mat_red = StandardMaterial3D.new()
	mat_red.albedo_color = Color(0.95, 0.1, 0.1)
	mat_red.emission_enabled = true
	mat_red.emission = Color(1.0, 0.15, 0.15)
	mat_red.emission_energy_multiplier = 2.8
	
	var mat_green = StandardMaterial3D.new()
	mat_green.albedo_color = Color(0.1, 0.9, 0.25)
	mat_green.emission_enabled = true
	mat_green.emission = Color(0.15, 1.0, 0.3)
	mat_green.emission_energy_multiplier = 2.8
	
	for i in range(corners.size()):
		var c_pos = center + corners[i]
		var root = Node3D.new()
		root.name = "TrafficLight_" + str(i)
		root.position = c_pos
		
		var p_mesh = CylinderMesh.new()
		p_mesh.top_radius = 0.10
		p_mesh.bottom_radius = 0.14
		p_mesh.height = 5.6
		var p_inst = MeshInstance3D.new()
		p_inst.mesh = p_mesh
		p_inst.material_override = pole_mat
		p_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		p_inst.position = Vector3(0, 2.8, 0)
		root.add_child(p_inst)
		
		var arm_mesh = CylinderMesh.new()
		arm_mesh.top_radius = 0.07
		arm_mesh.bottom_radius = 0.07
		arm_mesh.height = 4.2
		var arm_inst = MeshInstance3D.new()
		arm_inst.mesh = arm_mesh
		arm_inst.material_override = pole_mat
		arm_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arm_inst.rotation_degrees = Vector3(0, 0, 90)
		arm_inst.position = Vector3(-1.8 if corners[i].x > 0 else 1.8, 5.2, 0)
		root.add_child(arm_inst)
		
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.45, 1.25, 0.35)
		var box_inst = MeshInstance3D.new()
		box_inst.mesh = box_mesh
		box_inst.material_override = box_mat
		box_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		box_inst.position = arm_inst.position + Vector3(-1.8 if corners[i].x > 0 else 1.8, -0.4, 0.0)
		root.add_child(box_inst)
		
		var lens_mesh = SphereMesh.new()
		lens_mesh.radius = 0.12
		lens_mesh.height = 0.24
		
		var red_lens = MeshInstance3D.new()
		red_lens.mesh = lens_mesh
		red_lens.material_override = mat_red
		red_lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		red_lens.position = box_inst.position + Vector3(0, 0.35, 0.18)
		root.add_child(red_lens)
		
		var green_lens = MeshInstance3D.new()
		green_lens.mesh = lens_mesh
		green_lens.material_override = mat_green
		green_lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		green_lens.position = box_inst.position + Vector3(0, -0.35, 0.18)
		root.add_child(green_lens)
		
		chunk_node.add_child(root)

static func _build_crosswalk(chunk_node: Node3D, center: Vector3, is_horizontal: bool):
	var mat_white = WorldMaterialManager.get_white_line_material()
	var stripe_count = 8
	var stripe_spacing = 0.95
	var cw_dist = 8.5
	
	var cw_transforms: Array[Transform3D] = []
	for cw_sign in [-1.0, 1.0]:
		var base_dist = cw_sign * cw_dist
		for s in range(stripe_count):
			var s_off = (s - stripe_count * 0.5 + 0.5) * stripe_spacing
			var pos = center + Vector3(base_dist, 0.095, s_off) if is_horizontal else center + Vector3(s_off, 0.095, base_dist)
			cw_transforms.append(Transform3D(Basis(), pos))
			
	if not cw_transforms.is_empty():
		var c_mesh = BoxMesh.new()
		c_mesh.size = Vector3(2.5, 0.015, 0.65) if is_horizontal else Vector3(0.65, 0.015, 2.5)
		var mm_cw = MultiMesh.new()
		mm_cw.transform_format = MultiMesh.TRANSFORM_3D
		mm_cw.mesh = c_mesh
		mm_cw.instance_count = cw_transforms.size()
		for i in range(cw_transforms.size()):
			mm_cw.set_instance_transform(i, cw_transforms[i])
		var mm_cw_inst = MultiMeshInstance3D.new()
		mm_cw_inst.multimesh = mm_cw
		mm_cw_inst.material_override = mat_white
		mm_cw_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		chunk_node.add_child(mm_cw_inst)

static func _build_sidewalks(chunk_node: Node3D, center: Vector3, length: float, is_horizontal: bool, has_crossroads: bool = false):
	var sw_mat = WorldMaterialManager.get_sidewalk_material()
	var offset = (ROAD_WIDTH + SIDEWALK_WIDTH) * 0.5 + CURB_WIDTH
	
	var segments = []
	if has_crossroads:
		var half_gap = 12.0
		var seg_len = (length * 0.5) - half_gap
		segments.append({"center_offset": -(half_gap + seg_len * 0.5), "length": seg_len})
		segments.append({"center_offset": (half_gap + seg_len * 0.5), "length": seg_len})
	else:
		segments.append({"center_offset": 0.0, "length": length})
	
	for side in [-1.0, 1.0]:
		for seg in segments:
			var sw_mesh = BoxMesh.new()
			var sw_inst = MeshInstance3D.new()
			var s_len = seg["length"]
			var s_off = seg["center_offset"]
			
			if is_horizontal:
				sw_mesh.size = Vector3(s_len, 0.28, SIDEWALK_WIDTH)
				sw_inst.position = center + Vector3(s_off, 0.04, side * offset)
			else:
				sw_mesh.size = Vector3(SIDEWALK_WIDTH, 0.28, s_len)
				sw_inst.position = center + Vector3(side * offset, 0.04, s_off)
				
			sw_inst.mesh = sw_mesh
			sw_inst.material_override = sw_mat
			sw_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			chunk_node.add_child(sw_inst)
			
			# Collision
			var sb = StaticBody3D.new()
			sb.collision_layer = 1
			var col = CollisionShape3D.new()
			var bshape = BoxShape3D.new()
			bshape.size = sw_mesh.size
			col.shape = bshape
			sb.add_child(col)
			sw_inst.add_child(sb)

static func _build_sidewalk_benches(chunk_node: Node3D, center: Vector3, length: float, is_horizontal: bool, has_crossroads: bool):
	var wood_mat = WorldMaterialManager.get_wood_material()
	var metal_mat = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.18, 0.20, 0.22)
	metal_mat.metallic = 0.8
	metal_mat.roughness = 0.4
	
	var bench_positions = [20.0, 50.0, 80.0, 110.0]
	var side_offset = ROAD_WIDTH * 0.5 + SIDEWALK_WIDTH * 0.7
	
	# Calculate valid bench transforms
	var valid_transforms: Array[Transform3D] = []
	for pos_val in bench_positions:
		if has_crossroads and abs(pos_val - length * 0.5) < 18.0:
			continue # Leave crossroad clear
		for side in [-1.0, 1.0]:
			var t = Transform3D()
			if is_horizontal:
				var basis = Basis(Vector3.UP, 0.0 if side > 0 else PI)
				t = Transform3D(basis, Vector3(pos_val, 0.20, center.z + side * side_offset))
			else:
				var basis = Basis(Vector3.UP, -PI * 0.5 if side > 0 else PI * 0.5)
				t = Transform3D(basis, Vector3(center.x + side * side_offset, 0.20, pos_val))
			valid_transforms.append(t)
			
	if valid_transforms.is_empty():
		return
		
	var seat_mesh = BoxMesh.new()
	seat_mesh.size = Vector3(2.0, 0.12, 0.6)
	var mm_wood = MultiMesh.new()
	mm_wood.transform_format = MultiMesh.TRANSFORM_3D
	mm_wood.mesh = seat_mesh
	mm_wood.instance_count = valid_transforms.size()
	
	for i in range(valid_transforms.size()):
		var t = valid_transforms[i]
		var seat_t = t.translated_local(Vector3(0, 0.42, 0))
		mm_wood.set_instance_transform(i, seat_t)
		
	var mm_wood_inst = MultiMeshInstance3D.new()
	mm_wood_inst.multimesh = mm_wood
	mm_wood_inst.material_override = wood_mat
	mm_wood_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node.add_child(mm_wood_inst)
	
	# Cast iron legs
	var leg_mesh = BoxMesh.new()
	leg_mesh.size = Vector3(0.08, 0.44, 0.58)
	var mm_leg = MultiMesh.new()
	mm_leg.transform_format = MultiMesh.TRANSFORM_3D
	mm_leg.mesh = leg_mesh
	mm_leg.instance_count = valid_transforms.size() * 2
	
	var leg_idx = 0
	for i in range(valid_transforms.size()):
		var t = valid_transforms[i]
		for leg_x in [-0.9, 0.9]:
			var leg_t = t.translated_local(Vector3(leg_x, 0.22, 0))
			mm_leg.set_instance_transform(leg_idx, leg_t)
			leg_idx += 1
			
	var mm_leg_inst = MultiMeshInstance3D.new()
	mm_leg_inst.multimesh = mm_leg
	mm_leg_inst.material_override = metal_mat
	mm_leg_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node.add_child(mm_leg_inst)

static func _build_parking_bays(chunk_node: Node3D, road_center: float, is_horizontal: bool):
	var mat_white = WorldMaterialManager.get_white_line_material()
	var stall_width = 3.2
	var stall_depth = 5.2
	var stall_count = 4
	var bay_start = 24.0
	var shoulder_edge = ROAD_WIDTH * 0.5 - stall_depth * 0.5
	
	for i in range(stall_count):
		var p_x = bay_start + i * stall_width
		# Stall dividing line
		var line_mesh = BoxMesh.new()
		var line_inst = MeshInstance3D.new()
		line_inst.material_override = mat_white
		if is_horizontal:
			line_mesh.size = Vector3(0.12, 0.015, stall_depth)
			line_inst.position = Vector3(p_x, 0.092, road_center - shoulder_edge)
		else:
			line_mesh.size = Vector3(stall_depth, 0.015, 0.12)
			line_inst.position = Vector3(road_center - shoulder_edge, 0.092, p_x)
		line_inst.mesh = line_mesh
		line_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		chunk_node.add_child(line_inst)
		
		# Place a parked civilian vehicle in every 2nd stall
		if i % 2 == 1 and parked_car_prefab:
			var car_prop = parked_car_prefab.instantiate()
			if is_horizontal:
				car_prop.position = Vector3(p_x - stall_width * 0.5, 0.10, road_center - shoulder_edge)
				car_prop.rotation_degrees = Vector3(0, 90, 0)
			else:
				car_prop.position = Vector3(road_center - shoulder_edge, 0.10, p_x - stall_width * 0.5)
			car_prop.scale = Vector3(1.15, 1.15, 1.15)
			for c in car_prop.find_children("*", "MeshInstance3D"):
				c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			chunk_node.add_child(car_prop)

static func _build_electricity_poles(chunk_node: Node3D, road_pos: float, size: float, is_horizontal: bool):
	var spacing = 48.0
	var count = int(size / spacing)
	if count <= 0: return
	
	var wood_mat = WorldMaterialManager.get_wood_material()
	
	var p_mesh = CylinderMesh.new()
	p_mesh.top_radius = 0.14
	p_mesh.bottom_radius = 0.20
	p_mesh.height = 9.2
	
	var mm_pole = MultiMesh.new()
	mm_pole.transform_format = MultiMesh.TRANSFORM_3D
	mm_pole.mesh = p_mesh
	mm_pole.instance_count = count
	
	var bar_mesh = BoxMesh.new()
	bar_mesh.size = Vector3(2.8, 0.16, 0.16)
	
	var mm_bar = MultiMesh.new()
	mm_bar.transform_format = MultiMesh.TRANSFORM_3D
	mm_bar.mesh = bar_mesh
	mm_bar.instance_count = count
	
	for i in range(count):
		var main_pos = i * spacing + spacing * 0.5
		var pos = Vector3(main_pos, 4.6, road_pos + 9.5) if is_horizontal else Vector3(road_pos + 9.5, 4.6, main_pos)
		mm_pole.set_instance_transform(i, Transform3D(Basis(), pos))
		
		var bar_pos = Vector3(main_pos, 8.4, road_pos + 9.5) if is_horizontal else Vector3(road_pos + 9.5, 8.4, main_pos)
		mm_bar.set_instance_transform(i, Transform3D(Basis(), bar_pos))
		
	var pole_inst = MultiMeshInstance3D.new()
	pole_inst.multimesh = mm_pole
	pole_inst.material_override = wood_mat
	pole_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node.add_child(pole_inst)
	
	var bar_inst = MultiMeshInstance3D.new()
	bar_inst.multimesh = mm_bar
	bar_inst.material_override = wood_mat
	bar_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node.add_child(bar_inst)

static func _build_streetlights(chunk_node: Node3D, road_pos: float, size: float, is_horizontal: bool):
	var spacing = 32.0
	var count = int(size / spacing)
	
	var pole_mesh = CylinderMesh.new()
	pole_mesh.top_radius = 0.08
	pole_mesh.bottom_radius = 0.14
	pole_mesh.height = 6.8
	
	var pole_mat = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.24, 0.25, 0.27)
	pole_mat.metallic = 0.7
	pole_mat.roughness = 0.35
	
	var glow_mesh = BoxMesh.new()
	glow_mesh.size = Vector3(1.1, 0.3, 0.45)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = pole_mesh
	mm.instance_count = count * 2
	
	var mm_glow = MultiMesh.new()
	mm_glow.transform_format = MultiMesh.TRANSFORM_3D
	mm_glow.mesh = glow_mesh
	mm_glow.instance_count = count * 2
	
	var idx = 0
	for i in range(count):
		var main_pos = i * spacing + spacing * 0.5
		for side in [-8.8, 8.8]:
			var pos: Vector3
			if is_horizontal:
				pos = Vector3(main_pos, 3.4, road_pos + side)
			else:
				pos = Vector3(road_pos + side, 3.4, main_pos)
			var t = Transform3D(Basis(), pos)
			mm.set_instance_transform(idx, t)
			
			var t_glow = Transform3D(Basis(), pos + Vector3(0.0, 3.3, 0.0))
			mm_glow.set_instance_transform(idx, t_glow)
			idx += 1
			
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.multimesh = mm
	mm_inst.material_override = pole_mat
	mm_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node.add_child(mm_inst)
	
	var mm_glow_inst = MultiMeshInstance3D.new()
	mm_glow_inst.multimesh = mm_glow
	mm_glow_inst.material_override = WorldMaterialManager.get_lamp_glow_material()
	mm_glow_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node.add_child(mm_glow_inst)

static func _place_highway_props(chunk_node: Node3D):
	if barrier_prefab:
		for b in range(2):
			var barrier = barrier_prefab.instantiate()
			barrier.position = Vector3(25.0 + b * 55.0, 0.1, 56.5)
			for c in barrier.find_children("*", "MeshInstance3D"):
				c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			chunk_node.add_child(barrier)
	if cone_prefab:
		for c in range(3):
			var cone = cone_prefab.instantiate()
			cone.position = Vector3(45.0 + c * 3.5, 0.1, 71.5)
			for ch in cone.find_children("*", "MeshInstance3D"):
				ch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			chunk_node.add_child(cone)
	if sign_prefab:
		var sign = sign_prefab.instantiate()
		sign.position = Vector3(40.0, 0.1, 71.5)
		for ch in sign.find_children("*", "MeshInstance3D"):
			ch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		chunk_node.add_child(sign)

static func _build_highway_barriers(chunk_node: Node3D, road_pos: float, size: float, is_horizontal: bool):
	var conc_mat = WorldMaterialManager.get_building_concrete_material()
	var refl_mat = WorldMaterialManager.get_yellow_line_material()
	var barrier_offset = (ROAD_WIDTH + SIDEWALK_WIDTH) * 0.5 + CURB_WIDTH + 0.35 # Outer shoulder edge
	
	for side in [-1.0, 1.0]:
		var b_mesh = BoxMesh.new()
		var b_inst = MeshInstance3D.new()
		var pos: Vector3
		if is_horizontal:
			b_mesh.size = Vector3(size, 0.85, 0.45)
			pos = Vector3(size * 0.5, 0.425, road_pos + side * barrier_offset)
		else:
			b_mesh.size = Vector3(0.45, 0.85, size)
			pos = Vector3(road_pos + side * barrier_offset, 0.425, size * 0.5)
			
		b_inst.mesh = b_mesh
		b_inst.material_override = conc_mat
		b_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		b_inst.position = pos
		chunk_node.add_child(b_inst)
		
		# Solid collision body protecting highway shoulders without wheel snagging
		var sb = StaticBody3D.new()
		sb.collision_layer = 1
		var col = CollisionShape3D.new()
		var bshape = BoxShape3D.new()
		bshape.size = b_mesh.size
		col.shape = bshape
		sb.add_child(col)
		b_inst.add_child(sb)
		
		# Amber highway safety reflectors mounted along barrier top
		var num_refl = int(size / 16.0)
		for r in range(num_refl):
			var r_mesh = BoxMesh.new()
			r_mesh.size = Vector3(0.14, 0.08, 0.14)
			var r_inst = MeshInstance3D.new()
			r_inst.mesh = r_mesh
			r_inst.material_override = refl_mat
			r_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var r_coord = r * 16.0 + 8.0
			if is_horizontal:
				r_inst.position = Vector3(r_coord - size * 0.5, 0.45, 0.0)
			else:
				r_inst.position = Vector3(0.0, 0.45, r_coord - size * 0.5)
			b_inst.add_child(r_inst)
