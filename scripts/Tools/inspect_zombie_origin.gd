@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = scn.instantiate()
	var sk = inst.find_child("Skeleton3D", true, false)
	if sk:
		print("Bone count: ", sk.get_bone_count())
		for i in range(min(15, sk.get_bone_count())):
			print(i, ": ", sk.get_bone_name(i), " pose pos: ", sk.get_bone_pose_position(i))
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		print("Mesh: ", m.name, " aabb: ", m.mesh.get_aabb() if m.mesh else "null")
	quit()
