# Original User Request

## 2026-09-06T13:05:45Z

Sector Zero: Lockdown — Build out a 12-Mission Campaign architecture with progressive scaling, focusing specifically on implementing Mission 2 (Infected Dogs) as the immediate milestone.

Working directory: /workspaces/targetkill
Integrity mode: demo

## Requirements

### R1. Campaign Architecture (Workstream A & D)
Refactor the game into a 12-mission structure, where each mission consists of exactly 3 large waves. The wave system must handle multiple enemy groups, different spawn directions, escalating pressure, and varied stationary-FPS objectives. Implement gradual CASH rewards ($500 -> $6,000) granted exactly once upon completion, and update the UI (Mission Select, wave indicators, completion screen).

### R2. Reusable Environment Complexes (Workstream B)
Create 5 major reusable environment complexes (Airport, Railway, Urban, Industrial, Quarantine) using realistic PBR materials, believable scale, and atmospheric lighting (no primitive placeholders). Modify lighting, weather, and dressing to make reused maps feel distinct.

### R3. Mission 2 Implementation (Workstream C)
Focus active development on MISSION 2 — AIRPORT SERVICE ROAD. Primary enemy: Infected Dogs.
- Wave 1: Small dog groups.
- Wave 2: Larger groups + varied spawn directions.
- Wave 3: Largest assault + special final group.
Dogs must have proper skeletal animations (no T-posing or floating limbs), realistic materials, and distinct hit zones (Head, Body). Ensure CC0/commercial-safe assets are used.

### R4. Performance & Android Targeting (Workstream E)
Maintain 720p landscape 60 FPS performance. Avoid unnecessary 4K textures, excessive dynamic lights, or huge particle systems. Modularize scenes to prevent memory leaks and track APK size.

## Acceptance Criteria

### Testing & Validation (Workstream F)
- [ ] Existing regression tests (`godot --headless scenes/test/TestRunner.tscn`) must remain at 44/44 PASSED (or higher with new tests added).
- [ ] `assets_tests/Zombie360Test.tscn` must PASS.
- [ ] New tests created and passing for: wave progression, mission completion, CASH reward logic, mission unlock, and save/load persistence.
- [ ] No duplicate CASH rewards can be claimed on restart.

### Quality Criteria
- [ ] No ripped/copyrighted assets are used.
- [ ] Mission 2 is fully playable, visually validated, and stable before progressing to Mission 3.
- [ ] Mission 1 remains intact and unmodified.

## 2026-09-06T14:14:16Z

# Teamwork Project Prompt — Draft

> Status: Step 9 — Ready for launch — awaiting user approval.
> Goal: Craft prompt → get user approval → delegate to teamwork_preview
> Requested team: Full-scale team (multiple workstreams)

Sector Zero: Lockdown — Full-Scale Mobile Zombie FPS. Expand the existing prototype into a premium, 12-mission tactical stationary 3D shooter with a fully functional economy, upgrades, diverse enemy types, and a polished Android target.

Working directory: `/workspaces/targetkill`
Integrity mode: development

## Requirements

### R1. Campaign & Gameplay Framework
Build a 12-mission campaign with 3 substantial waves per mission. The player is primarily stationary with 360-degree aiming. Implement scalable EnemyBase architecture (Normal, Fast, Heavy, Special, Dogs, Rats, Bats, Boss) with clean state-machine AI.

### R2. Weapons, Upgrades & Economy
Implement 10 distinct 3D weapons with upgrade paths (Damage, Magazine, Reload, Accuracy) using a fictional CASH economy. Cash persists across sessions and is earned by completing missions.

### R3. UI/UX & Polish
Create a unified premium dark-tactical UI: Main Menu, Mission Select, Briefings, Gameplay HUD, Mission Complete/Failed screens, Armory, and Settings. Ensure mobile-friendly performance (720p target, controlled lighting).

### R4. Integrity & Legal
Do NOT copy commercial assets or clone proprietary code (e.g., Dead Target). Ensure every external asset is fully documented in `ASSET_LICENSES.md`.

## Acceptance Criteria

