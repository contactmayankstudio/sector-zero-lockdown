with open("scenes/player/Player.gd", "r") as f:
    content = f.read()

old_fallback = '["pistol", "rifle", "shotgun"]'
new_fallback = '["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]'

content = content.replace(old_fallback, new_fallback)

# Also ensure all weapon_configs are always unlocked by default
ensure_code = """	var unlocked_ids = save_mgr.data.unlocked_weapons if save_mgr and save_mgr.data.has("unlocked_weapons") else ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]
	for cfg in weapon_configs:
		if not cfg.id in unlocked_ids:
			unlocked_ids.append(cfg.id)"""

content = content.replace('var unlocked_ids = save_mgr.data.unlocked_weapons if save_mgr and save_mgr.data.has("unlocked_weapons") else ["negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"]', ensure_code)

with open("scenes/player/Player.gd", "w") as f:
    f.write(content)

print("Updated scenes/player/Player.gd unlocked fallback!")
