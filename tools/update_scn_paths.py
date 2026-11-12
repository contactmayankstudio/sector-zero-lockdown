import re

def update_file(path):
    with open(path, "r") as f:
        content = f.read()
    content = content.replace(".tscn", ".scn")
    # restore scenes/weapons/models/fps_arms.tscn if touched
    content = content.replace("fps_arms.scn", "fps_arms.tscn")
    content = content.replace("Weapon.scn", "Weapon.tscn")
    content = content.replace("ArmoryUI.scn", "ArmoryUI.tscn")
    content = content.replace("UpgradeUI.scn", "UpgradeUI.tscn")
    content = content.replace("AirportTerminal.scn", "AirportTerminal.tscn")
    content = content.replace("Zombie.scn", "Zombie.tscn")
    with open(path, "w") as f:
        f.write(content)
    print("Updated", path)

update_file("scripts/Weapons/WeaponManager.gd")
update_file("scripts/UI/ArmoryUI.gd")
update_file("scripts/Characters/Player.gd")
update_file("scenes/player/Player.gd")

