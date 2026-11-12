extends SceneTree

func _init():
	var res = load("res://scenes/zombies/models/RealDoomZombie.scn")
	var inst = res.instantiate()
	for mi in inst.find_children("*", "MeshInstance3D", true, false):
		print("Doom mesh: ", mi.name, " surfaces: ", mi.mesh.get_surface_count() if mi.mesh else 0)
		if mi.mesh:
			for s in range(mi.mesh.get_surface_count()):
				var mat = mi.get_active_material(s)
				print("   surface ", s, " mat: ", mat.resource_name if mat else "null")
	inst.free()
	
	print("--- Soldier ---")
	var s_res = load("res://scenes/zombies/models/RealSoldierZombie.scn")
	var s_inst = s_res.instantiate()
	for mi in s_inst.find_children("*", "MeshInstance3D", true, false):
		print("Soldier mesh: ", mi.name, " surfaces: ", mi.mesh.get_surface_count() if mi.mesh else 0)
		if mi.mesh:
			for s in range(mi.mesh.get_surface_count()):
				var mat = mi.get_active_material(s)
				print("   surface ", s, " mat: ", mat.resource_name if mat else "null")
	s_inst.free()
	quit()
