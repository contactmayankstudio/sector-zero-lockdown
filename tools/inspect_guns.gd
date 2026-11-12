@tool
extends SceneTree

func _init():
	var dir = DirAccess.open("/home/am/Downloads/gun")
	if not dir:
		print("Cannot open /home/am/Downloads/gun")
		quit()
		return
		
	dir.list_dir_begin()
	var fname = dir.get_next()
	var files = []
	while fname != "":
		if fname.ends_with(".glb") or fname.ends_with(".gltf"):
			files.append("/home/am/Downloads/gun/" + fname)
		fname = dir.get_next()
	dir.list_dir_end()
	
	files.sort()
	print("Found ", files.size(), " gun files.")
	
	for fpath in files:
		print("\n=== Inspecting: ", fpath.get_file(), " ===")
		var doc = GLTFDocument.new()
		var state = GLTFState.new()
		var err = doc.append_from_file(fpath, state)
		if err != OK:
			print("  ERR: ", err)
			continue
		var root = doc.generate_scene(state)
		if not root:
			print("  Failed to generate scene")
			continue
			
		var aabb = AABB()
		var first = true
		var mesh_count = 0
		var stack = [root]
		while stack.size() > 0:
			var n = stack.pop_back()
			if n is VisualInstance3D:
				var box = n.get_aabb()
				if first:
					aabb = box
					first = false
				else:
					aabb = aabb.merge(box)
				mesh_count += 1
			for c in n.get_children():
				stack.push_back(c)
		print("  Meshes: ", mesh_count, " Bounds: Pos=", aabb.position, " Size=", aabb.size)
		root.free()
	quit()
