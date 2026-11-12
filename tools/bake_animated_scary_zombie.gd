extends SceneTree

func _init():
	print("--- BAKING FULLY ANIMATED SCARY ZOMBIE V3 (PERFECT SKELETON ROOT) ---")
	
	# 1. Load animations from vitruvian_full_rigged.glb
	var doc_anim = GLTFDocument.new()
	var state_anim = GLTFState.new()
	doc_anim.append_from_file(ProjectSettings.globalize_path("res://assets/external/animations/vitruvian_full_rigged.glb"), state_anim)
	var vit_scene = doc_anim.generate_scene(state_anim)
	var source_ap: AnimationPlayer = vit_scene.find_children("*", "AnimationPlayer", true, false)[0]
	
	# 2. Load scary zombie model
	var doc_zombie = GLTFDocument.new()
	var state_zombie = GLTFState.new()
	var err = doc_zombie.append_from_file("/home/am/Downloads/scary_zombie_pack.glb", state_zombie)
	if err != OK:
		print("Failed loading scary_zombie_pack.glb: ", err)
		quit(1)
		return
	var scary_node = doc_zombie.generate_scene(state_zombie)
	var skel: Skeleton3D = scary_node.find_children("*", "Skeleton3D", true, false)[0]
	
	# Build bone map: vitruvian bone name -> scary bone name
	var bone_map = {}
	for bi in range(skel.get_bone_count()):
		var s_name = skel.get_bone_name(bi)
		var parts = s_name.split("_")
		var base_name = s_name
		if parts.size() >= 2 and parts[-1].is_valid_int():
			base_name = s_name.substr(0, s_name.rfind("_"))
		bone_map[base_name] = s_name
		bone_map[base_name.replace("mixamorig_", "mixamorig:")] = s_name
	
	var scary_ap: AnimationPlayer = scary_node.find_child("*AnimationPlayer*", true, false)
	if not scary_ap:
		scary_ap = AnimationPlayer.new()
		scary_ap.name = "AnimationPlayer"
		scary_node.add_child(scary_ap)
	
	# Point AP.root_node directly to the Skeleton3D!
	scary_ap.root_node = scary_ap.get_path_to(skel)
	print("Set AP root_node to: ", scary_ap.root_node)
	
	var default_lib = scary_ap.get_animation_library("")
	if not default_lib:
		default_lib = AnimationLibrary.new()
		scary_ap.add_animation_library("", default_lib)
	
	var anim_names = {
		"walk": "Walk",
		"idle": "Idle",
		"attack": "Attack_mixamo_vitruvian",
		"death": "Death_mixamo_vitruvian",
		"hit_react": "HitReaction_mixamo_vitruvian",
		"stagger": "HitReaction_mixamo_vitruvian"
	}
	
	for target_name in anim_names:
		var src_name = anim_names[target_name]
		if not source_ap.has_animation(src_name):
			print("Source missing: ", src_name)
			continue
		var orig_anim: Animation = source_ap.get_animation(src_name)
		var new_anim: Animation = orig_anim.duplicate()
		
		# Retarget track paths: since root_node IS Skeleton3D, bone path is just ":bone_name"
		for t in range(new_anim.get_track_count()):
			var p = new_anim.track_get_path(t)
			var bone_sub = p.get_subname(0)
			if bone_sub in bone_map:
				var target_bone = bone_map[bone_sub]
				new_anim.track_set_path(t, NodePath(":" + target_bone))
			else:
				new_anim.track_set_path(t, NodePath(":" + bone_sub))
				
		if target_name in ["walk", "idle"]:
			new_anim.loop_mode = Animation.LOOP_LINEAR
			
		if default_lib.has_animation(target_name):
			default_lib.remove_animation(target_name)
		default_lib.add_animation(target_name, new_anim)
		print("Successfully retargeted: ", target_name, " (tracks: ", new_anim.get_track_count(), ")")
	
	# Wrap in standard root node
	var root_wrapper = Node3D.new()
	root_wrapper.name = "ZombieScaryModel"
	
	# Scale from cm to meters (0.01)
	scary_node.scale = Vector3(0.01, 0.01, 0.01)
	scary_node.rotation.y = PI
	
	root_wrapper.add_child(scary_node)
	scary_node.owner = root_wrapper
	_set_owner_recursive(scary_node, root_wrapper)
	
	var packed = PackedScene.new()
	packed.pack(root_wrapper)
	var save_err = ResourceSaver.save(packed, "res://scenes/zombies/models/zombie_scary.scn", ResourceSaver.FLAG_COMPRESS)
	print("Saved animated zombie_scary.scn: ", save_err)
	
	# Test playback without warnings
	var test_inst = packed.instantiate()
	root.add_child(test_inst)
	var test_ap: AnimationPlayer = test_inst.find_children("*", "AnimationPlayer", true, false)[0]
	test_ap.play("walk")
	print("Test play walk: current=", test_ap.current_animation)
	test_inst.free()
	
	vit_scene.free()
	root_wrapper.free()
	print("--- DONE ---")
	quit(0)

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
