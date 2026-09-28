class_name WeaponManager
extends Node

# Canonical registry of all 10 weapons
const WEAPON_REGISTRY: Dictionary = {
	"negev_ng7": {
		"id": "negev_ng7",
		"display_name": "NG7 Heavy LMG",
		"subtitle": "7.62mm Sustained Fire Suppressive LMG",
		"category": "Machine Gun",
		"resource_path": "res://resources/weapons/negev_ng7.tres",
		"scene_path": "res://scenes/weapons/models/negev_ng7.scn",
		"model_path": "res://scenes/weapons/models/negev_ng7.scn",
		"unlock_price": 0,
		"default_unlocked": true,
		"aliases": ["negev", "lmg"]
	},
	"grenade_mk2": {
		"id": "grenade_mk2",
		"display_name": "MK2 Frag Grenade",
		"subtitle": "High-Explosive Shrapnel Grenade",
		"category": "Explosive",
		"resource_path": "res://resources/weapons/grenade_mk2.tres",
		"scene_path": "res://scenes/weapons/models/grenade_mk2.scn",
		"model_path": "res://scenes/weapons/models/grenade_mk2.scn",
		"unlock_price": 1800,
		"default_unlocked": false,
		"aliases": ["grenade"]
	},
	"car_smg": {
		"id": "car_smg",
		"display_name": "Frontier SMG-9",
		"subtitle": "Dual-Feed High Cyclic SMG",
		"category": "Submachine Gun",
		"resource_path": "res://resources/weapons/car_smg.tres",
		"scene_path": "res://scenes/weapons/models/car_smg.scn",
		"model_path": "res://scenes/weapons/models/car_smg.scn",
		"unlock_price": 2800,
		"default_unlocked": false,
		"aliases": ["car"]
	},
	"pestilence_handgun": {
		"id": "pestilence_handgun",
		"display_name": "Pestilence Mag-Pistol",
		"subtitle": "Heavy Caliber Bio-Magnetic Handgun",
		"category": "Pistol",
		"resource_path": "res://resources/weapons/pestilence_handgun.tres",
		"scene_path": "res://scenes/weapons/models/pestilence_handgun.scn",
		"model_path": "res://scenes/weapons/models/pestilence_handgun.scn",
		"unlock_price": 4000,
		"default_unlocked": false,
		"aliases": ["pestilence"]
	},
	"akx_scifi": {
		"id": "akx_scifi",
		"display_name": "AKX Cyber Carbine",
		"subtitle": "Advanced Plasma-Coated Kinetic Rifle",
		"category": "Assault Rifle",
		"resource_path": "res://resources/weapons/akx_scifi.tres",
		"scene_path": "res://scenes/weapons/models/akx_scifi.scn",
		"model_path": "res://scenes/weapons/models/akx_scifi.scn",
		"unlock_price": 5500,
		"default_unlocked": false,
		"aliases": ["akx"]
	},
	"prowler_smg": {
		"id": "prowler_smg",
		"display_name": "Prowler Reactive SMG",
		"subtitle": "Liquid-Cooled High Cyclic Burst SMG",
		"category": "Submachine Gun",
		"resource_path": "res://resources/weapons/prowler_smg.tres",
		"scene_path": "res://scenes/weapons/models/prowler_smg.scn",
		"model_path": "res://scenes/weapons/models/prowler_smg.scn",
		"unlock_price": 7500,
		"default_unlocked": false,
		"aliases": ["prowler"]
	},
	"primordium_vandal": {
		"id": "primordium_vandal",
		"display_name": "Primordium Vandal",
		"subtitle": "Golden Precision Kinetic Assault Rifle",
		"category": "Assault Rifle",
		"resource_path": "res://resources/weapons/primordium_vandal.tres",
		"scene_path": "res://scenes/weapons/models/primordium_vandal.scn",
		"model_path": "res://scenes/weapons/models/primordium_vandal.scn",
		"unlock_price": 10000,
		"default_unlocked": false,
		"aliases": ["vandal"]
	},
	"arcade_gun": {
		"id": "arcade_gun",
		"display_name": "Retro Arcade Blaster",
		"subtitle": "Classic Light-Gun Rapid Blaster",
		"category": "Pistol",
		"resource_path": "res://resources/weapons/arcade_gun.tres",
		"scene_path": "res://scenes/weapons/models/arcade_gun.scn",
		"model_path": "res://scenes/weapons/models/arcade_gun.scn",
		"unlock_price": 13000,
		"default_unlocked": false,
		"aliases": ["arcade"]
	},
	"prowl_blaster": {
		"id": "prowl_blaster",
		"display_name": "Prowl Cyber Blaster",
		"subtitle": "Compact Tactical Energy Sidearm",
		"category": "Pistol",
		"resource_path": "res://resources/weapons/prowl_blaster.tres",
		"scene_path": "res://scenes/weapons/models/prowl_blaster.scn",
		"model_path": "res://scenes/weapons/models/prowl_blaster.scn",
		"unlock_price": 16500,
		"default_unlocked": false,
		"aliases": ["prowl"]
	},
	"vaccinator_energy": {
		"id": "vaccinator_energy",
		"display_name": "Vaccinator Beam Rifle",
		"subtitle": "High-Tech Continuous Energy Weapon",
		"category": "Rifle",
		"resource_path": "res://resources/weapons/vaccinator_energy.tres",
		"scene_path": "res://scenes/weapons/models/vaccinator_energy.scn",
		"model_path": "res://scenes/weapons/models/vaccinator_energy.scn",
		"unlock_price": 20500,
		"default_unlocked": false,
		"aliases": ["vaccinator"]
	},
	"retro_ray_gun": {
		"id": "retro_ray_gun",
		"display_name": "Alien Disintegrator",
		"subtitle": "Retro-Futuristic Disintegration Ray",
		"category": "Special",
		"resource_path": "res://resources/weapons/retro_ray_gun.tres",
		"scene_path": "res://scenes/weapons/models/retro_ray_gun.scn",
		"model_path": "res://scenes/weapons/models/retro_ray_gun.scn",
		"unlock_price": 25000,
		"default_unlocked": false,
		"aliases": ["disintegrator"]
	},
	"ray_gun_cod": {
		"id": "ray_gun_cod",
		"display_name": "Wonder Ray Gun",
		"subtitle": "Alien Concentrated Energy Disintegrator",
		"category": "Special",
		"resource_path": "res://resources/weapons/ray_gun_cod.tres",
		"scene_path": "res://scenes/weapons/models/ray_gun_cod.scn",
		"model_path": "res://scenes/weapons/models/ray_gun_cod.scn",
		"unlock_price": 30000,
		"default_unlocked": false,
		"aliases": ["raygun", "ray_gun"]
	},
	"axon_cannon": {
		"id": "axon_cannon",
		"display_name": "Axon Heavy Blaster",
		"subtitle": "Devastating Ion-Particle Heavy Cannon",
		"category": "Special",
		"resource_path": "res://resources/weapons/axon_cannon.tres",
		"scene_path": "res://scenes/weapons/models/axon_cannon.scn",
		"model_path": "res://scenes/weapons/models/axon_cannon.scn",
		"unlock_price": 36000,
		"default_unlocked": false,
		"aliases": ["axon"]
	},
	"rocket_launcher": {
		"id": "rocket_launcher",
		"display_name": "Titan Rocket Launcher",
		"subtitle": "Anti-Armor High-Explosive Rocket Launcher",
		"category": "Explosive",
		"resource_path": "res://resources/weapons/rocket_launcher.tres",
		"scene_path": "res://scenes/weapons/models/rocket_launcher.scn",
		"model_path": "res://scenes/weapons/models/rocket_launcher.scn",
		"unlock_price": 45000,
		"default_unlocked": false,
		"aliases": ["rpg", "rocket"]
	}
}

