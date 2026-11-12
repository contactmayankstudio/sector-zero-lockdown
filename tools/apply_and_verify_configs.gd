@tool
extends SceneTree

# Test proposed weapon configs on Player camera view
var proposed_configs = [
	{
		"id": "negev_ng7", 
		"path": "res://resources/weapons/negev_ng7.tres", 
		"model": "res://scenes/weapons/models/negev_ng7.scn",
		"offset": Vector3(-0.02, -0.05, 0.0),
		"rot": Vector3(0.0, 90.0, 0.0),
		"scale": Vector3(0.048, 0.048, 0.048)
	},
	{
		"id": "p90", 
		"path": "res://resources/weapons/p90.tres", 
		"model": "res://scenes/weapons/models/p90.scn",
		"offset": Vector3(-0.02, -0.02, 0.0),
		"rot": Vector3(0.0, 90.0, 0.0),
		"scale": Vector3(0.50, 0.50, 0.50)
	},
	{
		"id": "ak74_bayonet", 
		"path": "res://resources/weapons/ak74_bayonet.tres", 
		"model": "res://scenes/weapons/models/ak74_bayonet.scn",
		"offset": Vector3(-0.02, -0.10, 0.15),
		"rot": Vector3(-90.0, 0.0, 0.0),
		"scale": Vector3(0.35, 0.35, 0.35)
	},
	{
		"id": "akx_scifi", 
		"path": "res://resources/weapons/akx_scifi.tres", 
		"model": "res://scenes/weapons/models/akx_scifi.scn",
		"offset": Vector3(-0.02, -0.15, 0.18),
		"rot": Vector3(90.0, 0.0, 0.0),
		"scale": Vector3(0.80, 0.80, 0.80)
	},
	{
		"id": "n7_rifle", 
		"path": "res://resources/weapons/n7_rifle.tres", 
		"model": "res://scenes/weapons/models/n7_rifle.scn",
		"offset": Vector3(-0.02, -0.05, 0.10),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(0.044, 0.044, 0.044)
	},
	{
		"id": "car_smg", 
		"path": "res://resources/weapons/car_smg.tres", 
		"model": "res://scenes/weapons/models/car_smg.scn",
		"offset": Vector3(-0.02, -0.08, 0.05),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(0.020, 0.020, 0.020)
	},
	{
		"id": "grenade_mk2", 
		"path": "res://resources/weapons/grenade_mk2.tres", 
		"model": "res://scenes/weapons/models/grenade_mk2.scn",
		"offset": Vector3(-0.03, -0.02, 0.0),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(1.2, 1.2, 1.2)
	},
	{
		"id": "primordium_vandal", 
		"path": "res://resources/weapons/primordium_vandal.tres", 
		"model": "res://scenes/weapons/models/primordium_vandal.scn",
		"offset": Vector3(-0.02, -0.02, 0.0),
		"rot": Vector3(-180.0, 0.0, 0.0),
		"scale": Vector3(0.70, 0.70, 0.70)
	},
	{
		"id": "prowler_smg", 
		"path": "res://resources/weapons/prowler_smg.tres", 
		"model": "res://scenes/weapons/models/prowler_smg.scn",
		"offset": Vector3(-0.02, -0.05, 0.05),
		"rot": Vector3(-180.0, 0.0, 0.0),
		"scale": Vector3(0.031, 0.031, 0.031)
	},
	{
		"id": "ray_gun_cod", 
		"path": "res://resources/weapons/ray_gun_cod.tres", 
		"model": "res://scenes/weapons/models/ray_gun_cod.scn",
		"offset": Vector3(-0.02, -0.05, 0.02),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(0.031, 0.031, 0.031)
	},
	{
		"id": "plasma_gun", 
		"path": "res://resources/weapons/plasma_gun.tres", 
		"model": "res://scenes/weapons/models/plasma_gun.scn",
		"offset": Vector3(-0.02, -0.05, 0.05),
		"rot": Vector3(0.0, 180.0, 90.0),
		"scale": Vector3(0.070, 0.070, 0.070)
	},
	{
		"id": "rocket_launcher", 
		"path": "res://resources/weapons/rocket_launcher.tres", 
		"model": "res://scenes/weapons/models/rocket_launcher.scn",
		"offset": Vector3(-0.05, -0.05, -0.05),
		"rot": Vector3(0.0, 90.0, 0.0),
		"scale": Vector3(0.88, 0.88, 0.88)
	},
	{
		"id": "pestilence_handgun", 
		"path": "res://resources/weapons/pestilence_handgun.tres", 
		"model": "res://scenes/weapons/models/pestilence_handgun.scn",
		"offset": Vector3(-0.02, -0.02, 0.0),
		"rot": Vector3(0.0, 0.0, 90.0),
		"scale": Vector3(0.038, 0.038, 0.038)
	},
	{
		"id": "arcade_gun", 
		"path": "res://resources/weapons/arcade_gun.tres", 
		"model": "res://scenes/weapons/models/arcade_gun.scn",
		"offset": Vector3(-0.02, -0.02, 0.0),
		"rot": Vector3(90.0, 90.0, 0.0),
		"scale": Vector3(0.095, 0.095, 0.095)
	},
	{
		"id": "retro_ray_gun", 
		"path": "res://resources/weapons/retro_ray_gun.tres", 
		"model": "res://scenes/weapons/models/retro_ray_gun.scn",
		"offset": Vector3(-0.02, -0.15, 0.0),
		"rot": Vector3(0.0, 0.0, 0.0),
		"scale": Vector3(0.052, 0.052, 0.052)
	},
	{
		"id": "scifi_battle_rifle", 
		"path": "res://resources/weapons/scifi_battle_rifle.tres", 
		"model": "res://scenes/weapons/models/scifi_battle_rifle.scn",
		"offset": Vector3(-0.02, -0.05, 0.0),
		"rot": Vector3(0.0, 90.0, 90.0),
		"scale": Vector3(0.029, 0.029, 0.029)
	},
	{
		"id": "prowl_blaster", 
		"path": "res://resources/weapons/prowl_blaster.tres", 
		"model": "res://scenes/weapons/models/prowl_blaster.scn",
		"offset": Vector3(-0.02, -0.02, 0.0),
		"rot": Vector3(90.0, 0.0, 0.0),
		"scale": Vector3(0.52, 0.52, 0.52)
	},
	{
		"id": "vaccinator_energy", 
		"path": "res://resources/weapons/vaccinator_energy.tres", 
		"model": "res://scenes/weapons/models/vaccinator_energy.scn",
		"offset": Vector3(-0.02, -0.05, 0.0),
		"rot": Vector3(90.0, 0.0, 0.0),
		"scale": Vector3(0.0093, 0.0093, 0.0093)
	},
	{
		"id": "axon_cannon", 
		"path": "res://resources/weapons/axon_cannon.tres", 
		"model": "res://scenes/weapons/models/axon_cannon.scn",
		"offset": Vector3(-0.02, -0.15, 0.0),
		"rot": Vector3(0.0, -90.0, 0.0),
		"scale": Vector3(0.039, 0.039, 0.039)
	}
]

