# Scope: Sector Zero: Lockdown Release Polish (orchestrator_9)

## Architecture
- **Engine**: Godot Engine 4.3.stable.official under `gl_compatibility` renderer.
- **Platform**: Android ARM64, Mobile touch controls, 720p 30 FPS target.
- **Core Systems**:
  - **Campaign**: 12 canonical missions, normalized to 3 active waves per mission, plus Endless survival mode.
  - **Weapons & Economy**: 10 verified CC0 3D weapons with 4-stat upgrade matrix and persistent Cash economy.
  - **Enemy AI**: 5 verified CC0 zombie archetypes (`normal`, `fast`, `heavy`, `special`, `dog`, `boss`) with HitZone multipliers.
  - **Asset Provenance**: 100% CC0 / MIT verified assets; zero commercial IP or quarantined assets in production scenes or exports.
  - **Export Infrastructure**: Headless Android APK export via Godot CLI with portable configuration and comprehensive exclude filters.
  - **Test Infrastructure**: Multi-tier headless regression suites unified by a deterministic Master Test Runner.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | R3.1 Sever GTA Grove Street | Remove GTAGroveStreetDirect from UrbanStreet.tscn & replace with clean props | M1 | Survey (Explorer R3/R4, R2) |
| 2 | R3.2 CC0 Weapon Normalization | Rewire Player.gd, ArmoryUI.gd, Weapon.gd from downloaded/ to 10 clean CC0 weapons | M1 | Survey (Explorer R3/R4) |
| 3 | R3.3 CC0 Zombie Normalization | Rewire RealisticZombie to clean CC0 meshes, remove ValveBiped bones & RealDoom | M1 | Survey (Explorer R3/R4) |
| 4 | R3.4 Segregate Suspect Assets | Quarantine downloaded/, Real*.scn, and delete stale references | M1 | Survey (Explorer R3/R4) |
| 5 | R3.5 Asset Licenses Manifest | Update ASSET_LICENSES.md to accurately document legal provenance for all bundled assets | M1 | Survey (Explorer R3/R4) |
| 6 | R2.1 Wave Progression Fix | Fix GameManager.gd:338 wave advance check to eliminate M12 hang | M2 | Survey (Explorer R2) |
| 7 | R2.2 Truncate 4th Waves | Remove residual 4th wave dictionaries from mission_03 to mission_12 (exact 3 waves) | M2 | Survey (Explorer R2) |
| 8 | R2.3 Normalize Archetypes | Replace reptile (M04) with rat and mutant (M10) with special in mission data | M2 | Survey (Explorer R2) |
| 9 | R2.4 Mission Manager Hardening | Prevent restart race condition in finish_mission() & remove duplicate script | M2 | Survey (Explorer R2) |
| 10 | R2.5 Campaign Contract Test | Assert waves.size() == 3 and verify endless mode resource in contract test | M2 | Survey (Explorer R2) |
| 11 | R4.1 Export Exclude Filters | Update export_presets.cfg exclude_filter to exclude quarantine, raw, & tests | M3 | Survey (Explorer R3/R4) |
| 12 | R4.2 Portable Export Config | Make export_presets.cfg paths portable (relative paths, portable JDK/keystore) | M3 | Survey (Explorer R3/R4) |
| 13 | R4.3 Android Export Verification | Execute headless Android export command and verify clean APK size (<150MB) | M3 | Survey (Explorer R3/R4) |
| 14 | R1.1 TestRunner.gd Fixes | Fix 7 failing assertions and exit code contract in TestRunner.gd (54/54 PASS) | M4 | Survey (Explorer R1) |
| 15 | R1.2 Clean Test Assets | Replace stale polyhaven material in Zombie360Test.tscn & repair test_mission1_gameplay.gd | M4 | Survey (Explorer R1) |
| 16 | R1.3 Master Test Runner | Implement scripts/Tools/run_all_headless_tests.gd with deterministic summary and exit code | M4 | Survey (Explorer R1) |
| 17 | Final E2E Regression | Run complete headless regression suite across all 4 tiers with 100% pass | M5 | TEST_INFRA.md |
| 18 | Final Adversarial Hardening | Challenger stress-tests for edge cases and regressions | M5 | Orchestrator Protocol |
| 19 | Forensic Integrity Audit | Independent auditor verification of authentic implementation and 0 cheats | M5 | Orchestrator Protocol |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Clean Asset Provenance & License Quarantine (R3) | Sever GTA Grove Street, downloaded/ weapons, Valve/Doom zombie rigs; rewire to clean CC0 weapons and zombies; update ASSET_LICENSES.md | none | IN_PROGRESS |
| M2 | Campaign Data Integrity & Mission Flow (R2) | Fix GameManager.gd wave advance deadlock, truncate 4th waves in M03-M12, normalize archetypes, tighten campaign contract test | M1 | PLANNED |
| M3 | Android Build & Export Readiness (R4) | Update export_presets.cfg filters, portable JDK/keystore configs, verify headless Android export & reduced APK size | M1 | PLANNED |
| M4 | Headless Test Infrastructure & TestRunner Fixes (R1) | Fix 7 stale assertions in TestRunner.gd (54/54 PASS), clean Zombie360Test materials, implement unified master test runner | M1, M2 | PLANNED |
| M5 | E2E Regression, Adversarial Verification & Forensic Audit | Run master test suite, challenger stress-testing, and full forensic integrity audit | M1, M2, M3, M4 | PLANNED |

## Interface Contracts
### Asset References ↔ Scenes & Scripts
- All weapon models instantiated by `scenes/weapons/models/` must reside in `assets/3d/weapons/` (CC0).
- All zombie models instantiated by `scenes/zombies/models/` must reside in `assets/3d/zombies/` (CC0).
- No file path in `.tscn`, `.tres`, or `.gd` may contain `quarantine_suspect_assets`, `real/`, or `downloaded/`.

### Wave Advancement Contract (`GameManager.gd` ↔ `MissionData`)
- If `current_wave < total_waves`, `GameManager` must unconditionally transition to `start_next_wave()` after `wave_delay` once active wave enemies are cleared.
- Every mission resource in `resources/missions/mission_*.tres` must have `wave_count == 3` and `waves.size() == 3`.

### Headless Test Runner Exit Code Contract
- `exit code 0`: 100% of executed assertions passed, 0 failures, 0 uncaught errors.
- `exit code 1`: >= 1 assertion failed or script execution aborted.

## Code Layout
- `scenes/environments/`: Active environment scenes (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`, `RailwayStation.tscn`, etc.)
- `resources/missions/`: Canonical mission resources (`mission_01.tres` through `mission_12.tres`, `mission_endless.tres`)
- `assets/3d/weapons/`: Clean CC0 weapon models (`usp45.glb`, `m4a1.glb`, `remington870.glb`, `ak47.glb`, `desert_eagle.glb`, `mp5.glb`, `awp.glb`, `combat_knife.glb`, `crossbow.glb`, `grenade_launcher.glb`)
- `assets/3d/zombies/`: Clean CC0 zombie models (`zombie_normal.glb`, `zombie_fast.glb`, `zombie_heavy.glb`, `zombie_boss.glb`, `infected_dog.glb`)
- `scripts/`: Gameplay logic (`GameManager.gd`, `MissionManager.gd`, `SaveManager.gd`, `Player.gd`)
- `scripts/Tools/`: Test suites and headless runners (`test_campaign_contract.gd`, `test_weapons_economy.gd`, `run_all_headless_tests.gd`)
- `scenes/test/`: `TestRunner.tscn`, `test_realistic_overhaul.tscn`
