extends SceneTree

func _init():
	print("--- TESTING UI SCENES LOAD ---")
	var scenes_to_test = [
		"res://scenes/UI/MainMenu.tscn",
		"res://scenes/UI/ArmoryUI.tscn",
		"res://scenes/UI/MissionSelect.tscn",
		"res://scenes/UI/MissionCard.tscn",
		"res://scenes/UI/ResultUI.tscn"
	]
	
	var all_ok = true
	for p in scenes_to_test:
		var sc = load(p)
		if not sc:
			print("❌ FAILED to load: ", p)
			all_ok = false
			continue
		var inst = sc.instantiate()
		if not inst:
			print("❌ FAILED to instantiate: ", p)
			all_ok = false
			continue
		root.add_child(inst)
		print("✅ SUCCESS: ", p, " (Node: ", inst.name, ")")
		inst.queue_free()
		
	if all_ok:
		print("🎉 ALL UI SCENES LOADED AND INSTANTIATED SUCCESSFULLY!")
		quit(0)
	else:
		print("❌ ERRORS FOUND IN UI SCENES")
		quit(1)
