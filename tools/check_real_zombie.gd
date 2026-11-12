@tool
extends SceneTree

func _init():
	print("=== CHECKING REAL INSTANTIATION OF Zombie.tscn ===")
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var z_inst = z_scene.instantiate()
	root.add_child(z_inst)
	
	# Give it 2 frames to process _ready and transforms
	for i in range(3):
		await process_frame
		
	print("Zombie root pos: ", z_inst.global_position, " rot: ", z_inst.global_rotation)
	
	var skel: Skeleton3D = z_inst.find_child("*Skeleton3D*", true, false)
	var ap: AnimationPlayer = z_inst.find_child("*AnimationPlayer*", true, false)
	
	print("Skeleton found: ", skel != null)
	print("AnimationPlayer found: ", ap != null)
	
	if skel:
		var b_head = skel.find_bone("mixamorig_Head_06")
		var b_hips = skel.find_bone("mixamorig_Hips_01")
		var b_toe = skel.find_bone("mixamorig_LeftToeBase_060")
		
		print("In Rest Pose / Ready:")
		var gh = skel.global_transform * skel.get_bone_global_pose(b_head)
		var ghip = skel.global_transform * skel.get_bone_global_pose(b_hips)
		var gtoe = skel.global_transform * skel.get_bone_global_pose(b_toe)
		print("Head global pos: ", gh.origin)
		print("Hips global pos: ", ghip.origin)
		print("Toe global pos: ", gtoe.origin)
		print("Toe Z relative to Hips Z: ", gtoe.origin.z - ghip.origin.z)
		
		if z_inst.has_method("_handle_chase"):
			print("\nTesting chase facing:")
			# Simulate player at (0, 0, -10)
			var dummy_player = Node3D.new()
			dummy_player.position = Vector3(0, 0, -10)
			root.add_child(dummy_player)
			z_inst.player = dummy_player
			z_inst._handle_chase(10.0, 0.016)
			
			for i in range(2):
				await process_frame
				
			gh = skel.global_transform * skel.get_bone_global_pose(b_head)
			ghip = skel.global_transform * skel.get_bone_global_pose(b_hips)
			gtoe = skel.global_transform * skel.get_bone_global_pose(b_toe)
			print("After chase towards player at (0, 0, -10):")
			print("Zombie global_rot: ", z_inst.global_rotation)
			print("Head global pos: ", gh.origin)
			print("Hips global pos: ", ghip.origin)
			print("Toe global pos: ", gtoe.origin)
			print("Toe Z relative to Hips Z: ", gtoe.origin.z - ghip.origin.z)
			if gtoe.origin.z < ghip.origin.z:
				print(">> Zombie is facing player at -Z! (CORRECT)")
			else:
				print(">> Zombie is facing AWAY from player at +Z! (BACKWARDS/MOONWALKING)")
				
			dummy_player.queue_free()
			
	z_inst.queue_free()
	print("=== DONE CHECKING Zombie.tscn ===")
	quit(0)
