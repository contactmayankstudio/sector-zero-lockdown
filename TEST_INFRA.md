# Sector Zero: Lockdown — Comprehensive 4-Tier E2E Testing Infrastructure

**Document Version**: 1.0.0  
**Project**: Sector Zero: Lockdown — DEAD TARGET Style Realistic 3D Overhaul  
**Engine**: Godot Engine `v4.3.stable.official.77dcf97d8`  
**Rendering Profile**: `gl_compatibility` (Mobile GLES3 / ASTC / ETC2)  
**Target Device Profile**: 720p Landscape, Locked 30 FPS, Android Low-Spec Hardware  
**Author**: Test Writer: E2E Testing Track Orchestration Specialist  

---

## 1. Executive Summary & Testing Architecture Overview

Sector Zero: Lockdown is a mobile-first stationary 3D zombie first-person shooter transitioning to a DEAD TARGET style realistic visual, tactical, and audio overhaul. Because the target platform is resource-constrained mobile hardware running under Godot 4's `gl_compatibility` backend, this End-to-End (E2E) Testing Infrastructure enforces a strict **4-Tier Testing Model**:

```
+-----------------------------------------------------------------------------------+
|                        TIER 4: REAL-WORLD MOBILE WORKLOAD                         |
|   gl_compatibility Draw Calls (<100) | Dynamic Light Caps (<=3) | ASTC/ETC2 VRAM   |
|   Stable 30 FPS Frame Cadence | Headless Clean Execution | Zero Memory Leaks      |
+-----------------------------------------------------------------------------------+
                                          ▲
+-----------------------------------------------------------------------------------+
|                     TIER 3: CROSS-FEATURE COMBINATIONS                            |
|   Minigun in Tram Station Arena | ADS Reload Under Multi-Quadrant Zombie Melee    |
|   Flatline 2.5x Headshot Burst on Fast Zombie | CAR SMG to Shotgun Switch on Rush  |
|   Armory Upgrade Matrix Propagation to Live HitZone Raycast Mechanics            |
+-----------------------------------------------------------------------------------+
                                          ▲
+-----------------------------------------------------------------------------------+
|                     TIER 2: BOUNDARY & CORNER CASES                               |
|   Empty Mag Auto-Reload | Zero Reserve Ammo | Rapid Weapon Switching Stress       |
|   Extreme Camera Pitch Bounds (-65° / +65°) | 360° Continuous Yaw Revolution      |
|   Out-of-Bounds Zombie Clamping | Reload Interruption / Cancel Graceful Recovery  |
+-----------------------------------------------------------------------------------+
                                          ▲
+-----------------------------------------------------------------------------------+
|                         TIER 1: FEATURE COVERAGE                                  |
|   >= 5 Verified Test Cases per Feature across all 14 Cataloged Overhaul Features  |
|   (F1 to F14): Weapons, Arenas, Lighting, PBR Materials, Gore VFX, Armory, AI    |
+-----------------------------------------------------------------------------------+
```

Every test case across all tiers is derived directly from authoritative requirements in `PROJECT.md` and `ORIGINAL_REQUEST.md`. Façade tests that unconditionally pass without asserting actual engine invariants are strictly prohibited.

---

## 2. System Under Test (SUT) & Feature Inventory Scope

The SUT encompasses the complete realistic 3D overhaul as defined in `PROJECT.md` § Feature Inventory:

