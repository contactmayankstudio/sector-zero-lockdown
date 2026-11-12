extends SceneTree

func _init():
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	root_node.add_child(bike)
	
	create_timer(0.05).timeout.connect(func():
		_solve_and_test(bike)
	)

func _solve_and_test(bike: Node3D):
	print("=== SOLVING EXACT RIDER POSTURE ===")
	var rider = bike.rider_soldier
	var skel: Skeleton3D = rider.find_child("Skeleton3D", true, false)
	var anim_player: AnimationPlayer = rider.find_child("AnimationPlayer", true, false)
	
	# Stop default animation
	anim_player.stop()
	anim_player.active = false
	
	# Handlebar targets in bike space:
	# Steer node is at (-0, 0.890936, -0.433675)
	# Left clip-on grip: X = 0.22, Y = 0.87, Z = -0.38
	# Right clip-on grip: X = -0.22, Y = 0.87, Z = -0.38
	# Seat target for hips: X = 0.0, Y = 0.64, Z = -0.05
	# Left footpeg: X = 0.20, Y = 0.38, Z = 0.08
	# Right footpeg: X = -0.20, Y = 0.38, Z = 0.08
	
	# If rider is at rider.position:
	# rider.position = Vector3(0.0, y_offset, z_offset)
	# Let's test what rider.position puts hips at Y = 0.64, Z = -0.05
	
	# In rest pose, where is Hips relative to rider origin?
	skel.clear_bones_global_pose_override()
	for i in range(skel.get_bone_count()):
		skel.reset_bone_pose(i)
	
	var hips_idx = skel.find_bone("mixamorig_Hips")
	var hips_rest_global = skel.global_transform * skel.get_bone_global_pose(hips_idx).origin
	var hips_bike_rest = bike.to_local(hips_rest_global)
	print("Rest hips in bike space (with current rider.position %s): %s" % [rider.position, hips_bike_rest])
	
	# Target hips in bike space is (0, 0.64, -0.05)
	var delta_hips = Vector3(0.0, 0.64, -0.05) - hips_bike_rest
	rider.position += delta_hips
	print("Adjusted rider.position to: ", rider.position)
	
	# Now re-check hips:
	var hips_global_now = skel.global_transform * skel.get_bone_global_pose(hips_idx).origin
	var hips_bike_now = bike.to_local(hips_global_now)
	print("New hips in bike space: ", hips_bike_now)
	
	# Now let's test spine lean angles:
	# Spine leaned forward by ~35-45 deg tucks the chest onto the gas tank
	# Let's see where Spine2 ends up
	var spine_idx = skel.find_bone("mixamorig_Spine")
	var spine1_idx = skel.find_bone("mixamorig_Spine1")
	var spine2_idx = skel.find_bone("mixamorig_Spine2")
	
	# In rest, local Y is up, local X is right, local Z is forward/back
	# Let's check which axis bends spine forward
	# Let's print Euler axes of Spine rest
	print("Spine rest euler: ", skel.get_bone_rest(spine_idx).basis.get_euler())
	
	quit(0)
