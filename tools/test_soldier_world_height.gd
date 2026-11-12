extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_res.instantiate()
	get_root().add_child(soldier)
	
	var mesh_inst: MeshInstance3D = soldier.find_child("vanguard_Mesh", true, false)
	print("Mesh global_transform inside tree: ", mesh_inst.global_transform)
	var aabb = mesh_inst.mesh.get_aabb()
	var corner1 = mesh_inst.global_transform * aabb.position
	var corner2 = mesh_inst.global_transform * (aabb.position + aabb.size)
	print("Inside tree: corner1=", corner1)
	print("Inside tree: corner2=", corner2)
	print("Inside tree: Calculated Height (Y): ", abs(corner2.y - corner1.y), " meters")
	soldier.queue_free()
	quit(0)
