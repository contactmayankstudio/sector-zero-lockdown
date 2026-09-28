# Project: Sector Zero: Lockdown — DEAD TARGET Style Realistic 3D Overhaul

## Architecture
Sector Zero: Lockdown is a mobile-first stationary 3D zombie FPS built with Godot 4 under the `gl_compatibility` renderer.
This overhaul transforms the game into a DEAD TARGET style realistic visual and combat experience:
- **High-Fidelity Weapon Pipeline**: PBR-textured weapon models imported from `real assent grafix import karna he` (Flatline AR, CAR SMG, M134 Minigun, Hawk Shotgun, Vantage Sniper). StandardMaterial3D conversion with diffuse/normal/metallic-roughness textures to resolve GLES3 `KHR_materials_pbrSpecularGlossiness` compatibility. Standardized `MuzzleSocket`, recoil kickback, procedural reload animations, and weapon upgrade progression.
- **Realistic Environment Staging**: Expansive urban complexes (`street_city_7_for_games_free(1).glb`, `tram_station(1).glb`, `street_city_buildings_8.glb`) configured with golden-hour/night PBR directional lighting, filmic tonemapping, crisp orthogonal shadows, zero-glare mobile atmospheric fog, 360-degree navigation regions, and stationary combat cover staging.
- **Visceral Combat Feedback**: Impactful hit reactions, headshot multipliers (2.5x) with audio punch, mobile-safe `CPUParticles3D` blood splatters, dynamic hitmarkers, and distinct zombie damage/stagger states.
- **Mobile Performance Safeguards**: Strict `gl_compatibility` budget (<100 draw calls, <=3 active dynamic lights, ASTC/ETC2 texture compression, .gdignore on raw bulk asset folders) ensuring smooth 30/60 FPS on Android.

## Feature Inventory
Every feature identified during the Survey phase is cataloged below with its assigned milestone:

| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | F1: Curate Asset Folders & `.gdignore` Protection | Add `.gdignore` to raw `real assent grafix import karna he` directory and curate selected models into `assets/3d/` | M1 | Survey (Explorer 3 / Pipeline) |
| 2 | F2: Realistic Urban Street Staging | Integrate `street_city_7_for_games_free(1).glb` and `street_city_buildings_8.glb` into realistic street arena with asphalt PBR and navigation | M1 | Survey (Explorer 1 / Assets) |
| 3 | F3: Tram Station Transit Hub Arena | Integrate `tram_station(1).glb` (mobile 1K textures) with platforms, tracks, canopies, and 360-degree zombie spawners | M1 | Survey (Explorer 1 / Assets) |
| 4 | F4: Mobile PBR Lighting & Atmosphere | Gritty post-apocalyptic DirectionalLight3D, procedural sky, filmic tonemapping, orthogonal shadows, no SSAO/glare errors | M1 | Survey (Explorer 2 & 3) |
| 5 | F5: Flatline AR Integration | Import `apex_legends_vk-47_flatline_overheat.glb` to `scenes/weapons/models/flatline.tscn`, PBR materials, `MuzzleSocket`, stats in `flatline.tres` | M2 | Survey (Explorer 1 / Assets) |
| 6 | F6: CAR SMG Integration | Import `apex_legends_car_smg_brimstone.glb` to `scenes/weapons/models/car_smg.tscn`, PBR materials, `MuzzleSocket`, stats in `car_smg.tres` | M2 | Survey (Explorer 1 / Assets) |
| 7 | F7: Rotary Minigun Integration | Import `serious_sam_3_minigun.glb` to `scenes/weapons/models/minigun.tscn`, 2K PBR materials, spinning barrel rig, stats in `minigun.tres` | M2 | Survey (Explorer 1 / Assets) |
| 8 | F8: Viewmodel Rig & Recoil Tuning | Connect new weapons to `FPSArms` tactical rig, synchronize recoil kick, procedural Lissajous breathing, and tactical reload | M2 | Survey (Explorer 2 / Codebase) |
| 9 | F9: Armory 3D Inspection & Economy | Update `ArmoryUI.tscn` to display 3D previews of new weapons with 4-stat upgrade matrix and unlock progression | M2 | Survey (Explorer 2 / Codebase) |
| 10 | F10: Visceral Combat Feedback & Gore VFX | Impactful headshot audio punch, golden hitmarkers, mobile-safe `CPUParticles3D` blood splatters, and zombie stagger reactions | M3 | Survey (Explorer 1, 2, 3) |
| 11 | F11: Mobile GLES3 Compatibility Safeguards | Ensure 0 shader compilation errors, 0 missing texture pink warnings, orthogonal shadows, and light pass budget in `gl_compatibility` | M3 | Survey (Explorer 3 / Pipeline) |
| 12 | F12: Stationary 360-Degree Combat Verification | Verify zombies navigate from all 360-degree quadrants towards stationary player, taking proper body (1.0x) and headshot (2.5x) damage | M4 | Survey (Explorer 2 / Codebase) |
| 13 | F13: Automated Headless E2E Regression Suite | Verify `TestRunner.tscn`, `Zombie360Test.tscn`, `test_weapons_economy.gd`, and new weapon integration test pass cleanly (100% PASS) | M4 | Survey (Explorer 3 / Pipeline) |
| 14 | F14: Forensic Integrity Audit | Independent verification by `teamwork_preview_auditor` confirming authentic implementation, 0 hardcoded cheats, 0 missing assets | M4 | Survey (Integrity Forensics) |

