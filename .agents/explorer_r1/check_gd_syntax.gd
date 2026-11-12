extends SceneTree

func _init():
	print("Checking GDScript compile & parse integrity across project...")
	var errors = []
	var checked = 0
	
	var dirs = ["res://scripts", "res://scenes", "res://assets_tests", "res://tools"]
	for d in dirs:
		_scan_dir(d, errors)
		
	print("Checked %d GDScript files." % [checked + errors.size()])
	if errors.is_empty():
		print("[SUCCESS] All GDScript files loaded and parsed cleanly without compile/syntax errors!")
		quit(0)
	else:
		printerr("[FAIL] Encountered %d GDScript syntax/compile errors:" % errors.size())
		for e in errors:
			printerr("  - ", e)
		quit(1)

func _scan_dir(path: String, errors: Array):
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = path.path_join(file_name)
		if dir.current_is_dir():
			_scan_dir(full_path, errors)
		elif file_name.ends_with(".gd"):
			var res = load(full_path)
			if not res:
				errors.append(full_path + " (Failed to load/parse)")
			else:
				print("  [OK] ", full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
