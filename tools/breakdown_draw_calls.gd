extends SceneTree

func _init():
	var scn = load("res://scenes/world/GTAOpenWorld.tscn")
	var inst = scn.instantiate()
	root.add_child(inst)
	
	# Run 2 frames so chunks and objects instantiate
	await process_frame
	await process_frame
	
	var mesh_by_parent = {}
	var shadow_by_parent = {}
	var visible_meshes = 0
	var shadow_casters = 0
	var multimeshes = 0
	
	var stack = [inst]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node is MeshInstance3D:
			if node.is_visible_in_tree():
				visible_meshes += 1
				var p_name = node.get_parent().name if node.get_parent() else "Root"
				mesh_by_parent[p_name] = mesh_by_parent.get(p_name, 0) + 1
				if node.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
					shadow_casters += 1
					shadow_by_parent[p_name] = shadow_by_parent.get(p_name, 0) + 1
		elif node is MultiMeshInstance3D:
			if node.is_visible_in_tree():
				multimeshes += 1
				var p_name = node.get_parent().name if node.get_parent() else "Root"
				mesh_by_parent[p_name] = mesh_by_parent.get(p_name, 0) + 1
				if node.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
					shadow_casters += 1
					shadow_by_parent[p_name] = shadow_by_parent.get(p_name, 0) + 1
				
		for c in node.get_children():
			stack.append(c)
			
	print("Visible Meshes: ", visible_meshes)
	print("Shadow Casters: ", shadow_casters)
	print("MultiMeshes:    ", multimeshes)
	print("\nTop Shadow Casters by Parent:")
	var s_keys = shadow_by_parent.keys()
	s_keys.sort()
	for k in s_keys:
		if shadow_by_parent[k] > 1:
			print("  ", k, ": ", shadow_by_parent[k])
			
	quit(0)
