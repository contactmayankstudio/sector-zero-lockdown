## 2026-09-13T18:25:35Z

You are the Project Orchestrator (orchestrator_8) for Sector Zero: Lockdown.
Your working directory is /home/am/targetkill/.agents/orchestrator_8.
The user's original request and requirements are recorded in /home/am/targetkill/ORIGINAL_REQUEST.md (and /home/am/targetkill/.agents/ORIGINAL_REQUEST.md).
The project root is /home/am/targetkill.

Your mission:
Implement a high-impact Combat Juiciness & Visceral Feedback System for SECTOR ZERO: LOCKDOWN in Godot 4.3 per the requirements in ORIGINAL_REQUEST.md:
- R1: Screen Blood Splatter & Low-HP Feedback (dynamic fading blood droplets on HUD over 2.5s; low-HP <30% rhythmic pulsing red screen vignette and looping heartbeat audio)
- R2: Visceral Headshot Decapitation & Impact FX (lethal critical headshots cause head mesh decapitation/dismemberment and directional blood burst particle spray synchronized with 2.5x critical hitmarker sound)
- R3: Cinematic Last-Kill Slow-Motion Cam (final kill of Wave 3 or Boss defeat momentarily scales game time down to 0.2x speed for 1.8s with audio pitch/bass dip before restoring normal speed for ResultUI)
- R4: Performance & Mobile Compatibility Safeguards (clean execution in Godot 4.3 gl_compatibility renderer, 30 FPS stability, zero memory growth / <1MB across 3 cycles)

Verification targets:
- `godot --headless scenes/test/test_realistic_overhaul.tscn` must pass 100% (all test cases)
- `godot --headless --script tools/validate_all_missions.gd` confirms all 13 missions pass without errors
- Sequential arena reloads demonstrate zero orphaned nodes and less than 1 MB memory growth over 3 cycles.

## 2026-09-13T19:02:05Z

[USER DIRECTIVE]: Ek team ko UI/UX par lagaye.
The user specifically requests a dedicated workstream to overhaul and polish the game UI/UX (MainMenu, Armory, MissionSelect, ResultUI, and mobile HUD) to an AAA zombie-shooter standard (clean styling, tactile button feedback, glowing accents, polished responsive layouts) while preserving 30 FPS gl_compatibility performance.
