# Dispatch: explorer_ui_ux

## Mission: AAA Tactical UI/UX Polish Overhaul
Investigate the current state and structure of all UI screens in Sector Zero: Lockdown:
- `scenes/UI/MainMenu.tscn`, `scripts/MainMenu.gd` (or `scenes/UI/MainMenu.gd`)
- `scenes/UI/ArmoryUI.tscn`, `scripts/ArmoryUI.gd`
- `scenes/UI/MissionSelectUI.tscn`, `scripts/MissionSelect.gd`
- `scenes/UI/ResultUI.tscn`, `scripts/ResultUI.gd`
- `scenes/UI/HUD.tscn`, `scripts/HUD.gd` (mobile buttons: Fire, Reload, Switch, Grenade, Pause, VirtualJoystick)

## Goals
1. Analyze existing Theme, StyleBox, fonts, and button interactions.
2. Formulate concrete styling upgrades: dark tactical/sci-fi aesthetic, glowing borders/accents, clean typography, tactile button animations (scale dip on press, hover highlight, sound).
3. Ensure touch target ergonomics and zero performance impact under Godot 4.3 `gl_compatibility` (avoid heavy fragment shaders, use StyleBoxFlat and TextureRect).
4. Document exact node hierarchies and implementation blueprints in `handoff.md`.

Output: `/home/am/targetkill/.agents/explorer_ui_ux/handoff.md`.

## 2026-09-13T19:05:11Z
You are explorer_ui_ux, a read-only exploration agent.
Your working directory is: /home/am/targetkill/.agents/explorer_ui_ux
Project root is: /home/am/targetkill

MANDATORY FIRST STEP: Read /home/am/targetkill/ORIGINAL_REQUEST.md completely before doing any work. Also read /home/am/targetkill/.agents/explorer_ui_ux/DISPATCH.md.

YOUR TASK:
Investigate and design a comprehensive AAA Tactical UI/UX Overhaul per the user directive:
"Ek team ko UI/UX par lagaye. Overhaul and polish the game UI/UX (MainMenu, Armory, MissionSelect, ResultUI, and mobile HUD) to an AAA zombie-shooter standard (clean styling, tactile button feedback, glowing accents, polished responsive layouts) while preserving 30 FPS gl_compatibility performance."

Examine:
1. scenes/UI/MainMenu.tscn and its controller script
2. scenes/UI/ArmoryUI.tscn and its controller script
3. scenes/UI/MissionSelectUI.tscn (or MissionSelect.tscn) and its controller script
4. scenes/UI/ResultUI.tscn and scripts/ResultUI.gd
5. scenes/UI/HUD.tscn mobile action buttons (Fire, Reload, Switch, Grenade, Pause, VirtualJoystick)
6. Existing Theme resources or styling methods in the project
7. Design AAA tactical UI style: dark palette, high contrast, subtle tactical glowing borders, tactile press response (scale tween/hover/sound), and mobile touch ergonomics with zero performance overhead under gl_compatibility.

Write a complete, actionable architectural blueprint and implementation plan to:
/home/am/targetkill/.agents/explorer_ui_ux/handoff.md
When finished, send a brief message with your handoff path.

