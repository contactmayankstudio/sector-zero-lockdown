extends SceneTree

const WEAPONS_TO_BAKE = [
	{
		"id": "p90",
		"name": "FN P90 Tactical",
		"sub": "5.7x28mm High-Capacity PDW",
		"cat": "Submachine Gun",
		"glb": "res://assets/3d/weapons/p90.glb",
		"target_size": 0.55,
		"rot": Vector3(0, 0, 0),
		"damage": 22.0,
		"fire_rate": 0.065,
		"mag": 50,
		"reserve": 300,
		"reload": 2.8,
		"recoil": 0.6,
		"spread": 0.035,
		"sound": "rifle",
		"price": 2200
	},
	{
		"id": "ak74_bayonet",
		"name": "AK-74 Bayonet",
		"sub": "5.45x39mm Combat Assault Rifle",
		"cat": "Assault Rifle",
		"glb": "res://assets/3d/weapons/ak74_bayonet.glb",
		"target_size": 0.95,
		"rot": Vector3(0, 0, 0),
		"damage": 35.0,
		"fire_rate": 0.10,
		"mag": 30,
		"reserve": 180,
		"reload": 3.0,
		"recoil": 1.1,
		"spread": 0.025,
		"sound": "rifle",
		"price": 2800
	},
	{
		"id": "akx_scifi",
		"name": "AKX Cyber Carbine",
		"sub": "Advanced Plasma-Coated Kinetic Rifle",
		"cat": "Assault Rifle",
		"glb": "res://assets/3d/weapons/akx_scifi.glb",
		"target_size": 0.85,
		"rot": Vector3(0, 0, 0),
		"damage": 38.0,
		"fire_rate": 0.09,
		"mag": 35,
		"reserve": 210,
		"reload": 2.9,
		"recoil": 0.95,
		"spread": 0.02,
		"sound": "rifle",
		"price": 3500
	},
	{
		"id": "n7_rifle",
		"name": "N7 Valkyrie Carbine",
		"sub": "Precision Heavy Kinetic Battle Rifle",
		"cat": "Rifle",
		"glb": "res://assets/3d/weapons/n7_rifle.glb",
		"target_size": 0.82,
		"rot": Vector3(0, 0, 0),
		"damage": 42.0,
		"fire_rate": 0.12,
		"mag": 28,
		"reserve": 168,
		"reload": 3.2,
		"recoil": 1.2,
		"spread": 0.015,
		"sound": "rifle",
		"price": 4200
	},
	{
		"id": "car_smg",
		"name": "Frontier CAR SMG",
		"sub": "Dual-Feed Submachine Gun",
		"cat": "Submachine Gun",
		"glb": "res://assets/3d/weapons/car_smg.glb",
		"target_size": 0.65,
		"rot": Vector3(0, 0, 0),
		"damage": 26.0,
		"fire_rate": 0.07,
		"mag": 27,
		"reserve": 216,
		"reload": 2.2,
		"recoil": 0.8,
		"spread": 0.03,
		"sound": "rifle",
		"price": 3000
	},
	{
		"id": "grenade_mk2",
		"name": "MK2 Frag Grenade",
		"sub": "High-Explosive Shrapnel Grenade",
		"cat": "Explosive",
		"glb": "res://assets/3d/weapons/grenade_mk2.glb",
		"target_size": 0.18,
		"rot": Vector3(0, 0, 0),
		"damage": 250.0,
		"fire_rate": 1.0,
		"mag": 1,
		"reserve": 10,
		"reload": 1.5,
		"recoil": 0.2,
		"spread": 0.05,
		"sound": "rifle",
		"price": 1000
	}
]

func _init():
	print("Starting automated weapon bake process...")
	for def in WEAPONS_TO_BAKE:
		_bake_weapon(def)
	print("ALL WEAPONS BAKED SUCCESSFULLY!")
	quit(0)

func _bake_weapon(def: Dictionary):
	var w_id = def.id
	print("Processing: ", w_id, " from ", def.glb)
	
	# 1. Load GLB via GLTFDocument
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var err = gltf.append_from_file(def.glb, state)
	if err != OK:
		printerr("ERROR: Could not append GLB for ", w_id, " err=", err)
		return
		
	var node = gltf.generate_scene(state)
	if not node:
		printerr("ERROR: Could not generate scene for ", w_id)
		return
		
	# Compute transformed AABB to scale accurately
	var aabb = AABB()
	var first = true
	var meshes = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
		
	for mi in meshes:
		if mi.mesh:
			var m_aabb = mi.transform * mi.mesh.get_aabb()
			if first:
				aabb = m_aabb
				first = false
			else:
				aabb = aabb.merge(m_aabb)
				
	var root = Node3D.new()
	root.name = w_id
	root.add_child(node)
	node.owner = root
	
	# Auto-scaling to target size
	var max_dim = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
	if max_dim > 0.001:
		var s = def.target_size / max_dim
		node.scale = Vector3(s, s, s)
		# Center around origin
		var center = aabb.get_center()
		var rot_center = node.transform.basis * center
		node.position = -rot_center
	
	# Add MuzzleSocket
	var muzzle = Node3D.new()
	muzzle.name = "MuzzleSocket"
	muzzle.position = Vector3(0, 0, -def.target_size * 0.6)
	root.add_child(muzzle)
	muzzle.owner = root
	
	_set_owner_recursive(node, root)
	
	var scene_path = "res://scenes/weapons/models/" + w_id + ".tscn"
	var out_scene = PackedScene.new()
	out_scene.pack(root)
	var save_err = ResourceSaver.save(out_scene, scene_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved model scene: ", scene_path, " (Result: ", save_err, ")")
	
	# 2. Create WeaponData Resource (.tres)
	var wd = load("res://scripts/Weapons/WeaponData.gd").new()
	wd.weapon_id = w_id
	wd.display_name = def.name
	wd.base_damage = def.damage
	wd.base_fire_rate = def.fire_rate
	wd.base_mag_size = def.mag
	wd.base_reserve_ammo = def.reserve
	wd.base_reload_time = def.reload
	wd.recoil = def.recoil
	wd.spread = def.spread
	wd.range = 80.0
	wd.is_automatic = (def.fire_rate < 0.2)
	wd.sound_set = def.sound
	wd.unlock_price = def.price
	
	var res_path = "res://resources/weapons/" + w_id + ".tres"
	var r_err = ResourceSaver.save(wd, res_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved weapon resource: ", res_path, " (Result: ", r_err, ")")

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