| # | Feature ID | Feature Name | Core Component | Milestone | Authoritative Specification Reference |
|---|------------|--------------|----------------|-----------|---------------------------------------|
| 1 | **F1** | Curate Asset Folders & `.gdignore` Protection | FileSystem / Importer | M1 | `PROJECT.md` L16, L66-67 |
| 2 | **F2** | Realistic Urban Street Staging | `UrbanStreet.tscn` | M1 | `PROJECT.md` L17, L54-58, L70 |
| 3 | **F3** | Tram Station Transit Hub Arena | `RailwayStation.tscn` | M1 | `PROJECT.md` L18, L54-58, L70 |
| 4 | **F4** | Mobile PBR Lighting & Atmosphere | `WorldEnvironment` / `DirectionalLight3D` | M1 | `PROJECT.md` L19, L57 |
| 5 | **F5** | Flatline AR Integration | `flatline.tres` / `flatline.tscn` | M2 | `PROJECT.md` L20, L42-46, L68 |
| 6 | **F6** | CAR SMG Integration | `car_smg.tres` / `car_smg.tscn` | M2 | `PROJECT.md` L21, L42-46, L68 |
| 7 | **F7** | Rotary Minigun Integration | `minigun.tres` / `minigun.tscn` | M2 | `PROJECT.md` L22, L42-46, L68 |
| 8 | **F8** | Viewmodel Rig & Recoil Tuning | `Player.gd` / `FPSArms` | M2 | `PROJECT.md` L23, L42-47, L71 |
| 9 | **F9** | Armory 3D Inspection & Economy | `ArmoryUI.gd` / `SaveManager.gd` | M2 | `PROJECT.md` L24, L48-53, L72 |
| 10 | **F10** | Visceral Combat Feedback & Gore VFX | `HitZone.gd` / `BloodEffect.tscn` / `HUD.gd` | M3 | `PROJECT.md` L25, L59-64, L73 |
| 11 | **F11** | Mobile GLES3 Compatibility Safeguards | `project.godot` / `QualityManager.gd` | M3 | `PROJECT.md` L26, L9 |
| 12 | **F12** | Stationary 360° Combat Verification | `Zombie360Test.gd` / `Player.gd` | M4 | `PROJECT.md` L27, L54-64 |
| 13 | **F13** | Automated Headless E2E Regression Suite | `TestRunner.tscn` / `test_weapons_economy.gd` | M4 | `PROJECT.md` L28, L74 |
| 14 | **F14** | Forensic Integrity Audit | Project Tree / Licenses / Hashes | M4 | `PROJECT.md` L29 |

---

## 3. Tier 1: Comprehensive Feature Coverage (>=5 Tests per Feature)

### Feature 1 (F1): Curate Asset Folders & `.gdignore` Protection
- **TC-F01-01**: Curated Weapon GLB Assets: Assert existence and readability of curated models in `res://assets/3d/weapons/downloaded/` (`flatline_rifle.glb`, `car_smg.glb`, `minigun_m134.glb`, `combat_shotgun.glb`, `sniper_vantage.glb`).
- **TC-F01-02**: Curated Environment GLB Assets: Assert existence and valid import of `res://assets/3d/environments/railway_station.glb` and `res://assets/external/downloads/environments/street_city_buildings_8.glb`.
- **TC-F01-03**: `.gdignore` Bulk Asset Shielding: Verify that heavy external folders (`assets/external/downloads/environments/gtasa_grovestreet/`, `assets/external/vitruvian/`, `assets/external/city_props/`) contain `.gdignore` to prevent uncontrolled re-import storms.
- **TC-F01-04**: Texture Compression `.import` Invariant: Verify `.import` headers for curated assets enforce `compress/mode=2` or VRAM compression flags without uncompressed RGBA8 fallback.
- **TC-F01-05**: Clean Project File Tree Isolation: Assert that no test scratch files or runtime artifacts pollute root `.agents/` or non-whitelisted source folders.

### Feature 2 (F2): Realistic Urban Street Staging
- **TC-F02-01**: Scene Instantiation & Tree Hierarchy: Instantiate `res://scenes/environments/UrbanStreet.tscn`; verify root is `Node3D`, script is valid, and scene adds to tree without error.
- **TC-F02-02**: NavigationRegion3D Perimeter Coverage: Assert `NavigationRegion3D` exists with a baked `NavigationMesh` having `>= 4` vertices spanning the player combat area (bounds `>= 30m x 30m`).
- **TC-F02-03**: Asphalt PBR Material Fidelity: Inspect floor mesh; assert `material_override` is assigned to `mat_asphalt.tres` with roughness texture and dark aggregate albedo.
- **TC-F02-04**: Stationary Player Origin & Cover Obstacles: Assert Player child node exists at `Vector3(0, 0, 0)` and street obstacles (jersey barriers, vehicles) are present with non-null collision shapes.
- **TC-F02-05**: Dynamic Light Pass Budget: Count active lights in `UrbanStreet.tscn`; verify exactly 1 `DirectionalLight3D` (sun) and `<= 3` localized `OmniLight3D` nodes.

