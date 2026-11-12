import re

with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    content = f.read()

negev_entry = """const WEAPON_REGISTRY: Dictionary = {
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
	}
}"""

content = re.sub(r'const WEAPON_REGISTRY: Dictionary = \{\}', negev_entry, content)

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.write(content)

with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

content = re.sub(r'var weapon_configs = \[\]', 'var weapon_configs = ["negev_ng7"]', content)
content = re.sub(r'equipped_id = ""', 'equipped_id = "negev_ng7"', content)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
