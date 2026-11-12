import re

with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

content = re.sub(r'res://models/weapons/([a-zA-Z0-9_]+)\.obj', r'res://scenes/weapons/models/\1.tscn', content)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
