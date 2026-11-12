@tool
extends SceneTree

func _init():
	print("=== CHECKING FACE DIRECTION OF MESH VERTICES ===")
	var res = load("res://scenes/zombies/models/zombie_scary.scn")
	var inst = res.instantiate()
	root.add_child(inst)
	
	var mesh_insts = inst.find_children("*", "MeshInstance3D", true, false)
	print("Mesh instances count: ", mesh_insts.size())
	for mi in mesh_insts:
		print("Mesh name: ", mi.name)
		if mi.mesh:
			var m = mi.mesh
			print("Surface count: ", m.get_surface_count())
			var mdt = MeshDataTool.new()
			var err = mdt.create_from_surface(m, 0)
			print("mdt create err: ", err, " vertex count: ", mdt.get_vertex_count())
			
			var min_z_head = 9999.0
			var max_z_head = -9999.0
			var min_z_foot = 9999.0
			var max_z_foot = -9999.0
			
			for vi in range(mdt.get_vertex_count()):
				var v = mdt.get_vertex(vi)
				# Check head height (in local mesh coords, character is ~200cm tall)
				if v.y > 160.0:
					if v.z < min_z_head: min_z_head = v.z
					if v.z > max_z_head: max_z_head = v.z
				if v.y < 10.0:
					if v.z < min_z_foot: min_z_foot = v.z
					if v.z > max_z_foot: max_z_foot = v.z
					
			print("HEAD level (Y > 160): min_z = ", min_z_head, " max_z = ", max_z_head)
			print("FOOT level (Y < 10):  min_z = ", min_z_foot, " max_z = ", max_z_foot)
			
			# Test a nose vertex (furthest forward on face) vs back of head:
			# Usually face protrudes forward, back of head is flatter or extends backward
			# Let's check global transform of mesh:
			print("Mesh global transform: ", mi.global_transform)
			
	inst.queue_free()
	quit(0)
