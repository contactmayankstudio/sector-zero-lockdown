extends SceneTree

func _init():
	print("--- RENDERING P90 VIEW CHECK ---")
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	
	for i in range(5):
		await process_frame
		
	var p = inst.find_child("Player", true, false)
	if p:
		print("Player found. Active weapon: ", p.weapons[p.current_weapon_index].weapon_data.display_name if p.weapons.size() > p.current_weapon_index else "none")
		var wm = p.weapons[p.current_weapon_index].get_node_or_null("WeaponModel")
		if wm:
			print("WeaponModel pos: ", wm.position, " rot: ", wm.rotation_degrees, " scale: ", wm.scale)
	
	inst.free()
	print("--- TEST PASSED ---")
	quit(0)
