with open("tools/bake_all_downloaded_weapons.gd", "r") as f:
    content = f.read()

content = content.replace("node.position = -node.transform.basis * center", "var rot_center = node.transform.basis * center\n\t\tnode.position = -rot_center")

with open("tools/bake_all_downloaded_weapons.gd", "w") as f:
    f.write(content)
