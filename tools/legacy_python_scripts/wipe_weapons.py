import re

with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    content = f.read()

# Replace the WEAPONS dict with empty
content = re.sub(r'const WEAPONS: Dictionary = \{[\s\S]*?\}\n\n# Alias', 'const WEAPONS: Dictionary = {}\n\n# Alias', content)

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.write(content)

with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

# Replace weapon_configs with empty
content = re.sub(r'var weapon_configs = \[[\s\S]*?\]\n', 'var weapon_configs = []\n', content)

# Change default equipped weapon
content = re.sub(r'equipped_id = "pistol"', 'equipped_id = ""', content)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