### Feature 3 (F3): Tram Station Transit Hub Arena
- **TC-F03-01**: Scene Instantiation & Tree Structure: Instantiate `res://scenes/environments/RailwayStation.tscn`; verify clean instantiation and addition to SceneTree.
- **TC-F03-02**: Platform & Track Geometry: Verify station transit mesh nodes (`train_tracks.obj`, `station_bench.obj`, `railway_station.glb`) are loaded with non-null meshes.
- **TC-F03-03**: 360-Degree Spawner Markers: Assert spawner positions cover 4 distinct quadrants around origin (Front `z < -10`, Back `z > 10`, Left `x < -10`, Right `x > 10`).
- **TC-F03-04**: Transit Navigation Mesh Invariant: Assert `NavigationRegion3D` contains a baked `NavigationMesh` with valid polygon count `>= 2` covering train platforms.
- **TC-F03-05**: Metro Ambience Audio Binding: Verify audio ambience player is bound to `res://audio/ambience/sfx_ambience_metro.wav`.

### Feature 4 (F4): Mobile PBR Lighting & Atmosphere
- **TC-F04-01**: Directional Sunlight Shadow Mode: In `UrbanStreet.tscn` and `RailwayStation.tscn`, inspect `DirectionalLight3D`; verify `shadow_enabled == true` and light color matches warm daylight/ambient tones.
- **TC-F04-02**: Filmic Tonemapping Configuration: Inspect `WorldEnvironment.environment`; assert `tonemap_mode == 2` (Filmic / ACES) for high-contrast post-apocalyptic grading.
- **TC-F04-03**: Zero-Glare Fog & Glow Controls: Assert `glow_bloom <= 0.2` and `ssao_enabled == false` (or guarded by QualityManager) to prevent white fog glare and GLES3 shader warnings.
- **TC-F04-04**: Procedural Skybox Calibration: Verify `WorldEnvironment.environment.sky` contains a valid `ProceduralSkyMaterial` with distinct top, horizon, and ground colors.
- **TC-F04-05**: Ambient Energy Mobile Range: Assert `ambient_light_energy` is bounded between `0.1` and `1.0` to preserve deep shadows without black crush or washed-out overexposure.

### Feature 5 (F5): Flatline AR Integration
- **TC-F05-01**: Resource Data Integrity: Load `res://resources/weapons/flatline.tres`; assert `weapon_id == "flatline"`, `base_damage == 36.0`, `headshot_multiplier == 2.2`, `base_mag_size == 32`, `base_fire_rate == 0.10`.
- **TC-F05-02**: Viewmodel Model Scene Instantiation: Load and instantiate `res://scenes/weapons/models/flatline.tscn`; assert root node name is `"flatline"`.
- **TC-F05-03**: MuzzleSocket Contract Compliance: Assert child node `"MuzzleSocket"` (`Node3D`) exists with forward position (`transform.origin.z < -0.3`).
- **TC-F05-04**: GLB Mesh Attachment: Assert child node `"Model"` contains valid mesh instances with non-null geometry extracted from `flatline_rifle.glb`.
- **TC-F05-05**: Audio & VFX Bindings: Assert `sound_set == "rifle"` and `muzzle_fx == "rifle"` with valid associated audio assets.

### Feature 6 (F6): CAR SMG Integration
- **TC-F06-01**: Resource Data Integrity: Load `res://resources/weapons/car_smg.tres`; assert `weapon_id == "car_smg"`, `base_damage == 26.0`, `headshot_multiplier == 2.2`, `base_mag_size == 28`, `base_fire_rate == 0.08`.
- **TC-F06-02**: Viewmodel Model Scene Instantiation: Load and instantiate `res://scenes/weapons/models/car_smg.tscn`; assert root node name is `"car_smg"`.
- **TC-F06-03**: MuzzleSocket Contract Compliance: Assert child node `"MuzzleSocket"` (`Node3D`) exists with forward position (`transform.origin.z < -0.3`).
- **TC-F06-04**: Rapid Cyclic Fire Rate: Verify `base_fire_rate` corresponds to `>= 750 RPM` (fire interval `<= 0.08s`), faster than assault rifle baseline.
- **TC-F06-05**: Tactical Reload Timing: Verify `base_reload_time <= 2.0s` reflecting lightweight SMG ergonomics.

