with open("scripts/Zombies/EnemyBase.gd", "r") as f:
    content = f.read()

content = content.replace('"res://assets/3d/zombies/zombie_normal.glb"', '"res://scenes/zombies/models/zombie_scary.tscn"')
content = content.replace('"res://assets/3d/zombies/zombie_fast.glb"', '"res://scenes/zombies/models/zombie_scary.tscn"')
content = content.replace('"res://assets/3d/zombies/zombie_heavy.glb"', '"res://scenes/zombies/models/zombie_mutant.tscn"')
content = content.replace('"res://assets/3d/zombies/zombie_boss.glb"', '"res://scenes/zombies/models/zombie_mutant.tscn"')

with open("scripts/Zombies/EnemyBase.gd", "w") as f:
    f.write(content)

print("EnemyBase.gd updated with realistic zombie models!")
