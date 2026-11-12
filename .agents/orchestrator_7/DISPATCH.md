## 2026-09-08T07:46:00Z
You are the Project Orchestrator (orchestrator_7).
Your working directory is: /home/am/targetkill/.agents/orchestrator_7
The project root is: /home/am/targetkill
The authoritative original user request is recorded in: /home/am/targetkill/ORIGINAL_REQUEST.md (specifically the latest request under ## 2026-09-08T07:44:39Z).

Mission:
Sector Zero: Lockdown — Realistic Audio, Weapon Arsenal & Full Game Polish
Complete integration of new punchy weapon audio, mechanical reloads, visceral headshot impacts, horror ambient soundscapes, 3D firearms, GTA Grove Street environment, and full-game test verification in Godot 4.3 for "Sector Zero: Lockdown".

Key Requirements:
R1. Punchy Weapon & Combat Audio Integration (link sfx_minigun_shoot.ogg, sfx_flatline_shoot.ogg, sfx_car_shoot.ogg, sfx_hawk_shoot.ogg, sfx_sniper_shoot.ogg in scenes/weapons/Weapon.gd; mechanical reload sounds for shotguns, snipers, rifles/pistols; headshot crunch sfx_headshot_crunch.ogg in scripts/Zombies/EnemyBase.gd; dark horror drone ambience sfx_horror_drone.wav).
R2. First-Person Tactical Firearms & SWAT Combat Arms (all 3D weapons in armory load complete native models with authentic materials; SWAT combat arms gloved hands and forearm skin; muzzle flashes, recoil kick, switching, auto reload on 0 ammo).
R3. Zombie Roster, Quadruped Infected Dogs, and AI Navigation (4-legged skeletal canine with full animations, lower collision, dedicated barking/biting/death audio; Dead Target outfit variations, all enemy archetypes).
R4. High-Clarity Environments & 30 FPS Optimization (GTA Grove Street in M1, CityStreetBlock in M2, RailwayStation, AirportTerminal, BossArena with dark asphalt, yellow divider lines, warm lighting, rich ground shadows, procedural sky, no glare/bloom, locked 30 FPS).
R5. Pure Mobile / Android HUD & Input Controls (virtual joystick, swipe look/aim, circular Fire, Reload, Switch, Grenade; uncaptured free mouse cursor; tactical HUD damage arcs, scratch overlays, hitmarkers, top bar).

Acceptance Criteria:
- scenes/test/TestRunner.tscn passes all 54/54 tests.
- scenes/test/test_realistic_overhaul.tscn passes all 88/88 tests across 4 tiers with 0 failures.
- Zero GDScript syntax or compilation errors.
- Audio & combat verification satisfied.
