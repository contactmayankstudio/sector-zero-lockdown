extends SceneTree

func _init():
	print("--- EXTRACTING ROAD PACK PROPS ---")
	var scn = load("res://scenes/environments/models/road_pack.scn")
	var inst = scn.instantiate()
	var root_node = inst.find_child("RootNode_80", true, false)
	if not root_node:
		print("ERROR: RootNode_80 not found!")
		quit(1)
		return

	# Helper to create StaticBody3D prop
	# 1. Concrete Barrier A
	_extract_static_prop(root_node, "BarrierA01_1", "res://scenes/environments/props/ConcreteBarrierA.scn", Vector3(4.0, 1.1, 0.7))
	# 2. Concrete Barrier B
	_extract_static_prop(root_node, "BarrierB01_7", "res://scenes/environments/props/ConcreteBarrierB.scn", Vector3(3.1, 1.1, 0.7))
	# 3. Road Closed Sign
	_extract_static_prop(root_node, "MainTrimNew1_35", "res://scenes/environments/props/RoadSignClosed.scn", Vector3(0.9, 1.0, 0.4))
	# 4. Road Works Sign
	_extract_static_prop(root_node, "MainTrimNew_29", "res://scenes/environments/props/RoadSignWorks.scn", Vector3(0.8, 1.0, 0.4))
	# 5. Traffic Cone
	_extract_static_prop(root_node, "TrafficCone01_53", "res://scenes/environments/props/TrafficCone.scn", Vector3(0.4, 0.7, 0.4))
	# 6. Straight Road
	_extract_road_section(root_node, "StraightRoad_49", "res://scenes/environments/props/StraightRoadSection.scn")

	inst.free()
	print("--- ALL PROPS EXTRACTED SUCCESSFULLY ---")
	quit(0)

func _extract_static_prop(root_node: Node, source_name: String, save_path: String, col_size: Vector3):
	var src = root_node.get_node_or_null(source_name)
	if not src:
		print("Source node not found: ", source_name)
		return
	
	var sb = StaticBody3D.new()
	sb.name = source_name.split("_")[0]
	
	# Duplicate visual node
	var visual = src.duplicate()
	visual.name = "Visuals"
	visual.transform = Transform3D.IDENTITY
	visual.scale = Vector3(0.01, 0.01, 0.01) # Convert cm to meters
	
	# Adjust center offset of visual if needed
	sb.add_child(visual)
	visual.owner = sb
	_set_owner_recursive(visual, sb)
	
	# Add collision
	var cs = CollisionShape3D.new()
	cs.name = "CollisionShape3D"
	var box = BoxShape3D.new()
	box.size = col_size
	cs.shape = box
	cs.position = Vector3(0, col_size.y * 0.5, 0)
	sb.add_child(cs)
	cs.owner = sb
	
	var packed = PackedScene.new()
	packed.pack(sb)
	var err = ResourceSaver.save(packed, save_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved ", save_path, " err: ", err)
	sb.free()

func _extract_road_section(root_node: Node, source_name: String, save_path: String):
	var src = root_node.get_node_or_null(source_name)
	if not src:
		print("Source road not found: ", source_name)
		return
		
	var sb = StaticBody3D.new()
	sb.name = "RoadSection"
	
	var visual = src.duplicate()
	visual.name = "Visuals"
	visual.transform = Transform3D.IDENTITY
	visual.scale = Vector3(0.01, 0.01, 0.01)
	visual.position = Vector3(7.0, 0, 4.5) # Center offset for road segment
	sb.add_child(visual)
	visual.owner = sb
	_set_owner_recursive(visual, sb)
	
	var cs = CollisionShape3D.new()
	cs.name = "CollisionShape3D"
	var box = BoxShape3D.new()
	box.size = Vector3(14.0, 0.2, 7.0)
	cs.shape = box
	cs.position = Vector3(0, -0.1, 0)
	sb.add_child(cs)
	cs.owner = sb
	
	var packed = PackedScene.new()
	packed.pack(sb)
	var err = ResourceSaver.save(packed, save_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved road section: ", save_path, " err: ", err)
	sb.free()

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