### Project Completion
- [ ] All 12 missions exist, each containing 3 substantial waves.
- [ ] Mission progression and save/load systems function correctly.
- [ ] CASH economy and weapon upgrade progression operate seamlessly.
- [ ] 10 unique weapons are implemented (or explicitly documented as unavailable).
- [ ] Distinct enemy variants (including Final Boss) are implemented and functional.
- [ ] The benchmark quality of Mission 1 is preserved and functional.
- [ ] Automated regression test suite completely passes.
- [ ] An ARM64 Android APK can be successfully exported.
- [ ] `ASSET_LICENSES.md` is populated for all external assets.

## 2026-09-06T14:24:14Z

The server restarted and all subagents and background tasks were stopped. Please resume your execution, revive your orchestrator, and restart your monitoring crons to continue working on the Sector Zero: Lockdown project.

## 2026-09-06T14:41:52Z

The user has requested to expedite the execution ("fast work karao"). Please prioritize completing the core gameplay features, resolving the remaining test failures, and moving towards the final integration as quickly as possible. Skip exhaustive non-essential tasks if they are slowing down the critical path.

## 2026-09-06T14:45:33Z

The user has requested to add more agents to the workforce ("aur agent ko work par lagao"). Please scale up your team by spawning additional worker agents to execute the remaining workstreams in parallel and finish the project even faster.

## 2026-09-06T14:57:17Z

The server restarted again and all subagents and background tasks were stopped. Please resume your execution, revive your orchestrator and worker agents, and restart your monitoring crons to continue working on the Sector Zero: Lockdown project at maximum scale.

## 2026-09-06T15:58:23Z

The server restarted and all subagents and background tasks were stopped. Please resume your execution, revive your orchestrator, auditors, and crons, and continue the Verification Gate and final Victory Audit for Sector Zero: Lockdown.

## 2026-09-07T15:52:42Z

Overhaul "Sector Zero: Lockdown" into a high-clarity 3D mobile zombie shooter matching the visual style, weapon mechanics, and enemy diversity of Dead Target, fully optimized for 30 FPS on low-spec hardware.

Working directory: /home/am/targetkill
Integrity mode: development

## Requirements

### R1. First-Person Tactical Weapons & SWAT Combat Arms
- All weapons in the armory (USP-45, MP5, M4A1, AK-47, Remington 870, Desert Eagle, AWP, Combat Knife, Crossbow, Grenade Launcher) must load complete native 3D weapon models with authentic materials and textures.
- The player's first-person view must feature realistic tactical SWAT combat arms (gloved hands and forearm skin) correctly aligned with the equipped firearm.
- Gunplay must feature dynamic muzzle flashes, realistic recoil kick, weapon switching, and automatic magazine reload when ammo reaches 0.

### R2. Zombie Roster, Quadruped Infected Dogs, and Audio
- The infected dog archetype must spawn as a genuine 4-legged skeletal canine with full animation playback (run, attack, hit_head, hit_body, death, idle), lower ground-level collision capsule, and dedicated barking, biting, and death audio streams.
- Humanoid zombies must display vivid Dead Target-style outfit variations: safety orange worker jumpsuits with blue undershirts and blood stains, civilian denim jeans with stained shirts, and necrotic diseased skin with glowing red eyes.
- Support all enemy archetypes across missions (normal, fast, heavy, spitter, dog, boss) with appropriate stats, rewards, and audio cues.

### R3. High-Clarity Environments & Atmosphere
- Environment scenes (AirportServiceRoad, AirportTerminal, etc.) must render with high visual clarity: dark aggregate asphalt road with yellow boundary/lane divider lines, road wear, barriers, and shipping containers matching Dead Target's look.
- Clear atmospheric lighting: warm sunlight, rich ground shadows, vibrant procedural sky, and complete elimination of washed-out white fog glare or overexposed bloom.
- Maintain low-spec optimization: native 1.0 3D resolution scale with FXAA, zero texture recompression hangs, locked 30 FPS, and low processor mode safeguards.

