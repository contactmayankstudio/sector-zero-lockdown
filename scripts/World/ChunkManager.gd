# ChunkManager.gd
# AGENT 9: PERFORMANCE ENGINEER & STREAMING COORDINATOR
# Manages 3x3 dynamic chunk streaming, strict coordinate mapping, and low-end 4GB RAM memory budget.
class_name ChunkManager
extends Node3D

const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")
const TerrainChunk = preload("res://scripts/World/TerrainChunk.gd")
const RoadGenerator = preload("res://scripts/World/RoadGenerator.gd")
const CityBuilder = preload("res://scripts/World/CityBuilder.gd")

@export var target_node: Node3D = null # Player or active Car
var active_chunks: Dictionary = {} # Vector2i -> Node3D
var current_center_chunk: Vector2i = Vector2i(9999, 9999)
var is_streaming_active: bool = true

func _process(_delta):
	if not is_streaming_active or not target_node or not is_instance_valid(target_node):
		return
		
	var player_pos = target_node.global_position
	var player_chunk = OpenWorldConfig.world_to_chunk_coord(player_pos)
	
	if player_chunk != current_center_chunk:
		current_center_chunk = player_chunk
		_update_chunks(player_chunk)

func _update_chunks(center: Vector2i):
	var needed_coords: Array[Vector2i] = []
	var radius = OpenWorldConfig.ACTIVE_CHUNK_RADIUS # 1 = 3x3 grid
	
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			needed_coords.append(Vector2i(center.x + dx, center.y + dz))
			
	# Unload distant chunks
	var to_remove: Array[Vector2i] = []
	for coord in active_chunks.keys():
		if not needed_coords.has(coord):
			to_remove.append(coord)
			
	for coord in to_remove:
		var chunk_node = active_chunks[coord]
		if is_instance_valid(chunk_node):
			chunk_node.queue_free()
		active_chunks.erase(coord)
		
	# Load new chunks
	for coord in needed_coords:
		if not active_chunks.has(coord):
			_load_chunk(coord)

func _load_chunk(coord: Vector2i):
	var size = OpenWorldConfig.CHUNK_SIZE
	var chunk_root = Node3D.new()
	chunk_root.name = "Chunk_%d_%d" % [coord.x, coord.y]
	# Strictly position chunk in world space
	chunk_root.position = Vector3(float(coord.x) * size, 0.0, float(coord.y) * size)
	add_child(chunk_root)
	active_chunks[coord] = chunk_root
	
	var region_type = OpenWorldConfig.get_region_for_chunk(coord.x, coord.y)
	
	# 1. Terrain Mesh & Solid Physics Collision
	var terrain = TerrainChunk.new()
	chunk_root.add_child(terrain)
	terrain.init_chunk(coord)
	
	# 2. Road Network & Streetlights
	RoadGenerator.build_chunk_roads(chunk_root, coord, region_type)
	
	# 3. City Buildings, Props & Vegetation
	CityBuilder.populate_chunk(chunk_root, coord, region_type)

func get_loaded_chunk_count() -> int:
	return active_chunks.size()
