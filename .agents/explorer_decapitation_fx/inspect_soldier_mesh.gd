extends SceneTree

func _init():
	var s_res = load("res://scenes/zombies/models/RealSoldierZombie.scn")
	var s_inst = s_res.instantiate()
	for mi in s_inst.find_children("*", "MeshInstance3D", true, false):
		print("Soldier mesh: ", mi.name, " aabb: ", mi.get_aabb(), " skeleton: ", mi.skeleton)
	s_inst.free()
	quit()
