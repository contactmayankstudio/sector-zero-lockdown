with open("scripts/UpgradeUI.gd", "r") as f:
    content = f.read()

content = content.replace('var current_weapon_id: String = "m4a1"', 'var current_weapon_id: String = "negev_ng7"')

old_weapon_res = """var weapon_resources = {
	"usp45": "res://resources/weapons/usp45.tres",
	"pistol": "res://resources/weapons/pistol.tres",
	"m4a1": "res://resources/weapons/m4a1.tres",
	"rifle": "res://resources/weapons/rifle.tres",
	"remington870": "res://resources/weapons/remington870.tres",
	"shotgun": "res://resources/weapons/shotgun.tres",
"""

new_weapon_res = """var weapon_resources = {
	"negev_ng7": "res://resources/weapons/negev_ng7.tres",
	"usp45": "res://resources/weapons/negev_ng7.tres",
	"pistol": "res://resources/weapons/negev_ng7.tres",
	"m4a1": "res://resources/weapons/negev_ng7.tres",
	"rifle": "res://resources/weapons/negev_ng7.tres",
	"remington870": "res://resources/weapons/negev_ng7.tres",
	"shotgun": "res://resources/weapons/negev_ng7.tres",
"""

content = content.replace(old_weapon_res, new_weapon_res)

with open("scripts/UpgradeUI.gd", "w") as f:
    f.write(content)
print("Patched UpgradeUI.gd!")