# Alias resolution mapping
static func resolve_weapon_id(id: String) -> String:
	return id
static func get_all_weapon_ids() -> Array[String]:
	var arr: Array[String] = ["negev_ng7", "akx_scifi", "car_smg", "grenade_mk2", "primordium_vandal", "prowler_smg", "ray_gun_cod", "rocket_launcher", "pestilence_handgun", "arcade_gun", "retro_ray_gun", "prowl_blaster", "vaccinator_energy", "axon_cannon"]
	return arr
static func get_weapon_entry(id: String) -> Dictionary:
	var canonical = resolve_weapon_id(id)
	return WEAPON_REGISTRY.get(canonical, {})

static func get_weapon_data(id: String) -> WeaponData:
	var entry = get_weapon_entry(id)
	if entry.is_empty():
		return null
	var path = entry.get("resource_path", "")
	if ResourceLoader.exists(path):
		return load(path) as WeaponData
	return null

static func get_weapon_scene(id: String) -> PackedScene:
	var entry = get_weapon_entry(id)
	if entry.is_empty():
		return null
	var path = entry.get("scene_path", "")
	if ResourceLoader.exists(path):
		return load(path) as PackedScene
	return null

static func is_weapon_owned(id: String, save_mgr = null) -> bool:
	if not save_mgr:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root.has_node("SaveManager"):
			save_mgr = tree.root.get_node("SaveManager")
	if not save_mgr:
		var entry = get_weapon_entry(id)
		return entry.get("default_unlocked", false)
	
	var canonical = resolve_weapon_id(id)
	if save_mgr.has_method("is_weapon_owned"):
		return save_mgr.is_weapon_owned(canonical)
		
	var unlocked = save_mgr.data.get("unlocked_weapons", [])
	if canonical in unlocked:
		return true
	var entry = get_weapon_entry(canonical)
	for alias in entry.get("aliases", []):
		if alias in unlocked:
			return true
	return false

