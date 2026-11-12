extends SceneTree

func _init():
	print("--- CHECK ZOMBIE VERTICES FOR FRONT / BACK ---")
	var scary_res = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = scary_res.instantiate()
	var mesh_inst: MeshInstance3D = inst.find_child("Object_7", true, false)
	if mesh_inst and mesh_inst.mesh:
		var arr = mesh_inst.mesh.surface_get_arrays(0)
		var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		# Find the highest vertex (top of head) and vertices around head height (y > 170 in cm, or y > 1.7m)
		var head_z_min = 9999.0
		var head_z_max = -9999.0
		var count = 0
		var sum_z = 0.0
		for v in verts:
			if v.y > 150.0: # near head
				if v.z < head_z_min: head_z_min = v.z
				if v.z > head_z_max: head_z_max = v.z
				sum_z += v.z
				count += 1
		print("Raw vertex head Z range: min=", head_z_min, " max=", head_z_max, " avg=", sum_z / float(count) if count > 0 else 0.0)
		
		# Now let's test how it's oriented inside inst
		print("Raw node scale: ", inst.get_child(0).scale if inst.get_child_count() > 0 else "none")
		print("Raw node rot: ", inst.get_child(0).rotation if inst.get_child_count() > 0 else "none")
	inst.free()
	
	# Now test with EnemyBase ModelWrapper
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var z = z_scene.instantiate()
	root.add_child(z)
	z._ready()
	
	# Check global transform of the zombie mesh in world space when z is at (0,0,0) facing default
	var m_child: MeshInstance3D = z.find_child("Object_7", true, false)
	if m_child:
		print("m_child global_transform basis: ", m_child.global_transform.basis)
		var test_forward = m_child.global_transform.basis * Vector3(0, 0, 1)
		print("m_child local +Z in world space points to: ", test_forward)
	
	quit(0)