### Feature 7 (F7): Rotary Minigun Integration
- **TC-F07-01**: Resource Data Integrity: Load `res://resources/weapons/minigun.tres`; assert `weapon_id == "minigun"`, `base_damage == 32.0`, `headshot_multiplier == 2.5`, `base_mag_size == 120`, `base_reserve_ammo >= 400`.
- **TC-F07-02**: Viewmodel Model Scene Instantiation: Load and instantiate `res://scenes/weapons/models/minigun.tscn`; assert root node name is `"minigun"`.
- **TC-F07-03**: MuzzleSocket Alignment: Assert child node `"MuzzleSocket"` exists at forward barrel terminus (`transform.origin.z <= -0.5`).
- **TC-F07-04**: Heavy Recoil & Spread Calibration: Verify `recoil >= 0.9` and `spread >= 0.03` reflecting heavy rotary platform kinetics.
- **TC-F07-05**: Sustained Fire Ammo Depletion: Verify continuous fire simulates rapid consumption without integer underflow or negative ammo.

### Feature 8 (F8): Viewmodel Rig & Recoil Tuning
- **TC-F08-01**: FPS Tactical Arms Attachment: Instantiate `res://scenes/player/Player.tscn`; assert `$Camera3D/FPSArms` is present and active with gloved SWAT mesh.
- **TC-F08-02**: Viewmodel Tactical Eye-Level Offset: Verify weapon container positioning matches tactical viewmodel standards (`transform.origin.x > 0.0`, `transform.origin.y < 0.0`, `transform.origin.z < 0.0`).
- **TC-F08-03**: Camera Recoil Kick & Recovery: Trigger player shot; assert `camera_kick > 0.0` and that recoil pitch returns towards baseline during subsequent physics frames.
- **TC-F08-04**: Procedural Lissajous Sway & Breathing: Verify `sway_amount > 0.0` and `breathing_speed > 0.0` in `Player.gd` producing smooth idle Lissajous motion.
- **TC-F08-05**: Dynamic Muzzle Flash & Light Positioning: Assert `MuzzleLight` is dynamically repositioned to match active weapon's `MuzzleSocket.global_position`.

### Feature 9 (F9): Armory 3D Inspection & Economy
- **TC-F09-01**: Armory UI Instantiation & Weapon Registry: Instantiate `res://scenes/UI/ArmoryUI.tscn`; assert `_populate_list()` registers all 16 cataloged weapons including `flatline`, `car_smg`, `minigun`.
- **TC-F09-02**: 3D Viewport Rotating Preview Pivot: Select `flatline`, `car_smg`, and `minigun`; assert `WeaponPivot` receives the corresponding 3D model instance and rotates over `_process(delta)`.
- **TC-F09-03**: 4-Stat Upgrade Matrix Scaling: For each new weapon, verify damage, magazine, reload, and accuracy scale monotonically across levels 0 to 4.
- **TC-F09-04**: Progressive Cost Curves ($200 to $3,000): Verify upgrade costs for all new weapons fall strictly within `$200` to `$3,000` with non-decreasing increments.
- **TC-F09-05**: SaveManager Persistence & Unlock State: Verify `SaveManager.unlock_weapon()` persists new weapon unlock to `SaveManager.data.unlocked_weapons`.

### Feature 10 (F10): Visceral Combat Feedback & Gore VFX
- **TC-F10-01**: Headshot Multiplier (2.5x Critical): Shoot `RealisticZombie` in `HeadHitZone`; assert `damage_multiplier == 2.5` and `hit_result.is_headshot == true`.
- **TC-F10-02**: Chest & Limb Multipliers: Assert `ChestHitZone.damage_multiplier == 1.0` and `LegsHitZone.damage_multiplier == 0.7`.
- **TC-F10-03**: Golden Hitmarker HUD Indication: Call `HUD.show_hitmarker(true)`; assert hitmarker tick visibility is enabled with golden/critical color.
- **TC-F10-04**: ImpactPool Pre-Allocated Blood Splatters: Verify `ImpactPool` pre-allocates `>= 16` blood splatter instances from `BloodEffect.tscn` with zero runtime stutter.
- **TC-F10-05**: Zombie Stagger & Death Transition: Deliver heavy shot to `RealisticZombie`; verify transition to `AIState.STAGGER` or `AIState.DEAD` with collision disabled.

