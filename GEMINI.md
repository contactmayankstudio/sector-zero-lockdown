# Sector Zero: Lockdown - Development Guide

## Project Overview
A ₹0 budget realistic Android zombie FPS built with Godot 4.x. 

## Current Progress (Phase 5: Final Content & Launch Prep)
- [x] **Game Identity:**
    - Final title: **Sector Zero: Lockdown**.
    - Original branding implemented in `MainMenu.tscn`.
- [x] **Tutorial:**
    - `TutorialUI.tscn`: Interactive 5-step onboarding for new players.
    - Logic integrated into `UrbanStreet.tscn` (automatic skip if completed).
- [x] **Weapon Balancing:**
    - USP-45 (Pistol), M4A1 Sentinel (Rifle), Remington 870 (Shotgun) balanced for distinct roles.
- [x] **HUD Polish:**
    - Integrated Boss Health Bar and Mission Objective display in `HUD.tscn`.
    - Added responsive `RELOAD` button for mobile touch.
- [x] **Launch Assets:**
    - `STORE_LISTING.md`: Original marketing copy for Google Play.
    - `ASSET_LICENSES.md`: Finalized third-party legal documentation.
- [x] **Realistic Scary Zombie Integration:**
    - Downloaded `scary_zombie_pack.glb` baked into lightweight `zombie_scary.scn` (1.89m height, facing forward).
    - Fully retargeted Mixamo animations: `walk`, `idle`, `attack`, `death`, `hit_react`, `stagger`.
    - Integrated across all zombie archetypes (`normal`, `realistic`, `fast`, `heavy`, `boss`, `spitter`, `special`) in `EnemyBase.gd`.
- [x] **Weapon Crosshair & Armory Alignment:**
    - Calibrated all 7 firearms (NG7 Heavy LMG, P90 Tactical, AK-74 Bayonet, AKX Cyber Carbine, Valkyrie V7 Carbine, Frontier SMG-9, MK2 Frag Grenade) for direct screen-center crosshair alignment in first-person view.
    - Added true relative AABB calculation in `ArmoryUI.gd` for 3D showroom turntable previews.
- [x] **Android Release Pipeline & 100-Year Keystore:**
    - Generated permanent 100-year validity keystore: `release.keystore` (valid until **2126**, alias `sectorzero_lockdown`, pass `sector123`).
    - Configured Gradle Android App Bundle (AAB) & Play Asset Delivery (PAD) pipeline.
    - Exported signed release bundle: `build/SectorZero-Lockdown-release.aab` (Deep optimized: 373 MB).
    - Exported and verified signed release binary: `build/SectorZero-Lockdown-release.apk` (417 MB).
    - Tested live over USB/Wi-Fi on physical device (OPPO CPH2185).
- [x] **Full Performance & Bug Fix Pass (Device-Verified):**
    - **No Disk I/O Hitching:** Eliminated per-kill synchronous `save_game()` in `ChallengeManager.gd`.
    - **No GPU Texture Stall:** Throttled `EnemyHealthBar3D.gd` pixel drawing and texture updates to only trigger when pixel columns change.
    - **Memory Leaks Eliminated:** Fixed un-freed `HeadshotBloodSpray` CPUParticles3D in `RealisticZombie.gd`.
    - **Audio Pooling:** Implemented 8-channel reuse pool in both `ImpactPool.gd` and `VFXManager.gd` to eliminate `AudioStreamPlayer3D` node spam on rapid fire.
    - **Crash Fixes:** Corrected QuadMesh to PlaneMesh in `AtmosphereEnhancer.gd`, guarded against dangling `is_instance_valid(player)` pointer in `EnemyBase.gd`, prevented corpse overkill `died` signals in `HealthComponent.gd`, and guarded weapon switch modulo by zero in `Player.gd`.
    - **Dependency Resolution:** Fixed `ExplosiveBarrel.tscn` missing audio dependency that previously blocked `AirportTerminal.tscn` mission loading.
    - **CPU Optimization:** Disabled active `_process` lerp loops on all inactive hidden weapons in inventory.
    - **Live Combat Verification:** Completed Waves 1, 2, and 3 through live device input on Mission 1 (`AirportTerminal.tscn`) with 0 errors and steady framerate.