func _init():
	var player_scn = load("res://scenes/player/Player.tscn")
	var player = player_scn.instantiate()
	# Override weapon_configs on player
	player.set("weapon_configs", proposed_configs)
	root.add_child(player)
	
	if not player.is_node_ready():
		await player.ready
	for f in range(5):
		await process_frame
		
	var cam: Camera3D = player.get_node("Camera3D")
	var wm: Node3D = cam.get_node("WeaponManager")
	
	print("\n================ VERIFYING PROPOSED WEAPONS IN CAMERA VIEW ================")
	var weapons_list = player.get("weapons")
	for idx in range(weapons_list.size()):
		var w = weapons_list[idx]
		var wid = w.weapon_data.weapon_id if w.weapon_data else "unknown"
		var wname = w.weapon_data.display_name if w.weapon_data else "unknown"
		
		var model = w.get_node_or_null("WeaponModel")
		if not model:
			model = w.get_node_or_null("CustomModel")
		if not model and w.has_node("MeshInstance3D"):
			model = w.get_node("MeshInstance3D")
		if not model:
			print("No model for ", wid)
			continue
			
		var min_cam = Vector3(1e9, 1e9, 1e9)
		var max_cam = Vector3(-1e9, -1e9, -1e9)
		var stack = [model]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				var m = curr.mesh
				var cam_local = cam.global_transform.affine_inverse() * curr.global_transform
				for s in range(m.get_surface_count()):
					var arr = m.surface_get_arrays(s)
					if arr.size() > Mesh.ARRAY_VERTEX:
						for v in arr[Mesh.ARRAY_VERTEX]:
							var cv = cam_local * v
							min_cam.x = min(min_cam.x, cv.x)
							min_cam.y = min(min_cam.y, cv.y)
							min_cam.z = min(min_cam.z, cv.z)
							max_cam.x = max(max_cam.x, cv.x)
							max_cam.y = max(max_cam.y, cv.y)
							max_cam.z = max(max_cam.z, cv.z)
			for c in curr.get_children():
				stack.append(c)
		var span = max_cam - min_cam
		var center = (min_cam + max_cam) * 0.5
		var blocks_screen = max_cam.y > 0.02 or min_cam.x < 0.02
		print("[%02d] %-20s: Span=(X:%.3fm, Y:%.3fm, Z:%.3fm) CamPos=X:%.2f..%.2f, Y:%.2f..%.2f [Blocks: %s]" % [
			idx, wid, span.x, span.y, span.z, min_cam.x, max_cam.x, min_cam.y, max_cam.y, str(blocks_screen)
		])
	quit(0)
