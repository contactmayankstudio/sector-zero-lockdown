with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if line.startswith("static func resolve_weapon_id"):
        new_lines.append(line)
        new_lines.append("\treturn id\n")
        skip = True
        continue
    if line.startswith("static func get_all_weapon_ids"):
        new_lines.append(line)
        new_lines.append("\treturn []\n")
        skip = True
        continue
        
    if skip and line.startswith("static func "):
        skip = False
        
    if not skip:
        new_lines.append(line)

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.writelines(new_lines)
