import json

# 1. Update WeaponManager.gd
weapon_registry_code = """const WEAPON_REGISTRY: Dictionary = {
	"negev_ng7": {
		"id": "negev_ng7",
		"display_name": "Negev NG7 LMG",
		"subtitle": "7.62x51mm Heavy Suppressive Fire",
		"category": "Machine Gun",
		"resource_path": "res://resources/weapons/negev_ng7.tres",
		"scene_path": "res://scenes/weapons/models/negev_ng7.tscn",
		"model_path": "res://scenes/weapons/models/negev_ng7.tscn",
		"unlock_price": 0,
		"default_unlocked": true,
		"aliases": ["negev", "lmg"]
	},
	"p90": {
		"id": "p90",
		"display_name": "FN P90 Tactical",
		"subtitle": "5.7x28mm High-Capacity PDW",
		"category": "Submachine Gun",
		"resource_path": "res://resources/weapons/p90.tres",
		"scene_path": "res://scenes/weapons/models/p90.tscn",
		"model_path": "res://scenes/weapons/models/p90.tscn",
		"unlock_price": 2200,
		"default_unlocked": true,
		"aliases": ["p90_smg"]
	},
	"ak74_bayonet": {
		"id": "ak74_bayonet",
		"display_name": "AK-74 Bayonet",
		"subtitle": "5.45x39mm Combat Assault Rifle",
		"category": "Assault Rifle",
		"resource_path": "res://resources/weapons/ak74_bayonet.tres",
		"scene_path": "res://scenes/weapons/models/ak74_bayonet.tscn",
		"model_path": "res://scenes/weapons/models/ak74_bayonet.tscn",
		"unlock_price": 2800,
		"default_unlocked": true,
		"aliases": ["ak74"]
	},
	"akx_scifi": {
		"id": "akx_scifi",
		"display_name": "AKX Cyber Carbine",
		"subtitle": "Advanced Plasma-Coated Kinetic Rifle",
		"category": "Assault Rifle",
		"resource_path": "res://resources/weapons/akx_scifi.tres",
		"scene_path": "res://scenes/weapons/models/akx_scifi.tscn",
		"model_path": "res://scenes/weapons/models/akx_scifi.tscn",
		"unlock_price": 3500,
		"default_unlocked": true,
		"aliases": ["akx"]
	},
	"n7_rifle": {
		"id": "n7_rifle",
		"display_name": "N7 Valkyrie Carbine",
		"subtitle": "Precision Heavy Kinetic Battle Rifle",
		"category": "Rifle",
		"resource_path": "res://resources/weapons/n7_rifle.tres",
		"scene_path": "res://scenes/weapons/models/n7_rifle.tscn",
		"model_path": "res://scenes/weapons/models/n7_rifle.tscn",
		"unlock_price": 4200,
		"default_unlocked": true,
		"aliases": ["n7"]
	},
	"car_smg": {
		"id": "car_smg",
		"display_name": "Frontier CAR SMG",
		"subtitle": "Dual-Feed High Cyclic SMG",
		"category": "Submachine Gun",
		"resource_path": "res://resources/weapons/car_smg.tres",
		"scene_path": "res://scenes/weapons/models/car_smg.tscn",
		"model_path": "res://scenes/weapons/models/car_smg.tscn",
		"unlock_price": 3000,
		"default_unlocked": true,
		"aliases": ["car"]
	},
	"grenade_mk2": {
		"id": "grenade_mk2",
		"display_name": "MK2 Frag Grenade",
		"subtitle": "High-Explosive Shrapnel Grenade",
		"category": "Explosive",
		"resource_path": "res://resources/weapons/grenade_mk2.tres",
		"scene_path": "res://scenes/weapons/models/grenade_mk2.tscn",
		"model_path": "res://scenes/weapons/models/grenade_mk2.tscn",
		"unlock_price": 1000,
		"default_unlocked": true,
		"aliases": ["grenade"]
	}
}"""

with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    wm_content = f.read()