### Feature 11 (F11): Mobile GLES3 Compatibility Safeguards
- **TC-F11-01**: Rendering Backend Configuration: Assert `project.godot` sets `renderer/rendering_method="gl_compatibility"` for both desktop and mobile.
- **TC-F11-02**: Zero Forward+ Exclusives (SSAO Guard): Verify SSAO is disabled in `QualityManager.gd` under GLES3 to prevent driver-level GL warnings.
- **TC-F11-03**: ASTC / ETC2 Texture Compression: Assert `project.godot` specifies `textures/vram_compression/import_etc2_astc=true`.
- **TC-F11-04**: Low-Spec Orthogonal Shadow Map: Verify directional light uses `SHADOW_ORTHOGONAL` avoiding multi-cascade VRAM overhead.
- **TC-F11-05**: Console Warning & Shader Check: Headless console output verification for 0 shader compilation aborts and 0 missing pink material shaders.

### Feature 12 (F12): Stationary 360-Degree Combat Verification
- **TC-F12-01**: Stationary Origin Clamping: Assert player position remains bounded within `move_limit` (`<= 12.0m`) during combat.
- **TC-F12-02**: Unconstrained 360° Yaw Aiming: Rotate camera yaw `360.0` degrees; assert yaw updates smoothly without angle truncation or wrap clamping.
- **TC-F12-03**: 4-Quadrant Simultaneous Zombie Navigation: In `Zombie360Test.tscn`, verify zombies spawned at Front, Back, Left, Right all reduce distance to origin over 150 physics frames.
- **TC-F12-04**: Melee Attack Distance Transition: Verify approaching zombies trigger attack state upon entering melee threshold (`<= 1.7m`).
- **TC-F12-05**: Directional Damage HUD Indication: Simulate damage from rear; assert HUD directional damage indicator triggers appropriate red arc rotation.

### Feature 13 (F13): Automated Headless E2E Regression Suite
- **TC-F13-01**: Core TestRunner Suite Execution: Execute `godot --headless scenes/test/TestRunner.tscn`; assert exit code 0 and 54/54 PASS.
- **TC-F13-02**: 360 Combat Test Execution: Execute `godot --headless assets_tests/Zombie360Test.tscn`; assert exit code 0 and all 5 phases pass.
- **TC-F13-03**: Weapons Economy Test Execution: Execute `godot --headless -s scripts/Tools/test_weapons_economy.gd`; assert exit code 0 and 58/58 PASS.
- **TC-F13-04**: Realistic Overhaul Suite Execution: Execute `godot --headless scenes/test/test_realistic_overhaul.tscn`; assert exit code 0 and 100% PASS across all tiers.
- **TC-F13-05**: Zero Exit Leak / Memory Degradation: Verify test harness terminates cleanly without orphan node warnings or unhandled exceptions.

### Feature 14 (F14): Forensic Integrity Audit
- **TC-F14-01**: Zero Commercial IP / Pirated Assets: Verify all asset references are documented in `ASSET_LICENSES.md` with permissible licenses (CC0, MIT, CC-BY).
- **TC-F14-02**: Zero Hardcoded Test Cheats: Inspect codebase for conditional bypasses (e.g. `if is_test: return true`); verify tests execute actual game mechanics.
- **TC-F14-03**: Valid Scene Dependencies: Run project scanner to verify 0 broken `.tscn` / `.tres` dependency UIDs.
- **TC-F14-04**: Authentic Model Geometry: Assert all weapon and environment models contain genuine non-degenerate vertices and surface counts.
- **TC-F14-05**: Save Game Anti-Corruption / Atomic Writes: Verify `SaveManager` uses atomic temporary file writes with version format validation.

---

## 4. Tier 2: Boundary & Corner Cases

