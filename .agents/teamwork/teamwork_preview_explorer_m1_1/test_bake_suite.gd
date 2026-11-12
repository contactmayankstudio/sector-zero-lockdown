@tool
extends SceneTree

func _init():
	print("--- TESTING FULL BAKE SUITE IN MEMORY ---")
	var scene_path = "res://scenes/environments/CityCarZombieArena.tscn"
	var packed = load(scene_path)
	if not packed:
		print("ERROR: Failed to load scene")
		quit(1)
		return
		
	var scene = packed.instantiate()
	var adv = scene.get_node_or_null("AdvancedTerrain")
	var real = scene.get_node_or_null("RealisticTerrain")
	var hp = scene.get_node_or_null("HighwayProps")
	
	# 1. Test newly created body: DirtPath_West_Physics
	var mi_dp = adv.get_node_or_null("DirtPath_West") as MeshInstance3D
	var sb_dp = StaticBody3D.new()
	sb_dp.name = "DirtPath_West_Physics"
	sb_dp.transform = mi_dp.transform
	adv.add_child(sb_dp)
	sb_dp.owner = scene
	
	var shape_dp = mi_dp.mesh.create_trimesh_shape()
	var cs_dp = CollisionShape3D.new()
	cs_dp.name = "CollisionShape3D"
	cs_dp.shape = shape_dp
	sb_dp.add_child(cs_dp)
	cs_dp.owner = scene
	
	# 2. Test sidewalk flush height and collider: SidewalkLeft
	var sb_sw = real.get_node_or_null("SidewalkLeft") as StaticBody3D
	var mi_sw = sb_sw.get_node_or_null("Mesh") as MeshInstance3D
	var orig_y = mi_sw.transform.origin.y
	mi_sw.transform.origin.y = 0.01
	print("SidewalkLeft Mesh Y changed from ", orig_y, " to ", mi_sw.transform.origin.y)
	
	var shape_sw = mi_sw.mesh.create_trimesh_shape()
	var cs_sw = CollisionShape3D.new()
	cs_sw.name = "CollisionShape3D"
	cs_sw.shape = shape_sw
	cs_sw.transform = mi_sw.transform # Match mesh transform!
	sb_sw.add_child(cs_sw)
	cs_sw.owner = scene
	
	# 3. Test barrier removal
	var barriers_removed = 0
	if hp:
		for i in range(8):
			var b = hp.get_node_or_null("Barrier_%d" % i)
			if b:
				b.free()
				barriers_removed += 1
	print("Barriers freed: ", barriers_removed)
	
	# 4. Pack scene
	var test_packed = PackedScene.new()
	var pack_err = test_packed.pack(scene)
	print("Pack error: ", pack_err)
	
	# 5. Re-instantiate and verify all 3 aspects
	var re_scene = test_packed.instantiate()
	var re_adv = re_scene.get_node_or_null("AdvancedTerrain")
	var re_real = re_scene.get_node_or_null("RealisticTerrain")
	var re_hp = re_scene.get_node_or_null("HighwayProps")
	
	# Check DirtPath_West_Physics
	var re_sb_dp = re_adv.get_node_or_null("DirtPath_West_Physics")
	assert(re_sb_dp != null, "DirtPath_West_Physics must exist in packed scene")
	var re_cs_dp = re_sb_dp.get_node_or_null("CollisionShape3D")
	assert(re_cs_dp != null, "CollisionShape3D must exist in DirtPath_West_Physics")
	print("✓ Verified DirtPath_West_Physics created and persisted with CollisionShape3D!")
	
	# Check SidewalkLeft
	var re_sb_sw = re_real.get_node_or_null("SidewalkLeft")
	var re_mi_sw = re_sb_sw.get_node_or_null("Mesh") as MeshInstance3D
	assert(absf(re_mi_sw.transform.origin.y - 0.01) < 0.001, "SidewalkLeft Mesh Y must be 0.01")
	var re_cs_sw = re_sb_sw.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert(re_cs_sw != null, "CollisionShape3D must exist in SidewalkLeft")
	assert(absf(re_cs_sw.transform.origin.y - 0.01) < 0.001, "CollisionShape3D transform Y must match 0.01")
	assert(absf(re_cs_sw.transform.origin.x - (-12.25)) < 0.001, "CollisionShape3D transform X must match -12.25")
	print("✓ Verified SidewalkLeft Mesh and CollisionShape3D flush at Y=0.01, X=-12.25!")
	
	# Check barriers
	var re_barriers_found = 0
	if re_hp:
		for i in range(8):
			if re_hp.get_node_or_null("Barrier_%d" % i) != null:
				re_barriers_found += 1
	assert(re_barriers_found == 0, "All Barrier_0 to Barrier_7 must be removed from packed scene")
	print("✓ Verified all 8 barriers removed from PackedScene!")
	
	print("\nALL VERIFICATIONS PASSED IN MEMORY!")
	
	scene.queue_free()
	re_scene.queue_free()
	quit(0)