### R4. Pure Mobile / Android HUD & Input Controls
- Maintain full Android mobile touch controls: visible virtual movement joystick on bottom-left, responsive swipe look/aim area, large circular Fire button on bottom-right, circular Reload button, weapon Switcher button, and Grenade button.
- The mouse cursor must remain free and visible (never captured or trapped) so the player can interact seamlessly via mouse click/drag touch emulation.
- Include tactical HUD feedback: directional red damage indicator arcs, bloody claw scratch overlays on screen edges when taking damage, crosshair hitmarkers, and top bar with health and ammo counters.

## Acceptance Criteria

### Weapons & Viewmodel
- [ ] Switching between all unlocked weapons loads the complete 3D model without missing `.scn` or resource errors.
- [ ] Combat arms (`FPSArms`) are visible in first-person camera view holding the active weapon.
- [ ] Firing an empty magazine automatically triggers reload without freezing the weapon state.

### Enemy Archetypes & Canine Audio
- [ ] Mission 2 spawns 4-legged animated infected dogs (`infected_dog.tscn`) that run, leap, bite, and collapse on death.
- [ ] Dog barks and snarling play through `SfxGrowl`, bite attacks play through `SfxAttack`, and death whimpers play through `SfxDeath`.
- [ ] Normal and fast zombies display vivid randomized clothing palettes (orange overalls, blue jeans, blood stains) instead of monochrome meshes.

### Visual Quality & Environment
- [ ] Road surfaces display realistic asphalt texturing with yellow divider lines and tire tracks.
- [ ] The environment renders sharp, high-contrast visuals with zero milky white fog glare.
- [ ] The project starts and runs smoothly at 30 FPS on the AMD APU without system freeze or hanging importer tasks.

### Mobile Controls & HUD
- [ ] Virtual Joystick and all HUD buttons (Fire, Reload, Switch, Grenade) are visible and responsive to touch / click events.
- [ ] Mouse cursor is never captured (`Input.MOUSE_MODE_VISIBLE` is maintained).
- [ ] Directional damage arcs and claw scratch effects trigger properly upon taking zombie hits.

## Verification Resources
- Verification scripts: `test_m2_play.gd`, `test_capture_mission2.gd`, `test_p_verify.gd`
- Reference visuals: `/home/am/Music/real/` (Dead Target benchmark screenshots)


## 2026-09-07T21:35:06Z

Transform Sector Zero: Lockdown into a high-octane, DEAD TARGET style realistic stationary 3D zombie shooter by integrating high-fidelity 3D weapon models and realistic environment assets from the local asset repository into the game engine with optimized mobile shaders, lighting, and visceral combat feedback.

Working directory: /home/am/targetkill
Integrity mode: development

## Requirements

### R1. High-Fidelity Weapon Asset Pipeline & Integration
- Integrate and configure realistic weapon models from `real assent grafix import karna he` (such as Flatline assault rifle, CAR SMG, M134 Minigun, Shotgun/Sniper) into the player's armory and FPS viewmodel rig.
- Ensure correct first-person muzzle transforms, ADS/hipfire positioning, muzzle flash alignment, recoil kickback animations, and proper weapon sound bindings without broken materials.

### R2. DEAD TARGET Style Realistic Environment Staging
- Utilize high-fidelity environment assets from `real assent grafix import karna he` (e.g. realistic street/city buildings, tram station, urban complexes) to stage immersive, atmospheric stationary combat arenas.
- Set up gritty post-apocalyptic visual presentation: realistic PBR lighting, atmospheric fog/skybox, directional shadow tuning, and obstacle cover points calibrated for 360-degree stationary zombie waves.

### R3. Combat Feedback & Mobile Performance Safeguards
- Enhance the visceral combat feel in line with DEAD TARGET mechanics: impactful hit reactions, gore/blood splatters, headshot audio punch, and distinct zombie damage states.
- Maintain Godot 4 `gl_compatibility` mobile performance budgets: LOD/texture optimization to prevent VRAM overflow or frame-rate drop on mobile targets (Android).

## Acceptance Criteria

### Visual & Audio Quality
- [ ] At least 3 new high-fidelity weapon models from `real assent grafix import karna he` are properly instantiated with intact PBR textures, correct hand/screen offsets, and working fire/reload VFX.
- [ ] The game loads and renders the realistic environment geometry without missing texture pink shaders or collision errors.

