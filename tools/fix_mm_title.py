import re
with open("scenes/UI/MainMenu.tscn", "r") as f:
    text = f.read()

text = re.sub(r'(name="Title".*?text = ")SECTOR ZERO(")', r'\1SECTOR ZERO: LOCKDOWN\2', text, flags=re.DOTALL)
with open("scenes/UI/MainMenu.tscn", "w") as f:
    f.write(text)
