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

	if lib.has_animation("RifleAimIdle"):
		lib.remove_animation("RifleAimIdle")

	var anim = Animation.new()
	anim.resource_name = "RifleAimIdle"
	anim.length = 2.0
	anim.loop_mode = Animation.LOOP_LINEAR

	var add_rot = func(bone_name: String, q0: Quaternion, q1: Quaternion):
		var track_idx = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(track_idx, "Character/Skeleton3D:" + bone_name)
		anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)
		anim.rotation_track_insert_key(track_idx, 0.0, q0)
		anim.rotation_track_insert_key(track_idx, 1.0, q1)
		anim.rotation_track_insert_key(track_idx, 2.0, q0)

	# PUBG Tactical Combat Aiming Stance:
	# 0. Hips: explicitly upright, eliminating upside-down FBX bone flip
	add_rot.call("mixamorig_Hips", Quaternion.IDENTITY, Quaternion.IDENTITY)

	# 1. Legs: planted firmly on ground in athletic shooting stance
	var l_up = Quaternion.from_euler(Vector3(deg_to_rad(-6.0), deg_to_rad(-8.0), deg_to_rad(4.0)))
	var r_up = Quaternion.from_euler(Vector3(deg_to_rad(-6.0), deg_to_rad(8.0), deg_to_rad(-4.0)))
	var knee_bend = Quaternion.from_euler(Vector3(deg_to_rad(12.0), 0.0, 0.0))
	var foot_flat = Quaternion.from_euler(Vector3(deg_to_rad(-6.0), 0.0, 0.0))
	add_rot.call("mixamorig_LeftUpLeg", l_up, l_up)
	add_rot.call("mixamorig_RightUpLeg", r_up, r_up)
	add_rot.call("mixamorig_LeftLeg", knee_bend, knee_bend)
	add_rot.call("mixamorig_RightLeg", knee_bend, knee_bend)
	add_rot.call("mixamorig_LeftFoot", foot_flat, foot_flat)
	add_rot.call("mixamorig_RightFoot", foot_flat, foot_flat)

	# Torso: angled ~18 deg in tactical weaver combat stance, subtle idle breathing
	var spine_q0 = Quaternion.from_euler(Vector3(deg_to_rad(6.0), deg_to_rad(-15.0), 0.0))
	var spine_q1 = Quaternion.from_euler(Vector3(deg_to_rad(7.5), deg_to_rad(-15.0), 0.0))
	add_rot.call("mixamorig_Spine", spine_q0, spine_q1)

	var spine1_q0 = Quaternion.from_euler(Vector3(deg_to_rad(5.0), deg_to_rad(-8.0), 0.0))
	var spine1_q1 = Quaternion.from_euler(Vector3(deg_to_rad(6.0), deg_to_rad(-8.0), 0.0))
	add_rot.call("mixamorig_Spine1", spine1_q0, spine1_q1)

	# Head: aligned looking straight down the rifle sights forward
	var head_q = Quaternion.from_euler(Vector3(deg_to_rad(-4.0), deg_to_rad(22.0), deg_to_rad(3.0)))
	add_rot.call("mixamorig_Head", head_q, head_q)

	# Right Arm: holding rifle grip at chest/shoulder, elbow down at ~45 deg
	# In Mixamo: RightArm rest is horizontal right (+58 deg in Z is pointing down)
	var r_arm_q = Quaternion.from_euler(Vector3(deg_to_rad(-25.0), deg_to_rad(45.0), deg_to_rad(40.0)))
	var r_forearm_q = Quaternion.from_euler(Vector3(deg_to_rad(75.0), deg_to_rad(-10.0), deg_to_rad(15.0)))
	var r_hand_q = Quaternion.from_euler(Vector3(deg_to_rad(10.0), 0.0, deg_to_rad(10.0)))
	add_rot.call("mixamorig_RightArm", r_arm_q, r_arm_q)
	add_rot.call("mixamorig_RightForeArm", r_forearm_q, r_forearm_q)
	add_rot.call("mixamorig_RightHand", r_hand_q, r_hand_q)

	# Left Arm: reaching forward and across chest to cup/grip the front handguard
	var l_arm_q = Quaternion.from_euler(Vector3(deg_to_rad(15.0), deg_to_rad(-35.0), deg_to_rad(38.0)))
	var l_forearm_q = Quaternion.from_euler(Vector3(deg_to_rad(-65.0), deg_to_rad(20.0), deg_to_rad(-15.0)))
	var l_hand_q = Quaternion.from_euler(Vector3(deg_to_rad(-10.0), 0.0, deg_to_rad(-10.0)))
	add_rot.call("mixamorig_LeftArm", l_arm_q, l_arm_q)
	add_rot.call("mixamorig_LeftForeArm", l_forearm_q, l_forearm_q)
	add_rot.call("mixamorig_LeftHand", l_hand_q, l_hand_q)

	lib.add_animation("RifleAimIdle", anim)
	print("Added RifleAimIdle animation successfully!")

	# Save packed scene
	var packed = PackedScene.new()
	for child in soldier.find_children("*"):
		child.owner = soldier
	packed.pack(soldier)
	var err = ResourceSaver.save(packed, "res://scenes/characters/RealSoldier.tscn")
	print("Saved RealSoldier.tscn status: ", err)

	quit(0)
