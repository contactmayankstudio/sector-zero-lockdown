@tool
extends SceneTree

# Test exact Basis application in Player camera view
var calibrated_configs = [
	{
		"id": "negev_ng7", 
		"path": "res://resources/weapons/negev_ng7.tres", 
		"model": "res://scenes/weapons/models/negev_ng7.scn",
		"basis": Basis(Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0)),
		"scale": Vector3(0.91, 0.91, 0.91),
		"offset": Vector3(-0.02, -0.05, 0.0)
	},
	{
		"id": "p90", 
		"path": "res://resources/weapons/p90.tres", 
		"model": "res://scenes/weapons/models/p90.scn",
		"basis": Basis(Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0)),
		"scale": Vector3(0.70, 0.70, 0.70),
		"offset": Vector3(-0.02, -0.05, 0.0)
	},
	{
		"id": "ak74_bayonet", 
		"path": "res://resources/weapons/ak74_bayonet.tres", 
		"model": "res://scenes/weapons/models/ak74_bayonet.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0)),
		"scale": Vector3(0.34, 0.34, 0.34),
		"offset": Vector3(-0.02, -0.15, 0.15)
	},
	{
		"id": "akx_scifi", 
		"path": "res://resources/weapons/akx_scifi.tres", 
		"model": "res://scenes/weapons/models/akx_scifi.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0)),
		"scale": Vector3(0.80, 0.80, 0.80),
		"offset": Vector3(-0.02, -0.15, 0.18)
	},
	{
		"id": "n7_rifle", 
		"path": "res://resources/weapons/n7_rifle.tres", 
		"model": "res://scenes/weapons/models/n7_rifle.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)),
		"scale": Vector3(0.044, 0.044, 0.044),
		"offset": Vector3(-0.02, -0.05, 0.10)
	},
	{
		"id": "car_smg", 
		"path": "res://resources/weapons/car_smg.tres", 
		"model": "res://scenes/weapons/models/car_smg.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)),
		"scale": Vector3(0.023, 0.023, 0.023),
		"offset": Vector3(-0.02, -0.08, 0.05)
	},
	{
		"id": "grenade_mk2", 
		"path": "res://resources/weapons/grenade_mk2.tres", 
		"model": "res://scenes/weapons/models/grenade_mk2.scn",
		"basis": Basis(Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0)),
		"scale": Vector3(1.5, 1.5, 1.5),
		"offset": Vector3(-0.03, -0.02, 0.0)
	},
	{
		"id": "primordium_vandal", 
		"path": "res://resources/weapons/primordium_vandal.tres", 
		"model": "res://scenes/weapons/models/primordium_vandal.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)),
		"scale": Vector3(0.75, 0.75, 0.75),
		"offset": Vector3(-0.02, -0.02, 0.0)
	},
	{
		"id": "prowler_smg", 
		"path": "res://resources/weapons/prowler_smg.tres", 
		"model": "res://scenes/weapons/models/prowler_smg.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)),
		"scale": Vector3(0.034, 0.034, 0.034),
		"offset": Vector3(-0.02, -0.15, 0.05)
	},
	{
		"id": "ray_gun_cod", 
		"path": "res://resources/weapons/ray_gun_cod.tres", 
		"model": "res://scenes/weapons/models/ray_gun_cod.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)),
		"scale": Vector3(0.033, 0.033, 0.033),
		"offset": Vector3(-0.02, -0.05, 0.02)
	},
	{
		"id": "plasma_gun", 
		"path": "res://resources/weapons/plasma_gun.tres", 
		"model": "res://scenes/weapons/models/plasma_gun.scn",
		"basis": Basis(Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0)),
		"scale": Vector3(0.070, 0.070, 0.070),
		"offset": Vector3(-0.02, -0.05, 0.05)
	},
	{
		"id": "rocket_launcher", 
		"path": "res://resources/weapons/rocket_launcher.tres", 
		"model": "res://scenes/weapons/models/rocket_launcher.scn",
		"basis": Basis(Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0)),
		"scale": Vector3(0.88, 0.88, 0.88),
		"offset": Vector3(-0.05, -0.05, -0.05)
	},
	{
		"id": "pestilence_handgun", 
		"path": "res://resources/weapons/pestilence_handgun.tres", 
		"model": "res://scenes/weapons/models/pestilence_handgun.scn",
		"basis": Basis(Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0)),
		"scale": Vector3(0.038, 0.038, 0.038),
		"offset": Vector3(-0.02, -0.02, 0.0)
	},
	{
		"id": "arcade_gun", 
		"path": "res://resources/weapons/arcade_gun.tres", 
		"model": "res://scenes/weapons/models/arcade_gun.scn",
		"basis": Basis(Vector3(0.0, 0.0, -1.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, -1.0, 0.0)),
		"scale": Vector3(0.098, 0.098, 0.098),
		"offset": Vector3(-0.02, -0.02, 0.0)
	},
	{
		"id": "retro_ray_gun", 
		"path": "res://resources/weapons/retro_ray_gun.tres", 
		"model": "res://scenes/weapons/models/retro_ray_gun.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0)),
		"scale": Vector3(0.054, 0.054, 0.054),
		"offset": Vector3(-0.02, -0.15, 0.0)
	},
	{
		"id": "scifi_battle_rifle", 
		"path": "res://resources/weapons/scifi_battle_rifle.tres", 
		"model": "res://scenes/weapons/models/scifi_battle_rifle.scn",
		"basis": Basis(Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, -1.0), Vector3(-1.0, 0.0, 0.0)),
		"scale": Vector3(0.029, 0.029, 0.029),
		"offset": Vector3(-0.02, -0.05, 0.0)
	},
	{
		"id": "prowl_blaster", 
		"path": "res://resources/weapons/prowl_blaster.tres", 
		"model": "res://scenes/weapons/models/prowl_blaster.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0)),
		"scale": Vector3(0.52, 0.52, 0.52),
		"offset": Vector3(-0.02, -0.02, 0.0)
	},
	{
		"id": "vaccinator_energy", 
		"path": "res://resources/weapons/vaccinator_energy.tres", 
		"model": "res://scenes/weapons/models/vaccinator_energy.scn",
		"basis": Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0)),
		"scale": Vector3(0.0093, 0.0093, 0.0093),
		"offset": Vector3(-0.02, -0.05, 0.0)
	},
	{
		"id": "axon_cannon", 
		"path": "res://resources/weapons/axon_cannon.tres", 
		"model": "res://scenes/weapons/models/axon_cannon.scn",
		"basis": Basis(Vector3(0.0, 0.0, -1.0), Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0)),
		"scale": Vector3(0.041, 0.041, 0.041),
		"offset": Vector3(-0.02, -0.15, 0.0)
	}
]