### Gameplay & Mechanics
- [ ] Stationary 360-degree combat loop remains fully functional with zombies navigating towards the player and properly triggering hit/headshot multipliers.
- [ ] Weapon switching, ammunition tracking, reloading, and armory selection correctly reflect the new weapons.

### Stability & Verification
- [ ] Godot headless check / test suites run without fatal script errors or crash on mission load.
- [ ] Mobile rendering profile (`gl_compatibility`) maintains clean console output without missing resource warnings.

## 2026-09-07T22:47:56Z

# Sector Zero: Lockdown — Full Game Verification, Realistic Overhaul & Autonomous Polish

Working directory: /home/am/targetkill
Integrity mode: development

## Requirements

### R1. First-Person Tactical Firearms & SWAT Combat Arms
- All 3D weapons in the armory (M134 Vulcan Minigun, VK-47 Flatline, C.A.R. SMG, Vantage Ultimate Sniper, Hawk 18.4mm Shotgun, USP-45, MP5, M4A1, AK-47, Remington 870, Desert Eagle, AWP, Combat Knife, Crossbow, Grenade Launcher) must load complete native 3D weapon models with authentic materials and textures.
- The player's first-person view must feature realistic tactical SWAT combat arms (gloved hands and forearm skin) correctly aligned with the equipped firearm.
- Weapon mechanics must feature dynamic muzzle flashes, realistic recoil kick, weapon switching, and automatic magazine reload when ammo reaches 0.

### R2. Zombie Roster, Quadruped Infected Dogs, and Audio
- The infected dog archetype must spawn as a genuine 4-legged skeletal canine with full animation playback (run, attack, hit_head, hit_body, death, idle), lower ground-level collision capsule, and dedicated barking, biting, and death audio streams.
- Humanoid zombies must display vivid Dead Target-style outfit variations: safety orange worker jumpsuits with blue undershirts and blood stains, civilian denim jeans with stained shirts, and necrotic diseased skin with glowing red eyes.
- Support all enemy archetypes across missions (normal, fast, heavy, spitter, dog, boss) with appropriate stats, rewards, and audio cues.

### R3. High-Clarity Environments & Atmosphere
- Environment scenes (UrbanStreet with GTA Grove Street in Mission 1, AirportServiceRoad with CityStreetBlock in Mission 2, RailwayStation, AirportTerminal, BossArena) must render with high visual clarity: dark aggregate asphalt road with yellow boundary/lane divider lines, road wear, barriers, and realistic buildings.
- Clear atmospheric lighting: warm sunlight, rich ground shadows, vibrant procedural sky, and complete elimination of washed-out white fog glare or overexposed bloom.
- Maintain low-spec optimization: native 1.0 3D resolution scale with FXAA, zero texture recompression hangs, locked 30 FPS, and low processor mode safeguards.

### R4. Pure Mobile / Android HUD & Input Controls
- Maintain full Android mobile touch controls: visible virtual movement joystick on bottom-left, responsive swipe look/aim area, large circular Fire button on bottom-right, circular Reload button, weapon Switcher button, and Grenade button.
- The mouse cursor must remain free and visible (never captured or trapped) so the player can interact seamlessly via mouse click/drag touch emulation.
- Include tactical HUD feedback: directional red damage indicator arcs, bloody claw scratch overlays on screen edges when taking damage, crosshair hitmarkers, and top bar with health and ammo counters.

### R5. Campaign Progression & Persistence
- Support full 12-mission campaign progression with single-claim cash rewards ($500 -> $6,000) and unlock chaining.
- Ensure save data persistence in `~/.local/share/godot/app_userdata/Sector Zero- Lockdown/savegame.json` maintains unlocked weapons, cash, and armory upgrades.
- Ensure zero `get_node()` outside scene tree errors occur during scene transitions or loading states.

## Acceptance Criteria

