extends SceneTree

const TerrainChunk = preload("res://scripts/World/TerrainChunk.gd")

func _init():
	print("--- TEST PLAYER ON TERRAIN CHUNK ---")
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var terrain = TerrainChunk.new()
	root_node.add_child(terrain)
	terrain.init_chunk(Vector2i(0, 0))
	
	var p_scene = load("res://scenes/player/Player.tscn")
	var pl = p_scene.instantiate()
	pl.position = Vector3(72.8, 2.0, 50.0)
	root_node.add_child(pl)
	
	for i in range(25):
		await process_frame
		print("Step %d | pos: %s | on_floor: %s" % [i, str(pl.position), str(pl.is_on_floor())])
		
	quit(0)
