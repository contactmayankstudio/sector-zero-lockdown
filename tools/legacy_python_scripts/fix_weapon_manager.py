import re

with open("scripts/Weapons/WeaponManager.gd", "r") as f:
    content = f.read()

# Replace res://models/weapons/X.obj with res://scenes/weapons/models/X.tscn
# Note: some are named slightly differently? No, ls shows pistol.tscn, m4a1.tscn, etc.

content = re.sub(r'res://models/weapons/([a-zA-Z0-9_]+)\.obj', r'res://scenes/weapons/models/\1.tscn', content)

with open("scripts/Weapons/WeaponManager.gd", "w") as f:
    f.write(content)
