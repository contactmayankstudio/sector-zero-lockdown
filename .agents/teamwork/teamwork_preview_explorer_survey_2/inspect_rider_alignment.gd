extends SceneTree

func _init():
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root_node.add_child(bike)
	
	# Process one frame to update transforms
	create_timer(0.05).timeout.connect(func():
		_inspect(bike)
	)

func _inspect(bike: Node3D):
	print("\n=== BIKE HIERARCHY & COMPONENT TRANSFORMS ===")
	print("Bike global_position: ", bike.global_position)
	print("VisualWrapper position: ", bike.visual_wrapper.position, " rot: ", bike.visual_wrapper.rotation_degrees)
	
	var hayabusa = bike.visual_wrapper.get_node("HayabusaMesh")
	print("HayabusaMesh position: ", hayabusa.position, " rot: ", hayabusa.rotation_degrees)
	
	var steer = bike.fork_steer_node
	if steer:
		print("Handlebar / Fork steer node: ", steer.name)
		print("  Global pos: ", steer.global_position)
		print("  Local to bike: ", bike.to_local(steer.global_position))
	
	var rider = bike.rider_soldier
	print("\nRider soldier: ", rider != null)
	if rider:
		print("  Rider local to visual_wrapper: ", rider.position)
		print("  Rider global pos: ", rider.global_position)
		var skel: Skeleton3D = rider.find_child("Skeleton3D", true, false)
		var anim: AnimationPlayer = rider.find_child("AnimationPlayer", true, false)
		if anim:
			print("  Animation: ", anim.current_animation, " (playing: ", anim.is_playing(), ")")
			anim.advance(0.1)
		
		if skel:
			for b_name in ["mixamorig_Hips", "mixamorig_Spine2", "mixamorig_LeftHand", "mixamorig_RightHand", "mixamorig_LeftFoot", "mixamorig_RightFoot"]:
				var idx = skel.find_bone(b_name)
				if idx != -1:
					var g_pose = skel.get_bone_global_pose(idx)
					var w_pos = skel.global_transform * g_pose.origin
					var bike_pos = bike.to_local(w_pos)
					print("  Bone %-22s -> Global: %s  | Local to bike: %s" % [b_name, w_pos, bike_pos])
	
	# Let's inspect Hayabusa parts related to rider contact points
	print("\n=== CONTACT POINT INSPECTION ===")
	var root_node = bike.visual_wrapper.get_node("HayabusaMesh/Sketchfab_model/Suzuki Hayabusa_fbx/RootNode/bike_suzuki_hayabusa")
	for child in root_node.get_children():
		var w_pos = child.global_position
		var b_pos = bike.to_local(w_pos)
		print("  Hayabusa part: %-26s -> Local to bike: %s" % [child.name, b_pos])
	
	quit(0)