### Automated Test Suites
- [ ] `scenes/test/TestRunner.tscn` runs headlessly and passes all 54/54 tests (100% PASS rate).
- [ ] `scenes/test/test_realistic_overhaul.tscn` runs headlessly and passes all 88/88 tests across 4 tiers with 0 failures.
- [ ] Zero GDScript syntax or compilation errors in any `.gd` file across the project.

### Gameplay Verification
- [ ] Switching between all unlocked weapons displays the authentic 3D model and tactical arms without errors.
- [ ] Firing an empty magazine automatically triggers reload without freezing the weapon state.
- [ ] Mission 1 (GTA Grove Street) and Mission 2 (City Street Block) load cleanly within timeout limits and run stably at 30 FPS.
- [ ] Virtual Joystick and all HUD buttons (Fire, Reload, Switch, Grenade) respond cleanly to mouse/touch interactions with an uncaptured cursor.

## Verification Resources
- Test suite runners: `scenes/test/TestRunner.tscn`, `scenes/test/test_realistic_overhaul.tscn`
- Reference captures: `/home/am/Music/real/`

## 2026-09-08T07:44:39Z

# Sector Zero: Lockdown — Realistic Audio, Weapon Arsenal & Full Game Polish

Complete integration of new punchy weapon audio, mechanical reloads, visceral headshot impacts, horror ambient soundscapes, 3D firearms, GTA Grove Street environment, and full-game test verification in Godot 4.3 for "Sector Zero: Lockdown".

Working directory: /home/am/targetkill
Integrity mode: development

## Requirements

### R1. Punchy Weapon & Combat Audio Integration
- Link the downloaded high-fidelity weapon audio (`sfx_minigun_shoot.ogg`, `sfx_flatline_shoot.ogg`, `sfx_car_shoot.ogg`, `sfx_hawk_shoot.ogg`, `sfx_sniper_shoot.ogg`) to their respective firearms in `scenes/weapons/Weapon.gd`.
- Implement distinct mechanical reload sounds: shotgun shell loading for shotguns, bolt-action rack for snipers, and magazine slide/clicks for rifles and pistols.
- Integrate the visceral bone/skull crunch sound (`sfx_headshot_crunch.ogg`) on critical headshots in `scripts/Zombies/EnemyBase.gd` and play dark horror drone ambience (`sfx_horror_drone.wav`) during gameplay missions.

### R2. First-Person Tactical Firearms & SWAT Combat Arms
- All 3D weapons in the armory (M134 Vulcan Minigun, VK-47 Flatline, C.A.R. SMG, Vantage Ultimate Sniper, Hawk 18.4mm Shotgun, USP-45, MP5, M4A1, AK-47, Remington 870, Desert Eagle, AWP) must load complete native 3D weapon models with authentic materials and textures.
- The player's first-person view must feature realistic tactical SWAT combat arms (gloved hands and forearm skin) correctly aligned with the equipped firearm.
- Weapon mechanics must feature dynamic muzzle flashes, realistic recoil kick, weapon switching, and automatic magazine reload when ammo reaches 0.

### R3. Zombie Roster, Quadruped Infected Dogs, and AI Navigation
- The infected dog archetype must spawn as a genuine 4-legged skeletal canine with full animation playback (run, attack, hit_head, hit_body, death, idle), lower ground-level collision capsule, and dedicated barking, biting, and death audio streams.
- Humanoid zombies must display vivid Dead Target-style outfit variations: safety orange worker jumpsuits with blue undershirts and blood stains, civilian denim jeans with stained shirts, and necrotic diseased skin with glowing red eyes.
- Support all enemy archetypes across missions (normal, fast, heavy, spitter, dog, boss) with appropriate stats, rewards, and audio cues.

### R4. High-Clarity Environments & 30 FPS Optimization
- Environment scenes (UrbanStreet with GTA Grove Street in Mission 1, AirportServiceRoad with CityStreetBlock in Mission 2, RailwayStation, AirportTerminal, BossArena) must render with high visual clarity: dark aggregate asphalt road with yellow boundary/lane divider lines, road wear, barriers, and realistic buildings.
- Clear atmospheric lighting: warm sunlight, rich ground shadows, vibrant procedural sky, and complete elimination of washed-out white fog glare or overexposed bloom.
- Maintain low-spec optimization: native 1.0 3D resolution scale with FXAA, zero texture recompression hangs, locked 30 FPS, and low processor mode safeguards.