func _init():
	var player_scn = load("res://scenes/player/Player.tscn")
	var player = player_scn.instantiate()
	root.add_child(player)
	
	if not player.is_node_ready():
		await player.ready
	for f in range(5):
		await process_frame
		
	var cam: Camera3D = player.get_node("Camera3D")
	var wm: Node3D = cam.get_node("WeaponManager")
	
	print("\n================ VERIFYING CALIBRATED BASIS IN FIRST PERSON VIEW ================")
	for cfg in calibrated_configs:
		var scn = load(cfg.model)
		var model_inst = scn.instantiate()
		model_inst.transform.basis = cfg.basis
		model_inst.scale = cfg.scale
		model_inst.position = cfg.offset
		wm.add_child(model_inst)
		
		var min_cam = Vector3(1e9, 1e9, 1e9)
		var max_cam = Vector3(-1e9, -1e9, -1e9)
		var stack = [model_inst]
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
		var blocks_screen = max_cam.y > 0.05 or min_cam.x < 0.02
		print("[CALIBRATED] %-20s: Span=(X:%.3fm, Y:%.3fm, Z:%.3fm) CamPos=X:%.2f..%.2f, Y:%.2f..%.2f [Blocks: %s]" % [
			cfg.id, span.x, span.y, span.z, min_cam.x, max_cam.x, min_cam.y, max_cam.y, str(blocks_screen)
		])
		model_inst.queue_free()
	quit(0)
