# Execution Plan: Sector Zero — Lockdown Audio, Weapons & Overhaul Polish

## Objective
Satisfy all requirements in ORIGINAL_REQUEST.md (## 2026-09-08T07:44:39Z):
- R1: Punchy Weapon & Combat Audio Integration (link sfx_minigun_shoot.ogg, sfx_flatline_shoot.ogg, sfx_car_shoot.ogg, sfx_hawk_shoot.ogg, sfx_sniper_shoot.ogg in scenes/weapons/Weapon.gd; mechanical reload sounds for shotguns, snipers, rifles/pistols; headshot crunch in EnemyBase.gd; dark horror drone ambience in gameplay missions).
- R2: First-Person Tactical Firearms & SWAT Combat Arms (all 3D weapons load native models/materials, tactical SWAT arms with gloved hands and forearm skin, dynamic muzzle flashes, recoil kick, switching, auto reload on 0 ammo).
- R3: Zombie Roster, Quadruped Infected Dogs, and AI Navigation (4-legged skeletal canine with full animations, lower collision, dedicated audio, Dead Target outfit variations, all archetypes).
- R4: High-Clarity Environments & 30 FPS Optimization (GTA Grove Street in M1, CityStreetBlock in M2, RailwayStation, AirportTerminal, BossArena; dark asphalt, yellow divider lines, warm lighting, rich ground shadows, procedural sky, no glare/bloom, locked 30 FPS).
- R5: Pure Mobile / Android HUD & Input Controls (virtual joystick, swipe look/aim, circular Fire, Reload, Switch, Grenade; uncaptured mouse cursor; tactical HUD damage arcs, scratch overlays, hitmarkers, top bar).
- Acceptance: TestRunner.tscn 54/54 PASS, test_realistic_overhaul.tscn 88/88 PASS (all 4 tiers), 0 GDScript errors.

## Phase 0: Survey & Technical Diagnostics (Exploration)
- Spawn 3 parallel Explorers:
  1. `explorer_audio_r7`: Investigate R1 audio integration in `scenes/weapons/Weapon.gd`, `scripts/Zombies/EnemyBase.gd`, ambience playback in missions, reload sfx mapping.
  2. `explorer_weapons_r7`: Investigate R2 & R3 weapons armory, SWAT combat arms, infected dog canine model, animations, collision, and audio.
  3. `explorer_tests_env_r7`: Run and inspect `scenes/test/TestRunner.tscn` and `scenes/test/test_realistic_overhaul.tscn`, inspect R4 environments and R5 HUD/input.

## Phase 1: Implementation & Bug Fixing (Workers)
- Based on Explorer findings, dispatch Worker(s) with clear write ownership:
  - Audio & Combat Worker: Fix audio bindings, reload sfx, headshot crunch, and horror drone ambience.
  - Fix any failing tests or missing requirements in TestRunner or test_realistic_overhaul.
  - Verify zero GDScript syntax/compilation errors.

## Phase 2: Independent Review & Verification
- Spawn Reviewers to review code diffs, GDScript syntax, audio links, and mobile compatibility.
- Spawn Challengers to run full headless test suites and stress-test game loops.

## Phase 3: Forensic Integrity Audit
- Spawn Forensic Auditor (`teamwork_preview_auditor`) to verify zero cheating, genuine implementation, and zero hardcoded test pass bypasses.

## Phase 4: Gate Check & Victory Handoff
- Check all gate criteria: build/tests pass, reviewer approvals, challenger pass, auditor CLEAN.
- Complete handoff and report to Sentinel.