### R5. Pure Mobile / Android HUD & Input Controls
- Maintain full Android mobile touch controls: visible virtual movement joystick on bottom-left, responsive swipe look/aim area, large circular Fire button on bottom-right, circular Reload button, weapon Switcher button, and Grenade button.
- The mouse cursor must remain free and visible (never captured or trapped) so the player can interact seamlessly via mouse click/drag touch emulation.
- Include tactical HUD feedback: directional red damage indicator arcs, bloody claw scratch overlays on screen edges when taking damage, crosshair hitmarkers, and top bar with health and ammo counters.

## Acceptance Criteria

### Automated Test Suites
- [ ] `scenes/test/TestRunner.tscn` runs headlessly and passes all 54/54 tests (100% PASS rate).
- [ ] `scenes/test/test_realistic_overhaul.tscn` runs headlessly and passes all 88/88 tests across 4 tiers with 0 failures.
- [ ] Zero GDScript syntax or compilation errors in any `.gd` file across the project.

### Audio & Combat Verification
- [ ] Firing the Minigun, Flatline, CAR SMG, Sniper, and Shotgun plays their dedicated punchy sound effects without fallback glitches.
- [ ] Landing a headshot triggers the visceral headshot crunch audio and visual hitmarker feedback.
- [ ] Reloading weapons triggers authentic mechanical reload clicks and slide sounds according to weapon class.
- [ ] Background horror drone ambience loops softly during mission gameplay without drowning out gunfire or zombie groans.

## Verification Resources
- Test suite runners: `scenes/test/TestRunner.tscn`, `scenes/test/test_realistic_overhaul.tscn`
- Audio assets directory: `res://audio/weapons/`, `res://audio/ambience/`, `res://audio/impacts/`

## 2026-09-13T18:24:34Z

Implement a high-impact Combat Juiciness & Visceral Feedback System for SECTOR ZERO: LOCKDOWN in Godot 4.3, featuring dynamic screen blood splatters, critical headshot decapitation effects, low-HP pulsing heartbeat feedback, and a cinematic slow-motion Last-Kill Cam on wave completion.

Working directory: /home/am/targetkill
Integrity mode: development

## Requirements

### R1. Screen Blood Splatter & Low-HP Feedback
Render dynamic, fading blood splatters on the player's screen/HUD whenever damage is taken. When player health drops below 30%, activate a rhythmic pulsing red vignette overlay and looping heartbeat audio that subsides upon recovery.

### R2. Visceral Headshot Decapitation & Impact FX
Lethal critical headshots against zombies must trigger immediate head dismemberment/decapitation effects and a directional blood burst particle spray, synchronized with the existing 2.5x critical hitmarker sound.

### R3. Cinematic Last-Kill Slow-Motion Cam
Upon eliminating the final zombie in Wave 3 or defeating the Giant Butcher Boss, momentarily scale game time down to 0.2x speed for 1.8 seconds with an audio pitch/bass dip to deliver a satisfying cinematic climax before restoring normal speed for the Victory/Result UI.

### R4. Performance & Mobile Compatibility Safeguards
All new overlays, particle systems, and time-scale logic must run cleanly in Godot 4.3's `gl_compatibility` renderer, maintaining 30 FPS stability and zero memory growth across extended play sessions on the low-spec AMD APU / Android target.

## Verification Resources

- Automated 4-Tier Regression Test Suite: `scenes/test/test_realistic_overhaul.tscn`
- Mission Consistency Validator: `tools/validate_all_missions.gd`
- Realistic Zombie Controller: `assets/zombies/RealisticZombie.gd`
- Player Controller & Camera: `scenes/player/Player.tscn` and `scripts/Player.gd`
- HUD Overlay: `scenes/UI/HUD.tscn` and `scenes/UI/HUD.gd`

## Acceptance Criteria

