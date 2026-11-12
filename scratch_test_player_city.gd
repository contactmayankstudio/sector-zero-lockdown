extends SceneTree

const TerrainChunk = preload("res://scripts/World/TerrainChunk.gd")
const RoadGenerator = preload("res://scripts/World/RoadGenerator.gd")
const CityBuilder = preload("res://scripts/World/CityBuilder.gd")
const OpenWorldConfig = preload("res://scripts/World/OpenWorldConfig.gd")

func _init():
	print("--- TEST PLAYER WITH CITYBUILDER ---")
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var terrain = TerrainChunk.new()
	root_node.add_child(terrain)
	terrain.init_chunk(Vector2i(0, 0))
	
	RoadGenerator.build_chunk_roads(root_node, Vector2i(0, 0), OpenWorldConfig.RegionType.CITY_DOWNTOWN)
	CityBuilder.populate_chunk(root_node, Vector2i(0, 0), OpenWorldConfig.RegionType.CITY_DOWNTOWN)
	
	var p_scene = load("res://scenes/player/Player.tscn")
	var pl = p_scene.instantiate()
	pl.position = Vector3(72.8, 2.0, 50.0)
	root_node.add_child(pl)
	
	for i in range(25):
		await process_frame
		print("Step %d | pos: %s | on_floor: %s" % [i, str(pl.position), str(pl.is_on_floor())])
		
	quit(0)
