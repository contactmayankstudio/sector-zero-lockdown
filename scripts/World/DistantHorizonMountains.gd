# DistantHorizonMountains.gd
# AGENT 3: DISTANT HORIZON LANDSCAPE, TERRAIN APRON & MOUNTAIN PERIMETER
# Renders a continuous 360-degree mountain horizon perimeter ring (radius 340m - 1980m),
# an open-world ground terrain apron (LOD), and continuous distant road corridors.
# Guarantees ground, roads, and perimeter mountains are visible from all camera angles
# with zero horizon void or plain gradient background.
class_name DistantHorizonMountains
extends Node3D

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")
const WorldMaterialManager = preload("res://scripts/World/WorldMaterialManager.gd")

var mountain_mesh_inst: MeshInstance3D = null
var ground_mesh_inst: MeshInstance3D = null
var road_mesh_inst: MeshInstance3D = null

func _ready():
	name = "DistantHorizonMountains"
	_generate_horizon_mountains()
	_generate_distant_ground_apron()
	_generate_distant_roads()

func _generate_horizon_mountains():
	var segments = 64
	var rings = 6
	var radii = [340.0, 520.0, 760.0, 1080.0, 1480.0, 1980.0]
	
	# Center around the open-world downtown/map center (64, 64)
	var center_x = 64.0
	var center_z = 64.0
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	for r_idx in range(rings):
		var r = radii[r_idx]
		for s_idx in range(segments):
			var angle = (float(s_idx) / float(segments)) * TAU
			var dir_x = cos(angle)
			var dir_z = sin(angle)
			
			var wx = center_x + dir_x * r
			var wz = center_z + dir_z * r
			
			var wy = 0.0
			var north_factor = clampf(-dir_z * 0.85 + 0.40, 0.35, 1.35) # Taller alpine crest in North/North-West
			
			if r_idx == 0:
				# Seamless match to terrain apron at inner boundary
				wy = OpenWorldConfig.get_terrain_height(wx, wz)
			elif r_idx == 1:
				# Foothills & lower ridge slopes
				var base_h = OpenWorldConfig.get_terrain_height(wx, wz)
				var ridge = sin(angle * 6.0) * 16.0 + cos(angle * 4.0) * 12.0
				wy = maxf(base_h, 16.0) + 18.0 + ridge
			elif r_idx == 2:
				# Mountain Massif Shoulder
				var shoulder_noise = sin(angle * 8.0) * 22.0 + cos(angle * 5.0) * 18.0
				wy = (52.0 + shoulder_noise) * north_factor
			elif r_idx == 3:
				# Mountain Peaks & Alpine Ridge Crest (up to 120m+ in North)
				var peak_noise = sin(angle * 9.0) * 28.0 + cos(angle * 5.0) * 20.0 + sin(angle * 15.0) * 10.0
				wy = (88.0 + peak_noise) * north_factor
			elif r_idx == 4:
				# Outer mountain slope descent
				var dist_noise = sin(angle * 6.0) * 18.0 + cos(angle * 3.0) * 14.0
				wy = (42.0 + dist_noise) * north_factor
			else:
				# Deep perimeter horizon skirt dropping below ground level all 360 degrees
				# Eliminates any horizon gap or plain gradient background under the mountains
				wy = -50.0
				
			vertices.append(Vector3(wx, wy, wz))
			uvs.append(Vector2(wx / 20.0, wz / 20.0))
			normals.append(Vector3.ZERO)
			
	# Generate Triangles between rings
	for r_idx in range(rings - 1):
		var ring1 = r_idx * segments
		var ring2 = (r_idx + 1) * segments
		for s_idx in range(segments):
			var next_s = (s_idx + 1) % segments
			
			var i0 = ring1 + s_idx
			var i1 = ring1 + next_s
			var i2 = ring2 + s_idx
			var i3 = ring2 + next_s
			
			# Triangle 1: i0 -> i2 -> i1
			indices.append(i0)
			indices.append(i2)
			indices.append(i1)
			
			# Triangle 2: i1 -> i2 -> i3
			indices.append(i1)
			indices.append(i2)
			indices.append(i3)
			
	# Analytical Normal Calculation & Accumulation
	for i in range(0, indices.size(), 3):
		var ia = indices[i]
		var ib = indices[i + 1]
		var ic = indices[i + 2]
		var va = vertices[ia]
		var vb = vertices[ib]
		var vc = vertices[ic]
		var fnorm = (vb - va).cross(vc - va).normalized()
		if fnorm.y < 0.0:
			fnorm = -fnorm
		normals[ia] += fnorm
		normals[ib] += fnorm
		normals[ic] += fnorm
		
	for i in range(normals.size()):
		if normals[i].length_squared() > 0.001:
			normals[i] = normals[i].normalized()
		else:
			normals[i] = Vector3.UP
		
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_distant_mountain_material())
	
	mountain_mesh_inst = MeshInstance3D.new()
	mountain_mesh_inst.mesh = arr_mesh
	mountain_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mountain_mesh_inst)
	print("[HORIZON] Distant Mountain Perimeter generated (64 segs, 6 rings, deep skirt, zero void).")

