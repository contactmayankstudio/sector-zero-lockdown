extends SceneTree

const SCENES = [
	"res://scenes/environments/UrbanStreet.tscn",
	"res://scenes/environments/AirportServiceRoad.tscn",
	"res://scenes/environments/RailwayStation.tscn",
	"res://scenes/environments/AbandonedTrain.tscn",
	"res://scenes/environments/DarkIndustrial.tscn",
	"res://scenes/environments/ApartmentComplex.tscn",
	"res://scenes/environments/NightCityStreet.tscn",
	"res://scenes/environments/AirportTerminal.tscn",
	"res://scenes/environments/FinalLockdown.tscn"
]

func _init():
	print("=== INSPECTING ENVIRONMENT SCENES & SPAWN POINTS ===")
	for path in SCENES:
		_check_scene(path)
	quit(0)

func _check_scene(path: String):
	print("\n--------------------------------------------------")
	print("SCENE: ", path)
	if not ResourceLoader.exists(path):
		print("  [ERROR] Scene does not exist!")
		return
	
	var packed = load(path) as PackedScene
	if not packed:
		print("  [ERROR] Failed to load PackedScene!")
		return
	
	var root = packed.instantiate()
	if not root:
		print("  [ERROR] Failed to instantiate root node!")
		return
	
	# Find GameManager / ZombieSpawner
	var spawner = null
	for node in _get_all_children(root):
		var script = node.get_script()
		if script and script.resource_path.ends_with("GameManager.gd"):
			spawner = node
			break
	
	if not spawner:
		print("  [ERROR] No node with GameManager.gd found in scene!")
		root.queue_free()
		return
	
	print("  Spawner node: ", spawner.name, " (path: ", root.get_path_to(spawner), ")")
	print("  zombie_scene configured: ", spawner.zombie_scene != null)
	
	var spawn_pts = spawner.spawn_points
	print("  Exported spawn_points count: ", spawn_pts.size())
	
	var registered_names = []
	var directions_found = {"front": false, "back": false, "left": false, "right": false}
	
	for idx in range(spawn_pts.size()):
		var sp = spawn_pts[idx]
		if sp == null:
			print("    [ERROR] spawn_points[%d] is NULL / unresolved!" % idx)
		else:
			registered_names.append(sp.name)
			var s_low = sp.name.to_lower()
			for d in directions_found.keys():
				if s_low.contains(d):
					directions_found[d] = true
			print("    [%d] %s at %s" % [idx, sp.name, sp.global_position])
	
	print("  Direction coverage in exported spawn_points:")
	for d in directions_found.keys():
		print("    - %s: %s" % [d.to_upper(), "YES" if directions_found[d] else "MISSING!"])
	
	# Now find all nodes in scene containing 'spawn'
	var all_spawn_nodes = []
	for node in _get_all_children(root):
		if node.name.to_lower().contains("spawn") and node is Node3D and node != spawner:
			all_spawn_nodes.append(node)
	
	var unexported = []
	for sn in all_spawn_nodes:
		if not spawn_pts.has(sn):
			unexported.append(sn.name)
	
	if not unexported.is_empty():
		print("  [WARN] Nodes named 'Spawn*' found in scene but NOT in spawner.spawn_points: ", unexported)
	
	# Check Player node
	var player = root.find_child("Player", true, false)
	print("  Player node present: ", player != null)
	
	root.queue_free()

func _get_all_children(node: Node) -> Array:
	var result = []
	for c in node.get_children():
		result.append(c)
		result.append_array(_get_all_children(c))
	return result
