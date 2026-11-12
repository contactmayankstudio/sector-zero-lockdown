## 2026-09-07T22:47:56Z

You are the Project Orchestrator (orchestrator_6) for the project "Sector Zero: Lockdown — Full Game Verification, Realistic Overhaul & Autonomous Polish".

Your working directory is: /home/am/targetkill/.agents/orchestrator_6
The project root directory is: /home/am/targetkill
The authoritative user request is located at: /home/am/targetkill/ORIGINAL_REQUEST.md (and /home/am/targetkill/.agents/ORIGINAL_REQUEST.md). Please inspect the newest request under timestamp `2026-09-07T22:47:56Z`.

Mission Scope & Requirements:
R1. First-Person Tactical Firearms & SWAT Combat Arms:
- Load complete native 3D weapon models with authentic materials and textures for all weapons in the armory (M134 Vulcan Minigun, VK-47 Flatline, C.A.R. SMG, Vantage Ultimate Sniper, Hawk 18.4mm Shotgun, USP-45, MP5, M4A1, AK-47, Remington 870, Desert Eagle, AWP, Combat Knife, Crossbow, Grenade Launcher).
- Player first-person view with realistic tactical SWAT combat arms aligned with equipped firearm.
- Weapon mechanics: dynamic muzzle flashes, realistic recoil kick, weapon switching, automatic magazine reload on 0 ammo.

R2. Zombie Roster, Quadruped Infected Dogs, and Audio:
- Quadruped 4-legged infected dog archetype with full animation playback (run, attack, hit_head, hit_body, death, idle), lower ground collision capsule, dedicated barking/biting/death audio.
- Humanoid zombies with Dead Target-style outfit variations (orange jumpsuits, denim jeans, necrotic skin with glowing red eyes).
- Support all enemy archetypes across missions (normal, fast, heavy, spitter, dog, boss).

R3. High-Clarity Environments & Atmosphere:
- Environment scenes (UrbanStreet with GTA Grove Street in Mission 1, AirportServiceRoad with CityStreetBlock in Mission 2, RailwayStation, AirportTerminal, BossArena) with dark aggregate asphalt, lane markings, realistic buildings, warm sunlight, rich shadows, procedural sky, no washed-out fog/overexposed bloom.
- Maintain low-spec optimization: locked 30 FPS, native 1.0 3D resolution scale with FXAA, zero texture recompression hangs.

R4. Pure Mobile / Android HUD & Input Controls:
- Virtual movement joystick bottom-left, swipe look/aim area, Fire button bottom-right, Reload, Switcher, Grenade buttons.
- Mouse cursor free & visible (`Input.MOUSE_MODE_VISIBLE`).
- Directional red damage indicator arcs, bloody claw scratch screen edge overlays, crosshair hitmarkers, top health/ammo bar.

R5. Campaign Progression & Persistence:
- 12-mission campaign progression with single-claim cash rewards ($500 -> $6,000) and unlock chaining.
- Save data persistence in `~/.local/share/godot/app_userdata/Sector Zero- Lockdown/savegame.json`.
- Zero get_node() outside scene tree errors.

Acceptance Criteria:
1. `scenes/test/TestRunner.tscn` passes all 54/54 tests (100% pass rate).
2. `scenes/test/test_realistic_overhaul.tscn` passes all 88/88 tests across 4 tiers with 0 failures.
3. Zero GDScript syntax or compilation errors in any .gd file.
4. Gameplay verification (weapon switching, auto-reload, Mission 1 & Mission 2 loads cleanly at 30 FPS, Virtual Joystick & HUD responsiveness).
