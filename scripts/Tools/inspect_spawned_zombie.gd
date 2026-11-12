@tool
extends SceneTree

func _init():
	var scene = load("res://scenes/zombies/Zombie.tscn")
	var zombie = scene.instantiate()
	root.add_child(zombie)
	zombie._apply_archetype()
	
	var sk = zombie.find_child("Skeleton3D", true, false)
	if sk:
		for i in range(sk.get_bone_count()):
			var bname = sk.get_bone_name(i)
			if "foot" in bname.to_lower() or "toe" in bname.to_lower() or "leg" in bname.to_lower():
				var g_pose = sk.global_transform * sk.get_bone_global_pose(i)
				print(bname, " global pos: ", g_pose.origin)
	
	var meshes = zombie.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		if m.mesh:
			var g_aabb = m.global_transform * m.mesh.get_aabb()
			print("Mesh: ", m.name, " visible: ", m.visible, " global AABB: ", g_aabb)
	quit()
