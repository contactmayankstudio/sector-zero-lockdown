extends SceneTree

const WEAPONS = [
	{
		"id": "negev_ng7",
		"name": "Negev NG7 LMG",
		"damage": 38.0,
		"fire_rate": 0.08,
		"mag": 150,
		"reserve": 450,
		"reload": 4.5,
		"recoil": 1.2,
		"spread": 0.04,
		"sound": "rifle",
		"price": 5000
	},
	{
		"id": "p90",
		"name": "FN P90 Tactical",
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
	for def in WEAPONS:
		var wd = load("res://scripts/WeaponData.gd").new()
		wd.weapon_id = def.id
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
		
		var path = "res://resources/weapons/" + def.id + ".tres"
		var err = ResourceSaver.save(wd, path, ResourceSaver.FLAG_COMPRESS)
		print("Rebuilt ", path, " with WeaponData class! Result: ", err)
	quit(0)
