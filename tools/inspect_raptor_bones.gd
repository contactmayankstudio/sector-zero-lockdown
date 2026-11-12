@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/models/RealVelociraptor.scn")
	var inst = scn.instantiate()
	var skel: Skeleton3D = inst.find_children("*", "Skeleton3D", true, false)[0]
	print("--- VELOCIRAPTOR BONES ---")
	for i in range(skel.get_bone_count()):
		var bname = skel.get_bone_name(i)
		var rest = skel.get_bone_global_rest(i)
		print(bname, " -> ", rest.origin)
	inst.free()
	quit(0)
