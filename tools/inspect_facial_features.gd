@tool
extends SceneTree

func _init():
	print("=== PRECISE ANATOMICAL ORIENTATION CHECK ===")
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
		var scn = load(path)
		var inst = scn.instantiate()
		print("\n==========================================")
		print("MODEL: ", name)
		
		# 1. Check Feet (bottom 15% of mesh) - Toes protrude forward, heel is back
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			if not m.mesh or not (m.mesh is ArrayMesh): continue
			var arr_mesh: ArrayMesh = m.mesh
			var aabb = arr_mesh.get_aabb()
			if aabb.size.y < 0.5: continue # skip small accessory meshes
			
			var mdt = MeshDataTool.new()
			mdt.create_from_surface(arr_mesh, 0)
			var min_y = aabb.position.y
			var max_y = min_y + aabb.size.y
			var foot_y_cutoff = min_y + aabb.size.y * 0.12 # bottom 12%
			var head_y_cutoff = min_y + aabb.size.y * 0.85 # top 15%
			
			# Feet analysis
			var foot_min_z = 999.0
			var foot_max_z = -999.0
			var foot_center_z = 0.0
			var foot_count = 0
			
			# Head analysis
			var head_min_z = 999.0
			var head_max_z = -999.0
			var head_center_z = 0.0
			var head_count = 0
			
			for i in range(mdt.get_vertex_count()):
				var v = mdt.get_vertex(i)
				if v.y <= foot_y_cutoff:
					foot_count += 1
					foot_center_z += v.z
					if v.z < foot_min_z: foot_min_z = v.z
					if v.z > foot_max_z: foot_max_z = v.z
				elif v.y >= head_y_cutoff:
					head_count += 1
					head_center_z += v.z
					if v.z < head_min_z: head_min_z = v.z
					if v.z > head_max_z: head_max_z = v.z
					
			if foot_count > 0:
				foot_center_z /= foot_count
				print("  [Mesh ", m.name, "] Feet Z range: [", foot_min_z, " to ", foot_max_z, "] center: ", foot_center_z)
				var dist_to_min = abs(foot_center_z - foot_min_z)
				var dist_to_max = abs(foot_max_z - foot_center_z)
				print("    Foot center to min_Z: ", dist_to_min, " | center to max_Z: ", dist_to_max)
				if dist_to_max > dist_to_min * 1.2:
					print("    ===> FEET / TOES EXTEND TOWARD +Z (Faces +Z!)")
				elif dist_to_min > dist_to_max * 1.2:
					print("    ===> FEET / TOES EXTEND TOWARD -Z (Faces -Z!)")
				else:
					print("    Feet elongation inconclusive.")
					
			if head_count > 0:
				head_center_z /= head_count
				print("  [Mesh ", m.name, "] Head Z range: [", head_min_z, " to ", head_max_z, "] center: ", head_center_z)
				var dist_to_min = abs(head_center_z - head_min_z)
				var dist_to_max = abs(head_max_z - head_center_z)
				print("    Head center to min_Z: ", dist_to_min, " | center to max_Z: ", dist_to_max)
				if dist_to_max > dist_to_min * 1.15:
					print("    ===> NOSE / FACE EXTENDS TOWARD +Z (Faces +Z!)")
				elif dist_to_min > dist_to_max * 1.15:
					print("    ===> NOSE / FACE EXTENDS TOWARD -Z (Faces -Z!)")
				else:
					print("    Head elongation inconclusive.")
					
		# Also check skeleton bones if available
		var skels = inst.find_children("*", "Skeleton3D", true, false)
		if not skels.is_empty():
			var skel: Skeleton3D = skels[0]
			for b_i in range(skel.get_bone_count()):
				var bn = skel.get_bone_name(b_i).to_lower()
				if "toe" in bn or "jaw" in bn or "snout" in bn or "mouth" in bn:
					var pose = skel.get_bone_global_rest(b_i)
					print("  Bone '", skel.get_bone_name(b_i), "' global rest origin: ", pose.origin)
					
		inst.free()
	quit(0)
