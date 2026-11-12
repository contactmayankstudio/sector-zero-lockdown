with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    content = f.read()

content = content.replace("static func get_all_weapon_ids() -> Array[String]:\n\treturn []", 'static func get_all_weapon_ids() -> Array[String]:\n\tvar arr: Array[String] = ["negev_ng7"]\n\treturn arr')

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.write(content)
print("WeaponManager patched!")
