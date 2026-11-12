# TerrainChunk.gd
# AGENT 2: PROCEDURAL REALISTIC TERRAIN GENERATION
# Builds seamless 128m x 128m terrain mesh with verified upward normals, PBR materials, and solid physics collision.
class_name TerrainChunk
extends Node3D

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")
const WorldMaterialManager = preload("res://scripts/World/WorldMaterialManager.gd")

var chunk_coord: Vector2i
var region_type: int
var mesh_instance: MeshInstance3D
var static_body: StaticBody3D
var collision_shape: CollisionShape3D

func init_chunk(coord: Vector2i):
	chunk_coord = coord
	region_type = OpenWorldConfig.get_region_for_chunk(coord.x, coord.y)
	name = "Terrain_%d_%d" % [coord.x, coord.y]
	position = Vector3.ZERO
	_generate_terrain()

func _generate_terrain():
	var res = OpenWorldConfig.CHUNK_RESOLUTION
	var size = OpenWorldConfig.CHUNK_SIZE
	var step = size / float(res)
	var origin_x = float(chunk_coord.x) * size
	var origin_z = float(chunk_coord.y) * size
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Generate Grid Vertices with Upward Normals
	for gz in range(res + 1):
		for gx in range(res + 1):
			var lx = gx * step
			var lz = gz * step
			var wx = origin_x + lx
			var wz = origin_z + lz
			var wy = OpenWorldConfig.get_terrain_height(wx, wz)
			
			vertices.append(Vector3(lx, wy, lz))
			uvs.append(Vector2(wx / 10.0, wz / 10.0))
			
			# Analytical finite-difference normal pointing UPWARDS
			var delta = 0.5
			var h_l = OpenWorldConfig.get_terrain_height(wx - delta, wz)
			var h_r = OpenWorldConfig.get_terrain_height(wx + delta, wz)
			var h_d = OpenWorldConfig.get_terrain_height(wx, wz - delta)
			var h_u = OpenWorldConfig.get_terrain_height(wx, wz + delta)
			var norm = Vector3(h_l - h_r, 2.0 * delta, h_d - h_u).normalized()
			if norm.y < 0.0:
				norm = -norm
			normals.append(norm)
			
	# Triangles: Continuous unified mesh with procedural slope-blended PBR shader
	indices.clear()
	
	for gz in range(res):
		for gx in range(res):
			var row1 = gz * (res + 1)
			var row2 = (gz + 1) * (res + 1)
			
			var i0 = row1 + gx
			var i1 = row1 + gx + 1
			var i2 = row2 + gx
			var i3 = row2 + gx + 1
			
			# Triangle 1: i0 -> i2 -> i1 (Upward Normal pointing +Y)
			indices.append(i0)
			indices.append(i2)
			indices.append(i1)
			
			# Triangle 2: i1 -> i2 -> i3 (Upward Normal pointing +Y)
			indices.append(i1)
			indices.append(i2)
			indices.append(i3)
			
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.surface_set_material(0, WorldMaterialManager.get_terrain_material(region_type))
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	
	# Generate Solid Trimesh Collision with Backface Collision enabled
	static_body = StaticBody3D.new()
	static_body.collision_layer = 1
	static_body.collision_mask = 0
	
	collision_shape = CollisionShape3D.new()
	var shape = arr_mesh.create_trimesh_shape()
	shape.backface_collision = true
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	
	# Solid chunk base box to absolutely guarantee no player/vehicle void fall
	var base_shape = BoxShape3D.new()
	base_shape.size = Vector3(size, 2.0, size)
	var base_col = CollisionShape3D.new()
	base_col.position = Vector3(size * 0.5, -1.0, size * 0.5)
	base_col.shape = base_shape
	static_body.add_child(base_col)
	
	add_child(static_body)
	
	# Coastal Ocean Water Surface (Only in Coastal Region, below land height)
	if region_type == OpenWorldConfig.RegionType.COASTAL:
		var water_mesh = PlaneMesh.new()
		water_mesh.size = Vector2(size, size)
		var water_inst = MeshInstance3D.new()
		water_inst.mesh = water_mesh
		water_inst.material_override = WorldMaterialManager.get_water_material()
		water_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		water_inst.position = Vector3(size * 0.5, -1.2, size * 0.5)
		add_child(water_inst)
