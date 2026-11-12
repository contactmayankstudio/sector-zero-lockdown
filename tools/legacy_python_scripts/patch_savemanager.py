with open("scripts/SaveManager.gd", "r") as f:
    content = f.read()

# Replace starter weapons
content = content.replace('["pistol", "rifle", "shotgun", "usp45", "m4a1", "remington870"]', '["negev_ng7"]')
content = content.replace('"equipped_weapon": "pistol"', '"equipped_weapon": "negev_ng7"')
content = content.replace('for starter in ["pistol", "rifle", "shotgun", "usp45", "m4a1", "remington870"]:', 'for starter in ["negev_ng7"]:')
content = content.replace('var eq = data.get("equipped_weapon", "pistol")', 'var eq = data.get("equipped_weapon", "negev_ng7")')

with open("scripts/SaveManager.gd", "w") as f:
    f.write(content)
print("Patched SaveManager.gd!")
