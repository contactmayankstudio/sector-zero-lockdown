@tool
extends SceneTree

func _init():
	print("=== DETAILED FACING INSPECTION ===")
	
	# 1. Velociraptor
	var vel_scn = load("res://scenes/zombies/models/RealVelociraptor.scn")
	var vel = vel_scn.instantiate()
	var skel: Skeleton3D = vel.find_children("*", "Skeleton3D", true, false)[0]
	var head_idx = skel.find_bone("head_16")
	var tail_idx = skel.find_bone("tail_11")
	var head_pose = skel.get_bone_global_rest(head_idx) if head_idx >= 0 else Transform3D()
	var tail_pose = skel.get_bone_global_rest(tail_idx) if tail_idx >= 0 else Transform3D()
	print("Velociraptor head global rest: ", head_pose.origin)
	print("Velociraptor tail global rest: ", tail_pose.origin)
	if head_pose.origin.z > tail_pose.origin.z:
		print("===> Velociraptor HEAD is at +Z (Faces +Z)!")
	else:
		print("===> Velociraptor HEAD is at -Z (Faces -Z)!")
	vel.free()
	
	# 2. Check Office Worker
	var off_scn = load("res://scenes/zombies/models/RealZombieOffice.scn")
	var off = off_scn.instantiate()
	var off_mesh: MeshInstance3D = off.find_children("*", "MeshInstance3D", true, false)[0]
	# Check where the nose is: in head region, the vertex with extreme Z
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(off_mesh.mesh, 0)
	var max_z_vert = Vector3.ZERO
	var min_z_vert = Vector3.ZERO
	var max_z = -999.0
	var min_z = 999.0
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		if v.y > 0.6: # upper body/head
			if v.z > max_z:
				max_z = v.z
				max_z_vert = v
			if v.z < min_z:
				min_z = v.z
				min_z_vert = v
	print("Office upper body: min Z vert: ", min_z_vert, " max Z vert: ", max_z_vert)
	# Check normals at max_z vs min_z
	print("Office max Z vert normal: ", mdt.get_vertex_normal(0))
	off.free()

	# 3. Check 6ft
	var s6_scn = load("res://scenes/zombies/models/RealZombie6ft.scn")
	var s6 = s6_scn.instantiate()
	for m in s6.find_children("*", "MeshInstance3D", true, false):
		print("6ft mesh: ", m.name, " aabb: ", m.get_aabb())
	s6.free()

	# 4. Check Biker
	var b_scn = load("res://scenes/zombies/models/RealZombieBiker.scn")
	var b = b_scn.instantiate()
	for m in b.find_children("*", "MeshInstance3D", true, false):
		print("Biker mesh: ", m.name, " aabb: ", m.get_aabb())
	b.free()

	# 5. Check Titan
	var t_scn = load("res://scenes/zombies/models/RealTitanBrute.scn")
	var t = t_scn.instantiate()
	for m in t.find_children("*", "MeshInstance3D", true, false):
		print("Titan mesh: ", m.name, " aabb: ", m.get_aabb())
	t.free()

	# 6. Check zombie_scary.scn
	var sc_scn = load("res://scenes/zombies/models/zombie_scary.scn")
	var sc = sc_scn.instantiate()
	var sc_skel: Skeleton3D = sc.find_children("*", "Skeleton3D", true, false)[0]
	var sc_head = sc_skel.find_bone("mixamorig_Head_06")
	print("Scary zombie head rest: ", sc_skel.get_bone_global_rest(sc_head).origin)
	sc.free()

	quit(0)
