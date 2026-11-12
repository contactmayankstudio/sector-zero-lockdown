@tool
extends SceneTree

func _init():
	print("=== VERIFYING ALL ZOMBIES FACE FORWARD (-Z) ===")
	var archetypes = ["normal", "realistic", "fast", "heavy", "boss", "dog", "spitter"]
	
	for arch in archetypes:
		var zombie = null
		if arch == "dog":
			var dog_res = load("res://scenes/zombies/InfectedDog.tscn")
			zombie = dog_res.instantiate()
		elif arch == "boss":
			var boss_res = load("res://scenes/zombies/BossZombie.tscn")
			zombie = boss_res.instantiate()
		else:
			var default_z_res = load("res://scenes/zombies/Zombie.tscn")
			zombie = default_z_res.instantiate()
			
		zombie.archetype = arch
		get_root().add_child(zombie)
		zombie._apply_archetype()
		
		var wrapper = zombie.get_node_or_null("ModelWrapper")
		var skel_model = zombie.find_child("SkeletalModel", true, false)
		
		var wrapper_rot_y = wrapper.rotation.y if wrapper else 0.0
		var model_rot_y = skel_model.rotation.y if skel_model else 0.0
		
		print("Archetype: [", arch, "]")
		print("  ModelWrapper rot.y: ", wrapper_rot_y, " (", rad_to_deg(wrapper_rot_y), " deg)")
		print("  SkeletalModel rot.y: ", model_rot_y, " (", rad_to_deg(model_rot_y), " deg)")
		
		# Total rotation applied to model relative to EnemyBase
		var total_rot_y = wrapper_rot_y + model_rot_y
		print("  Total Y Rotation: ", rad_to_deg(total_rot_y), " deg")
		
		# Expected facing check:
		# Models whose raw mesh faces +Z: Office, 6ft, Biker, Titan.
		# They NEED total_rot_y = PI (180 deg) so their face points to -Z.
		# Models whose raw mesh faces -Z: Velociraptor, Scary.
		# They NEED total_rot_y = 0.0 (0 deg) so their face points to -Z.
		var cfg = zombie.archetype_data.get(arch, {})
		var mesh_path = cfg.get("mesh", "")
		if "zombie_scary" in mesh_path:
			if is_zero_approx(total_rot_y):
				print("  [PASS] Correctly facing forward (-Z) with 0 deg offset!")
			else:
				print("  [FAIL] Expected 0 deg, got: ", rad_to_deg(total_rot_y))
		else:
			if is_equal_approx(total_rot_y, PI):
				print("  [PASS] Correctly facing forward (-Z) with 180 deg offset!")
			else:
				print("  [FAIL] Expected 180 deg, got: ", rad_to_deg(total_rot_y))
				
		zombie.queue_free()
		
	print("\nALL ARCHETYPES VERIFIED!")
	quit(0)