| Test Case ID | Boundary Scenario | Test Input / Action | Authoritative Expected Output |
|--------------|-------------------|---------------------|-------------------------------|
| **TC-B01** | Empty Mag Auto-Reload | Fire weapon until `current_ammo == 0` | Automatic reload triggers immediately; weapon does not freeze in firing state; `ammo_changed` signal emitted. |
| **TC-B02** | Zero Reserve Ammo | Set `reserve_ammo = 0`, fire empty mag, attempt reload | Reload action handles zero reserve gracefully; `current_ammo` remains 0; no negative ammo or crash. |
| **TC-B03** | Rapid Weapon Switching Stress | Switch weapons 10 times consecutively in rapid loop | Weapon index cycles safely within bounds `[0, weapon_count - 1]`; active model swaps cleanly without null reference. |
| **TC-B04** | Extreme Pitch Bounds Clamping | Apply extreme vertical look inputs (`pitch = -120°`, `pitch = +120°`) | Camera pitch is strictly clamped to `[min_pitch, max_pitch]` (`[-65.0°, +65.0°]`); no camera flipping. |
| **TC-B05** | Continuous 720° Multi-Turn Yaw | Rotate player yaw continuously by `720.0°` | Yaw handles continuous revolution without gimbal lock, precision loss, or NaN coordinates. |
| **TC-B06** | Out-of-Bounds Zombie Clamping | Spawn zombie far beyond arena perimeter (`(100, 0, 100)`) | Navigation agent clamps target to closest navmesh point; zombie advances towards origin without physics explosion. |
| **TC-B07** | Reload Interruption via Weapon Switch | Trigger reload, then immediately trigger weapon switch | Reload timer cleanly disconnects; new weapon equips in ready state; old weapon does not complete reload in background. |
| **TC-B08** | Zero / Overkill Lethal Damage | Deliver exact lethal damage (`HP -> 0.0`) vs extreme overkill (`1000.0 DMG`) | Both correctly trigger single death transition; collision shape disabled; `is_dead == true`; no double-death event. |

---

## 5. Tier 3: Cross-Feature Combinations

| Test Case ID | Combination Focus | Multi-Feature Integration Description | Authoritative Verification Criteria |
|--------------|-------------------|---------------------------------------|--------------------------------------|
| **TC-C01** | Minigun in Tram Station Arena | F3 (Tram Station) + F7 (Minigun) + F8 (Recoil Rig) + F10 (Audio/VFX): Equip M134 Minigun inside `RailwayStation.tscn`, perform sustained burst against approaching 360° zombie horde. | Minigun fires at 0.07s rate, muzzle light illuminates station platform, camera recoil recovers dynamically, ammo decrements accurately, 0 frame drops. |
| **TC-C02** | ADS Aim & Reload Under Melee Assault | F2 (Urban Street) + F5 (Flatline) + F8 (Player Rig) + F10 (Combat Feedback): Player aims down sights with Flatline while being struck by zombie melee attacks. | Player takes damage, HUD directional damage indicator and claw scratch trigger, reload completes or cancels gracefully, camera recoil and damage shake blend smoothly. |
| **TC-C03** | Flatline Headshot Critical on Fast Zombie | F5 (Flatline AR) + F10 (Gore VFX) + F12 (360 Combat): Player executes precision headshot on incoming Fast Zombie navigating from Left quadrant. | `HeadHitZone` triggers 2.5x critical (36.0 * 2.2 = 79.2 DMG), golden hitmarker displays on HUD, `BloodEffect` spawns at hit point, zombie enters stagger/death state. |
| **TC-C04** | CAR SMG Empty Mag Switch to Shotgun | F6 (CAR SMG) + F8 (Tactical Rig) + F10 (Hit Reactions): Empty CAR SMG magazine, quick-switch to Remington 870 under close-quarters Heavy Zombie rush. | Empty CAR SMG triggers auto-reload, switch overrides to shotgun, multi-pellet spread impacts Heavy Zombie, stagger threshold reached, kinetic knockback applied. |
| **TC-C05** | Armory Upgrade Matrix to Live Combat | F9 (Armory Economy) + F5 (Flatline) + F10 (HitZone Calculation): Purchase Flatline Level 3 Damage Upgrade in Armory, then spawn in arena and fire at test target. | Upgraded damage value (`flatline.get_damage(3)`) is transmitted into weapon firing raycast; target receives higher damage matching Armory UI matrix. |

---

## 6. Tier 4: Real-World Mobile Workload & Performance Budget