import re
wm_content = re.sub(r'const WEAPON_REGISTRY: Dictionary = \{[\s\S]*?\n\}', weapon_registry_code, wm_content)
wm_content = re.sub(r'static func get_all_weapon_ids\(\) -> Array\[String\]:[\s\S]*?return arr', 'static func get_all_weapon_ids() -> Array[String]:\n\tvar arr: Array[String] = ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]\n\treturn arr', wm_content)

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.write(wm_content)
print("Updated WeaponManager.gd")

# 2. Update ArmoryUI.gd
armory_weapons = 'var weapons = ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]\n\nvar meshes = {\n\t"negev_ng7": "res://scenes/weapons/models/negev_ng7.tscn",\n\t"p90": "res://scenes/weapons/models/p90.tscn",\n\t"ak74_bayonet": "res://scenes/weapons/models/ak74_bayonet.tscn",\n\t"akx_scifi": "res://scenes/weapons/models/akx_scifi.tscn",\n\t"n7_rifle": "res://scenes/weapons/models/n7_rifle.tscn",\n\t"car_smg": "res://scenes/weapons/models/car_smg.tscn",\n\t"grenade_mk2": "res://scenes/weapons/models/grenade_mk2.tscn"\n}'

with open("scripts/UI/ArmoryUI.gd", "r") as f:
    armory_content = f.read()

armory_content = re.sub(r'var weapons = \["negev_ng7"\][\s\S]*?var meshes = \{[\s\S]*?\}', armory_weapons, armory_content)

with open("scripts/UI/ArmoryUI.gd", "w") as f:
    f.write(armory_content)
print("Updated ArmoryUI.gd")

# 3. Update Player.gd
player_weapons_code = """var weapon_configs = [
	{"id": "negev_ng7", "path": "res://resources/weapons/negev_ng7.tres", "model": "res://scenes/weapons/models/negev_ng7.tscn"},
	{"id": "p90", "path": "res://resources/weapons/p90.tres", "model": "res://scenes/weapons/models/p90.tscn"},
	{"id": "ak74_bayonet", "path": "res://resources/weapons/ak74_bayonet.tres", "model": "res://scenes/weapons/models/ak74_bayonet.tscn"},
	{"id": "akx_scifi", "path": "res://resources/weapons/akx_scifi.tres", "model": "res://scenes/weapons/models/akx_scifi.tscn"},
	{"id": "n7_rifle", "path": "res://resources/weapons/n7_rifle.tres", "model": "res://scenes/weapons/models/n7_rifle.tscn"},
	{"id": "car_smg", "path": "res://resources/weapons/car_smg.tres", "model": "res://scenes/weapons/models/car_smg.tscn"},
	{"id": "grenade_mk2", "path": "res://resources/weapons/grenade_mk2.tres", "model": "res://scenes/weapons/models/grenade_mk2.tscn"}
]"""

with open("scripts/Characters/Player.gd", "r") as f:
    player_content = f.read()

player_content = re.sub(r'var weapon_configs = \[[\s\S]*?\]', player_weapons_code, player_content)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(player_content)
print("Updated Player.gd")

# 4. Update SaveManager.gd and savegame.json
with open("scripts/SaveManager.gd", "r") as f:
    save_content = f.read()

save_content = re.sub(r'"unlocked_weapons": \[[^\]]*\]', '"unlocked_weapons": ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]', save_content)
save_content = re.sub(r'for starter in \[[^\]]*\]:', 'for starter in ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]:', save_content)

with open("scripts/SaveManager.gd", "w") as f:
    f.write(save_content)
print("Updated SaveManager.gd")

save_json_path = "/home/am/.local/share/godot/app_userdata/Sector Zero- Lockdown/savegame.json"
try:
    with open(save_json_path, "r") as f:
        sdata = json.load(f)
    sdata["unlocked_weapons"] = ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]
    with open(save_json_path, "w") as f:
        json.dump(sdata, f, indent=4)
    print("Updated savegame.json with all 7 weapons!")
except Exception as e:
    print("Notice on savegame.json:", e)