func _generate_distant_ground_apron():
	# Continuous low-poly terrain mesh covering entire world inside mountain ring (radius 0m - 340m).
	# Guarantees ground is visible across unloaded chunks from any elevation or camera angle.
	var segments = 48
	var rings = 5
	var radii = [30.0, 95.0, 170.0, 255.0, 340.0]
	
	var center_x = 64.0
	var center_z = 64.0
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Center vertex
	var center_h = OpenWorldConfig.get_terrain_height(center_x, center_z) - 0.08
	vertices.append(Vector3(center_x, center_h, center_z))
	normals.append(Vector3.UP)
	uvs.append(Vector2(center_x / 20.0, center_z / 20.0))
	
	for r_idx in range(rings):
		var r = radii[r_idx]
		for s_idx in range(segments):
			var angle = (float(s_idx) / float(segments)) * TAU
			var wx = center_x + cos(angle) * r
			var wz = center_z + sin(angle) * r
			var wy = OpenWorldConfig.get_terrain_height(wx, wz) - 0.08
			
			vertices.append(Vector3(wx, wy, wz))
			normals.append(Vector3.UP)
			uvs.append(Vector2(wx / 20.0, wz / 20.0))
			
	# Triangles from center to ring 0
	for s_idx in range(segments):
		var next_s = (s_idx + 1) % segments
		indices.append(0)
		indices.append(1 + s_idx)
		indices.append(1 + next_s)
		
	# Triangles between concentric rings
	for r_idx in range(rings - 1):
		var ring1 = 1 + r_idx * segments
		var ring2 = 1 + (r_idx + 1) * segments
		for s_idx in range(segments):
			var next_s = (s_idx + 1) % segments
			var i0 = ring1 + s_idx
			var i1 = ring1 + next_s
			var i2 = ring2 + s_idx
			var i3 = ring2 + next_s
			
			indices.append(i0)
			indices.append(i2)
			indices.append(i1)
			
			indices.append(i1)
			indices.append(i2)
			indices.append(i3)
			
	# Analytical Normal calculation
	for i in range(0, indices.size(), 3):
		var ia = indices[i]
		var ib = indices[i + 1]
		var ic = indices[i + 2]
		var va = vertices[ia]
		var vb = vertices[ib]
		var vc = vertices[ic]
		var fnorm = (vb - va).cross(vc - va).normalized()
		if fnorm.y < 0.0:
			fnorm = -fnorm
		normals[ia] += fnorm
		normals[ib] += fnorm
		normals[ic] += fnorm
		
	for i in range(normals.size()):
		if normals[i].length_squared() > 0.001:
			normals[i] = normals[i].normalized()
		else:
			normals[i] = Vector3.UP
			
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_distant_ground_material())
	
	ground_mesh_inst = MeshInstance3D.new()
	ground_mesh_inst.mesh = arr_mesh
	ground_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground_mesh_inst)
	print("[HORIZON] Distant Ground Apron generated (continuous terrain coverage).")

func _generate_distant_roads():
	# Continuous distant road corridors stretching out to the horizon mountains
	# Ensures East-West Highway and North-South Avenue are visible without abrupt clipping
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	var road_w = 14.0
	var half_w = road_w * 0.5
	
	# 1. East-West Highway (z = 64.0, x from -340.0 to 420.0)
	var x_steps = 28
	var x_start = -340.0
	var x_end = 420.0
	var x_step = (x_end - x_start) / float(x_steps)
	
	var ew_start_idx = vertices.size()
	for i in range(x_steps + 1):
		var wx = x_start + float(i) * x_step
		var wz = 64.0
		var wy = OpenWorldConfig.get_terrain_height(wx, wz) + 0.02
		
		vertices.append(Vector3(wx, wy, wz - half_w))
		vertices.append(Vector3(wx, wy, wz + half_w))
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		uvs.append(Vector2(wx / 4.0, 0.0))
		uvs.append(Vector2(wx / 4.0, 1.0))
		
		if i < x_steps:
			var base_i = ew_start_idx + i * 2
			indices.append(base_i)
			indices.append(base_i + 2)
			indices.append(base_i + 1)
			
			indices.append(base_i + 1)
			indices.append(base_i + 2)
			indices.append(base_i + 3)
			
	# 2. North-South Avenue (x = 64.0, z from -340.0 to 360.0)
	var z_steps = 26
	var z_start = -340.0
	var z_end = 360.0
	var z_step = (z_end - z_start) / float(z_steps)
	
	var ns_start_idx = vertices.size()
	for i in range(z_steps + 1):
		var wx = 64.0
		var wz = z_start + float(i) * z_step
		var wy = OpenWorldConfig.get_terrain_height(wx, wz) + 0.02
		
		vertices.append(Vector3(wx - half_w, wy, wz))
		vertices.append(Vector3(wx + half_w, wy, wz))
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		uvs.append(Vector2(wz / 4.0, 0.0))
		uvs.append(Vector2(wz / 4.0, 1.0))
		
		if i < z_steps:
			var base_i = ns_start_idx + i * 2
			indices.append(base_i)
			indices.append(base_i + 2)
			indices.append(base_i + 1)
			
			indices.append(base_i + 1)
			indices.append(base_i + 2)
			indices.append(base_i + 3)
			
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_road_material())
	
	road_mesh_inst = MeshInstance3D.new()
	road_mesh_inst.mesh = arr_mesh
	road_mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(road_mesh_inst)
	print("[HORIZON] Distant Road Corridors generated (continuous highway & avenue).")