static func is_weapon_unlocked(id: String, save_mgr = null) -> bool:
	if not save_mgr:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root.has_node("SaveManager"):
			save_mgr = tree.root.get_node("SaveManager")
	if not save_mgr:
		var entry = get_weapon_entry(id)
		return entry.get("default_unlocked", false)
	
	var canonical = resolve_weapon_id(id)
	if save_mgr.has_method("is_weapon_unlocked"):
		return save_mgr.is_weapon_unlocked(canonical)
	return is_weapon_owned(id, save_mgr)

static func unlock_weapon(id: String, save_mgr = null) -> bool:
	if not save_mgr:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root.has_node("SaveManager"):
			save_mgr = tree.root.get_node("SaveManager")
	if not save_mgr:
		return false
		
	var canonical = resolve_weapon_id(id)
	var unlocked = save_mgr.data.get("unlocked_weapons", [])
	if not canonical in unlocked:
		unlocked.append(canonical)
		var entry = get_weapon_entry(canonical)
		for alias in entry.get("aliases", []):
			if not alias in unlocked:
				unlocked.append(alias)
		save_mgr.data["unlocked_weapons"] = unlocked
		save_mgr.save_game()
		return true
	return false

static func get_upgrade_levels(id: String, save_mgr = null) -> Dictionary:
	var defaults = {"damage": 0, "mag": 0, "reload": 0, "accuracy": 0}
	if not save_mgr:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root.has_node("SaveManager"):
			save_mgr = tree.root.get_node("SaveManager")
	if not save_mgr:
		return defaults
		
	var canonical = resolve_weapon_id(id)
	var upgrades = save_mgr.data.get("weapon_upgrades", {})
	if upgrades.has(canonical):
		var u = upgrades[canonical]
		for k in defaults.keys():
			if not u.has(k):
				u[k] = 0
		return u
	# Check alias
	var entry = get_weapon_entry(canonical)
	for alias in entry.get("aliases", []):
		if upgrades.has(alias):
			var u = upgrades[alias]
			for k in defaults.keys():
				if not u.has(k):
					u[k] = 0
			return u
	return defaults

static func get_upgrade_level(id: String, stat_name: String, save_mgr = null) -> int:
	var lvls = get_upgrade_levels(id, save_mgr)
	return lvls.get(stat_name, 0)

static func get_upgrade_cost(id: String, stat_name: String, save_mgr = null) -> int:
	var cur_lvl = get_upgrade_level(id, stat_name, save_mgr)
	var wdata = get_weapon_data(id)
	if not wdata:
		return -1
	return wdata.get_upgrade_cost(stat_name, cur_lvl)

static func purchase_upgrade(id: String, stat_name: String, save_mgr = null) -> bool:
	if not save_mgr:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root.has_node("SaveManager"):
			save_mgr = tree.root.get_node("SaveManager")
	if not save_mgr:
		return false
		
	var canonical = resolve_weapon_id(id)
	var cost = get_upgrade_cost(canonical, stat_name, save_mgr)
	if cost <= 0:
		return false
		
	var cur_lvl = get_upgrade_level(canonical, stat_name, save_mgr)
	if cur_lvl >= WeaponData.MAX_UPGRADE_LEVEL:
		return false
		
	var spent = save_mgr.spend_cash(cost) if save_mgr.has_method("spend_cash") else (save_mgr.data.cash >= cost)
	if not spent:
		return false
	if not save_mgr.has_method("spend_cash"):
		save_mgr.add_cash(-cost)
	var lvls = get_upgrade_levels(canonical, save_mgr)
	lvls[stat_name] = cur_lvl + 1
	save_mgr.data.weapon_upgrades[canonical] = lvls
	
	# Sync alias
	var entry = get_weapon_entry(canonical)
	for alias in entry.get("aliases", []):
		save_mgr.data.weapon_upgrades[alias] = lvls
		
	save_mgr.save_game()
	return true

static func purchase_weapon(id: String, save_mgr = null) -> bool:
	if not save_mgr:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root.has_node("SaveManager"):
			save_mgr = tree.root.get_node("SaveManager")
	if not save_mgr:
		return false
		
	var canonical = resolve_weapon_id(id)
	if is_weapon_unlocked(canonical, save_mgr):
		return true
		
	var entry = get_weapon_entry(canonical)
	var price = entry.get("unlock_price", 0)
	var spent = save_mgr.spend_cash(price) if save_mgr.has_method("spend_cash") else (save_mgr.data.cash >= price)
	if not spent:
		return false
	if not save_mgr.has_method("spend_cash"):
		save_mgr.add_cash(-price)
	unlock_weapon(canonical, save_mgr)
	return true