| Test Case ID | Metric / Guard | Performance Target | Authoritative Constraint & Measurement |
|--------------|----------------|--------------------|---------------------------------------|
| **TC-M01** | Dynamic Light Budget | `<= 3` Dynamic Lights | In `gl_compatibility`, active lights generate extra render passes. Total active dynamic lights per scene must not exceed 1 Directional + 3 OmniLights. |
| **TC-M02** | Target Frame Rate Locking | 30 FPS Fixed Cadence | `project.godot` specifies `run/max_fps=30` and `physics_ticks_per_second=60` ensuring consistent frame time on budget mobile chipsets. |
| **TC-M03** | ASTC / ETC2 Texture Compression | 100% Compressed VRAM | `project.godot` specifies `textures/vram_compression/import_etc2_astc=true`. Assets must not load uncompressed 4K desktop textures. |
| **TC-M04** | Headless Suite Integrity | 100% Pass / 0 Fatal Errors | Complete test runner executes headlessly with exit code 0, 0 unhandled script errors, and 0 missing shader errors. |
| **TC-M05** | Memory Lifecycle Stability | Flat Memory Curve | Repeated instantiation and destruction of environment, player, and weapon scenes must exhibit flat memory delta (`< 1.0 MB` growth across 5 cycles). |

---

## 7. Test Harness & Automation Execution

### Test Execution Commands

1. **Realistic Overhaul Standalone E2E Test Suite (All 4 Tiers)**:
   ```bash
   godot --headless scenes/test/test_realistic_overhaul.tscn
   ```
   *Alternative script runner*:
   ```bash
   godot --headless -s scenes/test/test_realistic_overhaul_e2e.gd
   ```

2. **Complete Full-Project Headless Regression Gate**:
   ```bash
   # 1. Realistic Overhaul 4-Tier E2E Suite
   godot --headless scenes/test/test_realistic_overhaul.tscn
   
   # 2. Baseline Gameplay Regression Suite (54 Tests)
   godot --headless scenes/test/TestRunner.tscn
   
   # 3. 360-Degree Combat Navigation Loop (5 Phases)
   godot --headless assets_tests/Zombie360Test.tscn
   
   # 4. Weapons & Economy Verification Suite (58 Tests)
   godot --headless -s scripts/Tools/test_weapons_economy.gd
   ```

### Exit Code & Reporting Protocol
- **Exit Code 0**: All test cases passed; zero engine warnings/crashes; console summary printed.
- **Exit Code 1**: One or more assertions failed; failure details logged with exact file, line number, and mismatch description.

---

## 8. Requirements Traceability Matrix

| Feature | Component | Tier 1 Test Case | Tier 2 Corner Case | Tier 3 Combination | Tier 4 Workload |
|---------|-----------|------------------|--------------------|--------------------|-----------------|
| F1 | Asset Importer | TC-F01-01..05 | TC-B06 | - | TC-M03 |
| F2 | Urban Street | TC-F02-01..05 | TC-B06 | TC-C02, TC-C03 | TC-M01, TC-M05 |
| F3 | Tram Station | TC-F03-01..05 | TC-B06 | TC-C01 | TC-M01, TC-M05 |
| F4 | PBR Lighting | TC-F04-01..05 | - | TC-C01 | TC-M01 |
| F5 | Flatline AR | TC-F05-01..05 | TC-B01, TC-B02 | TC-C02, TC-C03, TC-C05 | TC-M04 |
| F6 | CAR SMG | TC-F06-01..05 | TC-B01, TC-B03 | TC-C04 | TC-M04 |
| F7 | Rotary Minigun | TC-F07-01..05 | TC-B01, TC-B03 | TC-C01 | TC-M04 |
| F8 | Tactical Rig | TC-F08-01..05 | TC-B03, TC-B04, TC-B05, TC-B07 | TC-C01, TC-C02, TC-C04 | TC-M02 |
| F9 | Armory Economy | TC-F09-01..05 | - | TC-C05 | TC-M05 |
| F10 | Combat Feedback | TC-F10-01..05 | TC-B08 | TC-C02, TC-C03, TC-C04 | TC-M04 |
| F11 | Mobile GLES3 | TC-F11-01..05 | - | - | TC-M01, TC-M03 |
| F12 | 360° Combat | TC-F12-01..05 | TC-B04, TC-B05, TC-B06 | TC-C01, TC-C03 | TC-M02 |
| F13 | E2E Regression | TC-F13-01..05 | All | All | TC-M04 |
| F14 | Forensic Audit | TC-F14-01..05 | - | - | TC-M04 |

---
*Testing Infrastructure Specification Approved for Sector Zero: Lockdown Overhaul.*
