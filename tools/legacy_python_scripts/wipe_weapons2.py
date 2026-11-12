import re

with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    content = f.read()

content = re.sub(r'const WEAPON_REGISTRY: Dictionary = \{[\s\S]*?\}\n\n# Alias', 'const WEAPON_REGISTRY: Dictionary = {}\n\n# Alias', content)

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.write(content)