### Combat Juiciness & Visual FX
- [ ] Taking damage from a zombie melee attack renders fading blood droplets on the HUD that smoothly dissipate over 2.5 seconds.
- [ ] Player health falling below 30 HP triggers a visible pulsating red screen vignette and audible heartbeat effect.
- [ ] Delivering a lethal headshot causes the zombie's head mesh to disappear/decapitate accompanied by a blood burst effect.
- [ ] The final kill of Wave 3 or Boss defeat activates a 0.2x time scale for 1.8 seconds before transitioning to ResultUI.

### Stability & Performance
- [ ] Running `godot --headless scenes/test/test_realistic_overhaul.tscn` continues to pass 100% (all test cases).
- [ ] Running `godot --headless --script tools/validate_all_missions.gd` confirms all 13 missions pass without errors.
- [ ] Sequential arena reloads demonstrate zero orphaned nodes and less than 1 MB memory growth over 3 cycles.

## 2026-09-13T19:01:22Z

[USER DIRECTIVE]: Ek team ko UI/UX par lagaye.
The user specifically requests dedicating a workstream to polish and overhaul the game UI/UX across Main Menu, Armory, Mission Select, ResultUI, and mobile HUD styling to achieve a modern, AAA zombie shooter aesthetic (clean high-contrast typography, sci-fi/tactical glowing borders, polished button press feedback, improved layout, and touch ergonomics) while strictly maintaining mobile gl_compatibility performance. Please incorporate this UI/UX stream into the project milestones.



## 2026-09-18T04:43:32Z

Advance and polish 'Sector Zero: Lockdown' (a Godot 4.3 Android zombie FPS in `/home/am/targetkill`) toward release-readiness, focusing on test infrastructure, game stability, campaign balance, and Android export verification.

Working directory: /home/am/targetkill
Integrity mode: development

## Verification Resources
- Existing test suites in `scripts/Tools/` (`test_campaign_contract.gd`, `test_ui_screens.gd`, `test_endless_score.gd`, `test_daily_challenge.gd`, etc.).
- Testing guidelines and 4-tier model defined in `TEST_INFRA.md`.
- Milestone tracking in `PROJECT_STATUS.md`.

## Requirements

### R1. Deterministic Headless Test Infrastructure
The headless test runner and test suites (contract, UI, weapons/economy, endless scoring, and mission gameplay) must execute cleanly via Godot 4 CLI, emitting deterministic summary metrics and a clean exit code (0 on success, non-zero on failure), with zero script parse errors or unbounded timeouts.

### R2. Campaign Data Integrity & Mission Flow
All 12 campaign mission resources and Endless mode must conform to runtime contracts: valid active wave count (normalized to 3 waves per mission), verified scene and directional spawn references, and reliable completion logic that guarantees boss objectives cannot trigger early completion before all waves are cleared.

### R3. Clean Asset Provenance & License Quarantine
All assets included in active scenes and distribution builds must have verified permissive/commercial licenses. All unverified or quarantined assets must remain strictly segregated and excluded from game scene loads and export presets.

### R4. Android Build & Export Readiness
The project configuration and export presets (`export_presets.cfg`) must support automated/headless export verification for Android (ARM64 / release APK or AAB configuration) with portable export paths and no missing distribution assets or broken dependencies.

## Acceptance Criteria

### Test Execution & Harness Stability
- [ ] Running Godot in headless mode against the test runner exits cleanly with exit code 0 and an unambiguous pass/fail test summary.
- [ ] Zero script parse or runtime compile errors across all GDScript files in `scripts/` and `scenes/`.

### Campaign & Objective Integrity
- [ ] Campaign contract test verifies all 12 missions have exactly 3 configured waves, valid scene references, and proper spawn marker definitions.
- [ ] Mission completion handlers verify that boss missions do not finish prematurely before the final configured wave.

### Provenance & Asset Safety
- [ ] Game loads and runs all campaign scenes without referencing assets located in `quarantine_suspect_assets/` or unverified directories.
- [ ] `ASSET_LICENSES.md` accurately documents legal provenance for all bundled assets.

### Export Verification
- [ ] Android export configuration contains portable paths and valid export filters excluding quarantined/test files.
- [ ] Godot export command (or dry-run export validation) succeeds with zero missing file dependencies.