## Milestones

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Realistic Environment Staging & Mobile PBR Lighting (R2) | Curate models with `.gdignore` safeguard; stage high-fidelity Urban Street and Tram Station arenas with PBR materials, crisp orthogonal sun shadows, filmic tonemapping, and 360-degree navigation regions. | none | PLANNED |
| M2 | High-Fidelity 3D Weapon Pipeline & Viewmodel Rig Integration (R1) | Integrate Flatline AR, CAR SMG, and Serious Sam Minigun models into `assets/3d/weapons/`, create viewmodel scenes with `MuzzleSocket`, configure `WeaponData` resources with audio bindings and 4 upgrade paths, hook into `Player.gd` tactical arms rig and `ArmoryUI`. | M1 | PLANNED |
| M3 | Visceral Combat Feedback & Mobile Performance Safeguards (R3) | Implement mobile-safe `CPUParticles3D` blood/gore bursts, headshot sound punch, golden hitmarkers, distinct zombie stagger states, and audit console for 0 GLES3/gl_compatibility warnings. | M1, M2 | PLANNED |
| M4 | E2E Regression Verification & Forensic Integrity Audit | Run complete headless test suite (`TestRunner.tscn`, `Zombie360Test.tscn`, `test_weapons_economy.gd`, and new weapon tests); run `teamwork_preview_auditor` forensic verification. | M1, M2, M3 | PLANNED |

## Interface Contracts

### Weapon ↔ Viewmodel Rig (`Weapon.gd` ↔ `Player.gd`)
- Each weapon scene under `scenes/weapons/models/<name>.tscn` MUST contain a child node named `MuzzleSocket` (`Node3D`).
- Scale and rotation of weapon models must face `-Z` forward with proper tactical eye-level offset (approx `Vector3(0.18, -0.18, -0.42)`).
- `Weapon.gd` searches for `MuzzleSocket` in child model to position `MuzzleFlash` and `MuzzleLight`.
- Signals: `ammo_changed(current: int, max_ammo: int)`, `weapon_reload_started(duration: float)`.

### WeaponData ↔ Armory & Gameplay (`WeaponData.gd` ↔ `ArmoryUI.gd` / `SaveManager.gd`)
- `weapon_id`: Unique identifier matching resource filename (e.g. `flatline`, `car_smg`, `minigun`).
- Base stats: `base_damage`, `headshot_multiplier` (>=2.0), `base_fire_rate`, `base_mag_size`, `base_reload_time`, `spread`, `recoil`.
- 4 upgrade paths (levels 0-4): `get_damage()`, `get_mag_size()`, `get_reload_time()`, `get_spread()`, `get_upgrade_cost()`.
- Unlocked state persisted in `SaveManager.data.unlocked_weapons`.

### Environment Arena ↔ Combat Spawner (`Environment.tscn` ↔ `GameManager.gd`)
- `NavigationRegion3D` with baked `NavigationMesh` covering the stationary player perimeter.
- Spawn markers positioned 10m-25m in 4 quadrants: `SpawnFront`, `SpawnLeft`, `SpawnRight`, `SpawnBack`.
- Lighting: Exactly 1 `DirectionalLight3D` (sun, orthogonal shadow) + <= 3 `OmniLight3D` local perimeter lights.

### Combat HitZone ↔ Weapon Raycast (`HitZone.gd` ↔ `Weapon.gd`)
- Head hit zone: `zone_type = 0` (HEAD), `damage_multiplier = 2.5`.
- Chest hit zone: `zone_type = 1` (CHEST), `damage_multiplier = 1.0`.
- Limb hit zone: `zone_type = 2` (LIMBS), `damage_multiplier = 0.7`.
- Hit result triggers `HUD.show_hitmarker(is_headshot)` and spawns blood particles at collision normal.

## Code Layout
- `assets/3d/weapons/`: High-fidelity GLB models (`flatline.glb`, `car_smg.glb`, `minigun.glb`, `hawk_shotgun.glb`)
- `assets/3d/environments/`: High-fidelity GLB environment models (`street_city_7.glb`, `tram_station.glb`, `street_buildings.glb`)
- `scenes/weapons/models/`: Godot 3D viewmodel scenes with `MuzzleSocket` and PBR materials (`flatline.tscn`, `car_smg.tscn`, `minigun.tscn`)
- `resources/weapons/`: `WeaponData` resource files (`flatline.tres`, `car_smg.tres`, `minigun.tres`, etc.)
- `scenes/environments/`: Arena scenes (`UrbanStreet.tscn`, `RailwayStation.tscn`, `AirportServiceRoad.tscn`)
- `scenes/player/`: `Player.tscn`, `Player.gd` (viewmodel rig, stationary rotation, recoil, ADS)
- `scenes/UI/`: `HUD.tscn`, `ArmoryUI.tscn`
- `scripts/Zombies/`: `EnemyBase.gd` (hit reactions, headshot multipliers, stagger)
- `scenes/test/`: `TestRunner.tscn`, test scripts in `scripts/Tools/`
