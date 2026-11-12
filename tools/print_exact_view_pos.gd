extends SceneTree

var frame_count: int = 0
var scene_inst: Node3D = null
var player: Node3D = null

func _process(delta: float):
	frame_count += 1
	if frame_count == 1:
		var s = load("res://scenes/environments/UrbanStreet.tscn") as PackedScene
		scene_inst = s.instantiate()
		root.add_child(scene_inst)
	elif frame_count == 10:
		player = scene_inst.find_child("Player", true, false)
		if player:
			for idx in range(player.weapons.size()):
				var w = player.weapons[idx]
				if w.weapon_data and w.weapon_data.weapon_id == "ak74u":
					player.switch_to_weapon(idx)
					break
			var cam = player.find_child("Camera3D", true, false)
			var wm = player.find_child("WeaponModel", true, false)
			var skel = player.find_child("Skeleton3D", true, false)
			if cam and skel:
				var b44_world = skel.global_transform * skel.get_bone_global_pose(44)
				var b44_cam_local = cam.global_transform.affine_inverse() * b44_world
				print("BONE 44 in CAMERA SPACE: ", b44_cam_local.origin)
				print("BONE 44 rotation in CAM: ", b44_cam_local.basis.get_euler())
				var cam_to_m = cam.global_transform.affine_inverse() * wm.global_transform
				print("WeaponModel in CAMERA SPACE: ", cam_to_m.origin)
				print("WeaponModel rot in CAM: ", cam_to_m.basis.get_euler())
		quit(0)
