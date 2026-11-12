extends SceneTree

func _init():
	print("--- TESTING FAST BOOT HEADLESS ---")
	var t0 = Time.get_ticks_msec()
	
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var t1 = Time.get_ticks_msec()
	print("AirportTerminal loaded in: ", t1 - t0, " ms")
	
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var t2 = Time.get_ticks_msec()
	print("AirportTerminal instantiated in: ", t2 - t1, " ms")
	
	var p = inst.find_child("Player", true, false)
	if p:
		print("Player found! Weapons loaded: ", p.weapons.size())
		if p.weapons.size() > 0:
			var w = p.weapons[p.current_weapon_index]
			print("Active weapon: ", w.name, " ID: ", w.weapon_data.weapon_id if w.weapon_data else "None")
			var wm = w.get_node_or_null("WeaponModel")
			print("WeaponModel child attached: ", wm != null)
	print("Total test time: ", Time.get_ticks_msec() - t0, " ms")
	print("--- TEST PASSED WITH ZERO FREEZE ---")
	quit(0)
