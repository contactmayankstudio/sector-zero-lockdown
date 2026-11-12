import re

with open("scenes/player/Player.gd", "r") as f:
    content = f.read()

new_configs = """var weapon_configs = [
	{"id": "negev_ng7", "path": "res://resources/weapons/negev_ng7.tres", "model": "res://scenes/weapons/models/negev_ng7.tscn"},
	{"id": "p90", "path": "res://resources/weapons/p90.tres", "model": "res://scenes/weapons/models/p90.tscn"},
	{"id": "ak74_bayonet", "path": "res://resources/weapons/ak74_bayonet.tres", "model": "res://scenes/weapons/models/ak74_bayonet.tscn"},
	{"id": "akx_scifi", "path": "res://resources/weapons/akx_scifi.tres", "model": "res://scenes/weapons/models/akx_scifi.tscn"},
	{"id": "n7_rifle", "path": "res://resources/weapons/n7_rifle.tres", "model": "res://scenes/weapons/models/n7_rifle.tscn"},
	{"id": "car_smg", "path": "res://resources/weapons/car_smg.tres", "model": "res://scenes/weapons/models/car_smg.tscn"},
	{"id": "grenade_mk2", "path": "res://resources/weapons/grenade_mk2.tres", "model": "res://scenes/weapons/models/grenade_mk2.tscn"}
]"""

content = re.sub(r'var weapon_configs = \[[\s\S]*?\]\n\nvar weapons:', new_configs + '\n\nvar weapons:', content)

# Also ensure weapon orientation & position relative to camera / hands in _init_weapons
old_inst = """		if model_res is PackedScene:
			var model_inst = model_res.instantiate()
			model_inst.name = "WeaponModel"
			w.add_child(model_inst)"""

new_inst = """		if model_res is PackedScene:
			var model_inst = model_res.instantiate()
			model_inst.name = "WeaponModel"
			# Adjust positioning in hands
			model_inst.position = Vector3(0, 0, 0)
			w.add_child(model_inst)"""

content = content.replace(old_inst, new_inst)

with open("scenes/player/Player.gd", "w") as f:
    f.write(content)

print("Updated scenes/player/Player.gd!")
