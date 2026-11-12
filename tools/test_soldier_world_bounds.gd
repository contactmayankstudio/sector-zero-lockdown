extends SceneTree

func _init():
	var soldier_res = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_res.instantiate()
	var mesh_inst: MeshInstance3D = soldier.find_child("vanguard_Mesh", true, false)
	print("Mesh global transform with soldier scale (1,1,1): ", mesh_inst.global_transform)
	var aabb = mesh_inst.mesh.get_aabb()
	var min_pt = mesh_inst.global_transform * aabb.position
	var max_pt = mesh_inst.global_transform * (aabb.position + aabb.size)
	print("World bounds: min=", min_pt, " max=", max_pt, " height=", abs(max_pt.y - min_pt.y))
	soldier.queue_free()
	quit(0)
