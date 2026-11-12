with open("scripts/UI/ArmoryUI.gd", "r") as f:
    lines = f.readlines()

with open("scripts/UI/ArmoryUI.gd", "w") as f:
    for line in lines:
        if line.startswith("for mi in meshes_found:"):
            f.write("\tfor mi in meshes_found:\n")
        else:
            f.write(line)