- [x] **AdMob Banner & UI Overlap Resolution:**
    - Re-architected `BannerAdManager.gd`: Banner strictly shows in `MAIN_MENU` and `UPGRADES` (Armory). Automatically hidden in `MISSION_SELECT`, `LOADING`, and active `GAMEPLAY`.
    - Compacted banner size from 1360px wide (`PRESET_TOP_WIDE`) to 320x36 center-top (`PRESET_CENTER_TOP`), leaving all top buttons, cash labels, and controls completely unobstructed.
- [x] **HUD Top Bar Redesign:**
    - Stripped solid dark background (`Color(0,0,0,0)` transparent) and reduced vertical profile from 56px to 42px in `HUD.tscn`. The 3D sky and battlefield are 100% visible.
- [x] **Zombie Visibility & Attack Awareness:**
    - **Glowing Red Eyes:** Procedural dual unshaded emissive spheres with localized OmniLight3D head illumination attached to all zombie archetypes in `EnemyBase.gd`.
    - **Brightened Atmosphere:** Elevated ambient lighting energy to 0.55 and directional sun to 0.85 in `AirportTerminal.tscn`.
    - **Unstuck Watchdog:** Automated directional nudge and visual lane re-acquisition if a zombie is stuck for > 1.6s. Cleared barricade from central charge corridor.
    - **Directional Damage Arc:** Passing attacker position directly from `EnemyBase.gd` through `Player.gd` to `HUD.gd`, drawing a glowing red tactical shield arc with tip chevron pointing directly at the attacker.
    - **Off-Screen Threat Radar:** Real-time HUD screen edge chevrons with dynamic distance tags (`4m`, `12m`, `BOSS 18m`) pointing towards off-screen threats.
- [x] **Mission Resource Sanity:**
    - Removed excluded scenes `ApartmentComplex.tscn` and `NightCityStreet.tscn` from `ROTATING_ENVIRONMENTS` and mission `.tres` files, and guarded with `ResourceLoader.exists()` fallback to `AirportTerminal.tscn`.
- [x] **Wave 3 Completion & Next Mission Transition (Device-Verified):**
    - **Boss Kill Accounting:** Fixed `MissionManager.gd` where `on_boss_killed()` failed to increment standard `kill_count`, leaving missions 1 kill short on final wave.
    - **Guaranteed Wave Completion:** Updated `check_objective()` in `MissionManager.gd` to award victory whenever all wave requirements are survived (`wave_count >= current_mission.wave_count`), preventing stranded player state.
    - **GameManager End Watchdog:** Added direct fallback trigger in `GameManager.gd`'s `_check_wave_end()` to call `mission_mgr.finish_mission(true)` when `current_wave >= total_waves`.
    - **Seamless Next Mission Flow:** Updated `ResultUI.gd` to dynamically show `"NEXT MISSION ▶"` and advance immediately to the next campaign mission (e.g., 1-1 -> 1-2 -> 1-3) via `mission_mgr.start_mission(next_m)` while preserving `"MISSION MAP"` for level selection.
    - **Live Device Verification:** Successfully verified Wave 1-3 combat and transition from Mission 1-1 to 1-2 and 1-3 on physical OPPO CPH2185 device with 0 crashes.

## Final QA Gate
1. [x] **Boot:** `MainMenu.tscn` launches with 'Sector Zero' branding.
2. [x] **Onboarding:** Tutorial triggers on Mission 1 for new saves.
3. [x] **Combat:** Shooting, reloading, and headshots work as expected with centered crosshair.
4. [x] **Progression:** Coins earned, weapons upgraded, missions unlocked.
5. [x] **Persistence:** Progression survives app restart.
6. [x] **Realistic Enemies:** Downloaded scary zombies fully active with skeletal animations and glowing eyes.
7. [x] **Android Build:** Signed APK generated (`build/SectorZero-Lockdown-release.apk`).
8. [x] **100-Year Validity:** Keystore signed until 2126.
9. [x] **Live Phone Gameplay:** Verified smooth Wave 1-3 combat on physical device with 0 crashes.

## Release Metadata
- **Version Name:** 1.0.0
- **Version Code:** 1
- **Package ID:** com.targetzero.lockdown
- **Min SDK:** 24 (Android 7.0)
- **Target SDK:** 34 (Android 14)

