@tool
extends SceneTree

func _init():
	print("--- PROBING MULTIMESH ---")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var inst = scn.instantiate()
	var pines = inst.get_node("AdvancedTerrain/FoliageAndProps/MultiMesh_PineTrees") as MultiMeshInstance3D
	var mm = pines.multimesh
	print("pines instance_count: ", mm.instance_count)
	print("pines buffer size: ", mm.buffer.size())
	print("pines get_instance_transform(0): ", mm.get_instance_transform(0))
	if mm.buffer.size() >= 12:
		print("pines buffer[0..11]: ", mm.buffer.slice(0, 12))
	
	# What if we set buffer?
	# Does get_instance_transform(0) change?
	inst.free()
	quit(0)
