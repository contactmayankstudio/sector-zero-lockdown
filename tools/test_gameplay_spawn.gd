extends SceneTree

func _init():
	print("--- TEST MESH VISIBILITY IN ZOMBIE ---")
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var z = z_scene.instantiate()
	root.add_child(z)
	z._ready()
	
	var mesh_inst = z.get_node("MeshInstance3D")
	print("MeshInstance3D visible? ", mesh_inst.visible)
	print("MeshInstance3D mesh: ", mesh_inst.mesh)
	
	var scary_res = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = scary_res.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	print("Meshes found in zombie_scary.scn: ", meshes.size())
	for m in meshes:
		print(" - ", m.name, " mesh: ", m.mesh)
	inst.free()
	
	quit(0)
