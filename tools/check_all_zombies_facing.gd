@tool
extends SceneTree

func _init():
	print("=== CHECKING ALL ZOMBIE MODELS FACING DIRECTION ===")
	var models = {
		"velociraptor": "res://scenes/zombies/models/RealVelociraptor.scn",
		"office": "res://scenes/zombies/models/RealZombieOffice.scn",
		"6ft": "res://scenes/zombies/models/RealZombie6ft.scn",
		"biker": "res://scenes/zombies/models/RealZombieBiker.scn",
		"titan": "res://scenes/zombies/models/RealTitanBrute.scn",
		"scary": "res://scenes/zombies/models/zombie_scary.scn"
	}
	
	for name in models:
		var path = models[name]
		if not ResourceLoader.exists(path):
			print("Model NOT found: ", path)
			continue
		var scn = load(path)
		var inst = scn.instantiate()
		
		# Find skeleton bones or mesh vertices
		var skel: Skeleton3D = null
		var skels = inst.find_children("*", "Skeleton3D", true, false)
		if not skels.is_empty():
			skel = skels[0]
			
		print("\n--- Model: ", name, " (", path, ") ---")
		if skel:
			print("  Has Skeleton: ", skel.name, " bone count: ", skel.get_bone_count())
			# Look for head, neck, nose, jaw bones
			for i in range(skel.get_bone_count()):
				var bname = skel.get_bone_name(i).to_lower()
				if "head" in bname or "jaw" in bname or "nose" in bname or "neck" in bname:
					var rest = skel.get_bone_rest(i)
					print("    Bone '", skel.get_bone_name(i), "' rest origin: ", rest.origin)
		
		# Check mesh vertices z min and z max
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		print("  MeshInstances: ", meshes.size())
		for m in meshes:
			var mesh: Mesh = m.mesh
			if mesh:
				var aabb = mesh.get_aabb()
				print("    Mesh '", m.name, "' local transform: ", m.transform, " AABB: ", aabb)
				# Check face vertices (top 20% of Y)
				var m_tool = MeshDataTool.new()
				var arr_mesh: ArrayMesh = null
				if mesh is ArrayMesh:
					arr_mesh = mesh
				if arr_mesh and arr_mesh.get_surface_count() > 0:
					m_tool.create_from_surface(arr_mesh, 0)
					var top_y = aabb.position.y + aabb.size.y * 0.8
					var avg_z_at_top = 0.0
					var count = 0
					var min_z = 999.0
					var max_z = -999.0
					for v_idx in range(m_tool.get_vertex_count()):
						var v = m_tool.get_vertex(v_idx)
						if v.y >= top_y:
							avg_z_at_top += v.z
							count += 1
							if v.z < min_z: min_z = v.z
							if v.z > max_z: max_z = v.z
					if count > 0:
						avg_z_at_top /= count
						print("    Top 20% (Head area) avg Z: ", avg_z_at_top, " min Z: ", min_z, " max Z: ", max_z)
						# Check normal of vertices in head area
						var avg_nz = 0.0
						for v_idx in range(m_tool.get_vertex_count()):
							var v = m_tool.get_vertex(v_idx)
							if v.y >= top_y:
								var n = m_tool.get_vertex_normal(v_idx)
								avg_nz += n.z
						avg_nz /= count
						print("    Head vertex normals avg Z: ", avg_nz)
						if avg_nz > 0.1:
							print("    ==> Head normals point toward +Z (faces +Z)")
						elif avg_nz < -0.1:
							print("    ==> Head normals point toward -Z (faces -Z)")
						else:
							print("    ==> Head normals ambiguous Z: ", avg_nz)
		
		inst.free()
	quit(0)
