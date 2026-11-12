@tool
extends SceneTree

func _init():
	print("--- RE-BAKING CLEAN SCARY ZOMBIE (SCALE 1.0 = 1.89M, FACING -Z) ---")
	
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
	
	scary_ap.root_node = scary_ap.get_path_to(skel)
	
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
	
	# Position scale factor:
	# vitruvian hips rest pose: Y = 0.995591 (meters)
	# scary zombie hips rest pose: Y = 114.4742 (centimeters)
	var pos_scale_factor = 114.4742 / 0.995591 # ~114.98115
	print("Applying position scale factor: ", pos_scale_factor)
	
	for target_name in anim_names:
		var src_name = anim_names[target_name]
		if not source_ap.has_animation(src_name):
			continue
		var orig_anim: Animation = source_ap.get_animation(src_name)
		var new_anim: Animation = orig_anim.duplicate()
		
		for t in range(new_anim.get_track_count()):
			var p = new_anim.track_get_path(t)
			var bone_sub = p.get_subname(0)
			if bone_sub in bone_map:
				var target_bone = bone_map[bone_sub]
				new_anim.track_set_path(t, NodePath(":" + target_bone))
			else:
				new_anim.track_set_path(t, NodePath(":" + bone_sub))
				
			# Scale position tracks from meters to centimeters
			if new_anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
				for k in range(new_anim.track_get_key_count(t)):
					var val: Vector3 = new_anim.track_get_key_value(t, k)
					new_anim.track_set_key_value(t, k, val * pos_scale_factor)
				
		if target_name in ["walk", "idle"]:
			new_anim.loop_mode = Animation.LOOP_LINEAR
			
		if default_lib.has_animation(target_name):
			default_lib.remove_animation(target_name)
		default_lib.add_animation(target_name, new_anim)
	
	# Wrap in standard root node
	var root_wrapper = Node3D.new()
	root_wrapper.name = "ZombieScaryModel"
	root_wrapper.scale = Vector3(1.0, 1.0, 1.0)
	root_wrapper.rotation = Vector3.ZERO
	
	# scary_node (Sketchfab_Scene) already has Whiteclown N Hallin_fbx.scale = 0.01!
	# So scary_node.scale MUST be (1.0, 1.0, 1.0) to have a 1.89m tall character!
	scary_node.scale = Vector3(1.0, 1.0, 1.0)
	# Rotate 180 degrees around Y so the front of the zombie faces -Z (Godot forward)
	scary_node.rotation = Vector3(0, PI, 0)
	scary_node.position = Vector3.ZERO
	
	root_wrapper.add_child(scary_node)
	scary_node.owner = root_wrapper
	_set_owner_recursive(scary_node, root_wrapper)
	
	var packed = PackedScene.new()
	packed.pack(root_wrapper)
	var save_err = ResourceSaver.save(packed, "res://scenes/zombies/models/zombie_scary.scn", ResourceSaver.FLAG_COMPRESS)
	print("Saved clean zombie_scary.scn: ", save_err)
	
	vit_scene.free()
	root_wrapper.free()
	print("--- CLEAN REBAKE COMPLETE ---")
	quit(0)

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
