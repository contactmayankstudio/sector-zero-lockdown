extends SceneTree

func _init():
	var soldier_scene: PackedScene = load("res://scenes/characters/RealSoldier.tscn")
	var soldier = soldier_scene.instantiate()
	get_root().add_child(soldier)

	var anim_player: AnimationPlayer = soldier.find_child("AnimationPlayer", true, false)
	var lib: AnimationLibrary = anim_player.get_animation_library("")
	if not lib:
		lib = AnimationLibrary.new()
		anim_player.add_animation_library("", lib)

	if lib.has_animation("BikeRiding"):
		lib.remove_animation("BikeRiding")

	var anim = Animation.new()
	anim.resource_name = "BikeRiding"
	anim.length = 1.0
	anim.loop_mode = Animation.LOOP_LINEAR

	# Helper to add rotation track
	var add_rot = func(bone_name: String, quat: Quaternion):
		var track_idx = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(track_idx, "Character/Skeleton3D:" + bone_name)
		anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)
		anim.rotation_track_insert_key(track_idx, 0.0, quat)
		anim.rotation_track_insert_key(track_idx, 1.0, quat)

	# 1. Torso & Head: aggressive sportbike aerodynamic tuck
	add_rot.call("mixamorig_Hips", Quaternion.from_euler(Vector3(deg_to_rad(15.0), 0.0, 0.0)))
	add_rot.call("mixamorig_Spine", Quaternion.from_euler(Vector3(deg_to_rad(32.0), 0.0, 0.0)))
	add_rot.call("mixamorig_Spine1", Quaternion.from_euler(Vector3(deg_to_rad(18.0), 0.0, 0.0)))
	add_rot.call("mixamorig_Spine2", Quaternion.from_euler(Vector3(deg_to_rad(10.0), 0.0, 0.0)))
	add_rot.call("mixamorig_Neck", Quaternion.from_euler(Vector3(deg_to_rad(-15.0), 0.0, 0.0)))
	add_rot.call("mixamorig_Head", Quaternion.from_euler(Vector3(deg_to_rad(-25.0), 0.0, 0.0)))

	# 2. Legs: high-mount sportbike footpegs (knees bent, feet tucked)
	add_rot.call("mixamorig_LeftUpLeg", Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(-16.0), deg_to_rad(16.0))))
	add_rot.call("mixamorig_LeftLeg", Quaternion.from_euler(Vector3(deg_to_rad(118.0), 0.0, 0.0)))
	add_rot.call("mixamorig_LeftFoot", Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0.0, 0.0)))

	add_rot.call("mixamorig_RightUpLeg", Quaternion.from_euler(Vector3(deg_to_rad(-68.0), deg_to_rad(16.0), deg_to_rad(-16.0))))
	add_rot.call("mixamorig_RightLeg", Quaternion.from_euler(Vector3(deg_to_rad(118.0), 0.0, 0.0)))
	add_rot.call("mixamorig_RightFoot", Quaternion.from_euler(Vector3(deg_to_rad(-22.0), 0.0, 0.0)))

	# 3. Arms & Hands: reaching forward and down to Hayabusa clip-on handlebars
	# Left Arm, ForeArm & Hand
	var l_arm_q = Quaternion.from_euler(Vector3(deg_to_rad(-25.0), deg_to_rad(-40.0), deg_to_rad(45.0)))
	var l_forearm_q = Quaternion.from_euler(Vector3(deg_to_rad(-60.0), deg_to_rad(12.0), 0.0))
	var l_hand_q = Quaternion.from_euler(Vector3(deg_to_rad(-15.0), 0.0, deg_to_rad(15.0)))
	add_rot.call("mixamorig_LeftArm", l_arm_q)
	add_rot.call("mixamorig_LeftForeArm", l_forearm_q)
	add_rot.call("mixamorig_LeftHand", l_hand_q)

	# Right Arm, ForeArm & Hand (symmetric to left arm)
	var r_arm_q = Quaternion.from_euler(Vector3(deg_to_rad(25.0), deg_to_rad(40.0), deg_to_rad(45.0)))
	var r_forearm_q = Quaternion.from_euler(Vector3(deg_to_rad(60.0), deg_to_rad(-12.0), 0.0))
	var r_hand_q = Quaternion.from_euler(Vector3(deg_to_rad(15.0), 0.0, deg_to_rad(15.0)))
	add_rot.call("mixamorig_RightArm", r_arm_q)
	add_rot.call("mixamorig_RightForeArm", r_forearm_q)
	add_rot.call("mixamorig_RightHand", r_hand_q)

	lib.add_animation("BikeRiding", anim)
	print("Added BikeRiding animation with ", anim.get_track_count(), " tracks!")

	# Save packed scene
	var packed = PackedScene.new()
	for child in soldier.find_children("*"):
		child.owner = soldier
	packed.pack(soldier)
	var err = ResourceSaver.save(packed, "res://scenes/characters/RealSoldier.tscn")
	print("Saved RealSoldier.tscn status: ", err)

	quit(0)
