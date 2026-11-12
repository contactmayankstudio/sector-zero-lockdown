import re

with open("scripts/UI/ArmoryUI.gd", "r") as f:
    content = f.read()

content = content.replace('var current_weapon_id: String = "m4a1"', 'var current_weapon_id: String = "negev_ng7"')

old_block = """var weapons = [
	"usp45", "m4a1", "remington870", "ak47", "desert_eagle", 
	"mp5", "awp", "combat_knife", "crossbow", "grenade_launcher"
]

var meshes = {
	"usp45": "res://scenes/weapons/models/usp45.tscn",
	"pistol": "res://scenes/weapons/models/usp45.tscn",
	"m4a1": "res://scenes/weapons/models/m4a1.tscn",
	"rifle": "res://scenes/weapons/models/m4a1.tscn",
	"remington870": "res://scenes/weapons/models/remington870.tscn",
	"shotgun": "res://scenes/weapons/models/remington870.tscn",
	"ak47": "res://scenes/weapons/models/ak47.tscn",
	"desert_eagle": "res://scenes/weapons/models/desert_eagle.tscn",
	"mp5": "res://scenes/weapons/models/mp5.tscn",
	"awp": "res://scenes/weapons/models/awp.tscn",
	"combat_knife": "res://scenes/weapons/models/combat_knife.tscn",
	"crossbow": "res://scenes/weapons/models/crossbow.tscn",
	"grenade_launcher": "res://scenes/weapons/models/grenade_launcher.tscn"
}"""

new_block = """var weapons = ["negev_ng7"]

var meshes = {
	"negev_ng7": "res://scenes/weapons/models/negev_ng7.tscn"
}"""

content = content.replace(old_block, new_block)

# Add negev_ng7 to WEAPON_ORIENTATIONS and WEAPON_TARGET_SIZES
content = content.replace('const WEAPON_ORIENTATIONS: Dictionary = {', 'const WEAPON_ORIENTATIONS: Dictionary = {\n\t"negev_ng7": Vector3(0, 0, 0),')
content = content.replace('const WEAPON_TARGET_SIZES: Dictionary = {', 'const WEAPON_TARGET_SIZES: Dictionary = {\n\t"negev_ng7": 0.85,')

with open("scripts/UI/ArmoryUI.gd", "w") as f:
    f.write(content)

print("Patched ArmoryUI.gd successfully!")
