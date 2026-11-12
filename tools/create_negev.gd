extends SceneTree

func _init():
	var wd = load("res://scripts/Weapons/WeaponData.gd").new()
	wd.weapon_id = "negev_ng7"
	wd.display_name = "Negev NG7 LMG"
	wd.base_damage = 38.0
	wd.base_fire_rate = 0.08 # Fast fire rate (approx 12 rounds per sec)
	wd.base_mag_size = 150
	wd.base_reserve_ammo = 450
	wd.base_reload_time = 4.5
	wd.recoil = 1.2
	wd.spread = 0.04
	wd.range = 80.0
	wd.is_automatic = true
	wd.sound_set = "rifle"
	wd.unlock_price = 5000
	
	ResourceSaver.save(wd, "res://resources/weapons/negev_ng7.tres", ResourceSaver.FLAG_COMPRESS)
	print("Saved Negev weapon data.")
	quit()
