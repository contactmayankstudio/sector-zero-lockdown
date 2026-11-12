
extends SceneTree

var frame = 0
func _process(d):
	frame += 1
	if frame == 1:
		var root_node = Node3D.new()
		root.add_child(root_node)
		
		var sun = DirectionalLight3D.new()
		sun.rotation_degrees = Vector3(-30, 45, 0)
		sun.light_energy = 1.3
		root_node.add_child(sun)
		
		# RealDoomZombie
		var s1 = load("res://scenes/zombies/models/RealDoomZombie.scn")
		var inst1 = s1.instantiate()
		inst1.position = Vector3(-0.6, 0, 0)
		inst1.scale = Vector3(1.3, 1.3, 1.3)
		inst1.rotation.y = PI
		root_node.add_child(inst1)
		
		var sk1 = inst1.find_child("*Skeleton3D*", true, false) as Skeleton3D
		if sk1:
			var l_arm = sk1.find_bone("ValveBiped.Bip01_L_UpperArm_78")
			var r_arm = sk1.find_bone("ValveBiped.Bip01_R_UpperArm_105")
			var l_fore = sk1.find_bone("ValveBiped.Bip01_L_Forearm_75")
			var r_fore = sk1.find_bone("ValveBiped.Bip01_R_Forearm_102")
			var spine = sk1.find_bone("ValveBiped.Bip01_Spine2_109")
			# In ValveBiped, upper arm local X is along the bone
			if l_arm >= 0:
				sk1.set_bone_pose_rotation(l_arm, Quaternion(Vector3(0, 0, 1), deg_to_rad(-55.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(50.0)))
			if r_arm >= 0:
				sk1.set_bone_pose_rotation(r_arm, Quaternion(Vector3(0, 0, 1), deg_to_rad(55.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-50.0)))
			if l_fore >= 0:
				sk1.set_bone_pose_rotation(l_fore, Quaternion(Vector3(0, 1, 0), deg_to_rad(35.0)))
			if r_fore >= 0:
				sk1.set_bone_pose_rotation(r_fore, Quaternion(Vector3(0, 1, 0), deg_to_rad(-35.0)))
			if spine >= 0:
				sk1.set_bone_pose_rotation(spine, Quaternion(Vector3(0, 0, 1), deg_to_rad(12.0)))
		
		# RealSoldierZombie
		var s2 = load("res://scenes/zombies/models/RealSoldierZombie.scn")
		var inst2 = s2.instantiate()
		inst2.position = Vector3(0.6, 0, 0)
		inst2.scale = Vector3(1.0, 1.0, 1.0)
		inst2.rotation.y = PI
		root_node.add_child(inst2)
		
		var sk2 = inst2.find_child("*Skeleton3D*", true, false) as Skeleton3D
		if sk2:
			var l_arm = sk2.find_bone("mixamorig_LeftArm_09")
			var r_arm = sk2.find_bone("mixamorig_RightArm_020")
			var l_fore = sk2.find_bone("mixamorig_LeftForeArm_010")
			var r_fore = sk2.find_bone("mixamorig_RightForeArm_021")
			var spine = sk2.find_bone("mixamorig_Spine1_03")
			if l_arm >= 0:
				sk2.set_bone_pose_rotation(l_arm, Quaternion(Vector3(0, 0, 1), deg_to_rad(-60.0)) * Quaternion(Vector3(1, 0, 0), deg_to_rad(45.0)))
			if r_arm >= 0:
				sk2.set_bone_pose_rotation(r_arm, Quaternion(Vector3(0, 0, 1), deg_to_rad(60.0)) * Quaternion(Vector3(1, 0, 0), deg_to_rad(45.0)))
			if l_fore >= 0:
				sk2.set_bone_pose_rotation(l_fore, Quaternion(Vector3(0, 0, 1), deg_to_rad(-20.0)))
			if r_fore >= 0:
				sk2.set_bone_pose_rotation(r_fore, Quaternion(Vector3(0, 0, 1), deg_to_rad(20.0)))
			if spine >= 0:
				sk2.set_bone_pose_rotation(spine, Quaternion(Vector3(1, 0, 0), deg_to_rad(10.0)))
		
		var cam = Camera3D.new()
		root_node.add_child(cam)
		cam.position = Vector3(0, 1.1, -2.4)
		cam.look_at(Vector3(0, 0.9, 0), Vector3.UP)
		cam.current = true
	elif frame == 8:
		var img = root.get_viewport().get_texture().get_image()
		if img:
			img.save_png("screenshots/preview_posed_zombies_v2.png")
			print("Saved screenshots/preview_posed_zombies_v2.png")
		quit(0)
