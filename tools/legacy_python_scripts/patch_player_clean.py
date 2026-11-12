import re

with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

# Replace weapon_configs
old_cfg = 'var weapon_configs = ["negev_ng7"]'
new_cfg = """var weapon_configs = [
	{
		"id": "negev_ng7",
		"path": "res://resources/weapons/negev_ng7.tres",
		"model": "res://scenes/weapons/models/negev_ng7.tscn"
	}
]"""

content = content.replace(old_cfg, new_cfg)

# Now let's look at _init_weapons
old_init = """func _init_weapons():
	for child in weapon_manager.get_children():
		child.queue_free()
	weapons.clear()

	var save_mgr = get_node_or_null("/root/SaveManager")
	var unlocked_ids = save_mgr.data.unlocked_weapons if save_mgr and save_mgr.data.has("unlocked_weapons") else ["pistol", "rifle", "shotgun"]
	print("UNLOCKED IDS: ", unlocked_ids)

	# We will dynamically build the list from unlocked IDs
	var all_possible_weapons = weapon_configs.duplicate()
	# Add the 10 heavy weapons to the possible list so we can find them
	var ids = ["m134", "rpg7", "rpd", "mg42", "l86", "m249", "pkm", "m60", "m2browning", "flamethrower"]
	for wid in ids:
		all_possible_weapons.append({"id": "heavy_"+wid, "path": "res://resources/weapons/heavy_"+wid+".tres", "model": "res://scenes/weapons/models/rifle.tscn"})

	for cfg in all_possible_weapons:
		if not cfg.id in unlocked_ids:
			continue
			
		var w = weapon_prefab.instantiate()
		w.weapon_data = load(cfg.path)
		w.aim_raycast = aim_raycast
		weapon_manager.add_child(w)
		
		# Set 3D model on weapon
		if w.has_node("MeshInstance3D"):
			var model_res = load(cfg.model)
			if model_res is PackedScene:
				var wm = _extract_mesh_from_scene(model_res)
				if wm:
					w.get_node("MeshInstance3D").mesh = wm
					w.get_node("MeshInstance3D").material_override = null
			elif model_res is Mesh:
				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = null
			
		w.ammo_changed.connect(func(_c, _m): _update_hud())"""

new_init = """func _init_weapons():
	for child in weapon_manager.get_children():
		child.queue_free()
	weapons.clear()

	for cfg in weapon_configs:
		var w = weapon_prefab.instantiate()
		if ResourceLoader.exists(cfg.path):
			w.weapon_data = load(cfg.path)
		w.aim_raycast = aim_raycast
		weapon_manager.add_child(w)
		weapons.append(w)
		
		# Set 3D model on weapon
		if w.has_node("MeshInstance3D") and ResourceLoader.exists(cfg.model):
			var model_res = load(cfg.model)
			if model_res is PackedScene:
				var wm = _extract_mesh_from_scene(model_res)
				if wm:
					w.get_node("MeshInstance3D").mesh = wm
					w.get_node("MeshInstance3D").material_override = null
			elif model_res is Mesh:
				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = null
			
		w.ammo_changed.connect(func(_c, _m): _update_hud())"""

content = content.replace(old_init, new_init)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)

print("Player.gd patched successfully!")
