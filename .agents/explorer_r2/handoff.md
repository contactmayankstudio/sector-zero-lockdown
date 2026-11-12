# Handoff Report: Requirement R2 — Campaign Data Integrity & Mission Flow

**Agent**: `teamwork_preview_explorer` (explorer_r2)  
**Date**: 2026-09-18  
**Scope**: Requirement R2 (Campaign Data Integrity & Mission Flow) for *Sector Zero: Lockdown* (`/home/am/targetkill`)  
**Target Recipient**: Orchestrator (`237eaf46-e809-4bcf-b125-d5770dc95b5a`) & Worker Agents  

---

## 1. Observation

### 1.1 Mission Resource Inventory & Active Wave Normalization
Direct inspection of all 12 campaign mission files in `res://resources/missions/` and `res://resources/missions/mission_endless.tres` revealed:

| File Path | Mission ID | Display Name | Obj Type | Target | wave_count | waves.size() | Residual Wave 4? | Linked Scene Path |
|---|---|---|---|---|---|---|---|---|
| `mission_01.tres` | `mission_01` | First Contact | KILL (0) | 15 | 3 | **3** | No | `scenes/environments/UrbanStreet.tscn` |
| `mission_02.tres` | `mission_02` | Feral Pack | KILL (0) | 32 | 3 | **3** | No | `scenes/environments/AirportServiceRoad.tscn` |
| `mission_03.tres` | `mission_03` | Crossfire | KILL (0) | 22 | 3 | **4** | **YES** | `scenes/environments/RailwayStation.tscn` |
| `mission_04.tres` | `mission_04` | Rat King | SURVIVE (1)| 0 | 3 | **4** | **YES** | `scenes/environments/AbandonedTrain.tscn` |
| `mission_05.tres` | `mission_05` | Containment Breach| KILL (0) | 30 | 3 | **4** | **YES** | `scenes/environments/DarkIndustrial.tscn` |
| `mission_06.tres` | `mission_06` | Patient Zero | KILL (0) | 25 | 3 | **4** | **YES** | `scenes/environments/ApartmentComplex.tscn` |
| `mission_07.tres` | `mission_07` | Dead Mall | KILL (0) | 30 | 3 | **4** | **YES** | `scenes/environments/ApartmentComplex.tscn` |
| `mission_08.tres` | `mission_08` | Blackout | SURVIVE (1)| 0 | 3 | **4** | **YES** | `scenes/environments/NightCityStreet.tscn` |
| `mission_09.tres` | `mission_09` | Fortified | KILL (0) | 35 | 3 | **4** | **YES** | `scenes/environments/AirportTerminal.tscn` |
| `mission_10.tres` | `mission_10` | Mutation | KILL (0) | 30 | 3 | **4** | **YES** | `scenes/environments/AbandonedTrain.tscn` |
| `mission_11.tres` | `mission_11` | Overrun | SURVIVE (1)| 0 | 3 | **4** | **YES** | `scenes/environments/DarkIndustrial.tscn` |
| `mission_12.tres` | `mission_12` | Lockdown | BOSS (2) | 1 | 3 | **4** | **YES** | `scenes/environments/FinalLockdown.tscn` |
| `mission_endless.tres` | `mission_endless`| Endless Survival | SURVIVE (1)| 999 | 999 | **0** | No (dynamic) | `scenes/environments/NightCityStreet.tscn` |

- **Wave count vs. array size discrepancy**: In `mission_03.tres` through `mission_12.tres` (10 of 12 mission files), the export property `wave_count` is set to `3`, but the underlying `waves` Array contains **4 wave dictionaries** (`waves.size() == 4`).
- **Contract test evasion**: In `scripts/Tools/test_campaign_contract.gd`, line 25 states:
  ```gdscript
  _check("Three active waves: %s" % mission.mission_id, mission.wave_count == 3 and mission.waves.size() >= 3)
  ```
  The condition checks `waves.size() >= 3` instead of `waves.size() == 3`. This masked the presence of residual 4th wave definitions in 10 missions.
- **Residual wave content**:
  - `mission_03.tres`: Wave 4 contains 5 normal, 4 dog, 1 heavy (10 enemies).
  - `mission_04.tres`: Wave 4 contains 6 dog, 5 fast, 2 heavy (13 enemies).
  - `mission_05.tres`: Wave 4 contains 5 fast, 4 dog, 2 spitter (11 enemies).
  - `mission_06.tres`: Wave 4 contains 4 heavy, 4 spitter, 3 fast (11 enemies).
  - `mission_07.tres`: Wave 4 contains 3 heavy, 4 fast, 4 dog, 2 spitter (13 enemies).
  - `mission_08.tres`: Wave 4 contains 5 heavy, 5 fast, 4 dog, 3 spitter (17 enemies).
  - `mission_09.tres`: Wave 4 contains 6 heavy, 5 dog, **1 boss** (12 enemies).
  - `mission_10.tres`: Wave 4 contains 5 heavy, 4 spitter, 4 fast, **1 boss** (14 enemies).
  - `mission_11.tres`: Wave 4 contains 6 heavy, 5 fast, 4 dog, 4 spitter, **1 boss** (20 enemies).
  - `mission_12.tres`: Wave 4 contains 6 heavy, 6 fast, 5 dog, 4 spitter, **2 boss** (23 enemies).

### 1.2 Enemy Archetype Inconsistencies in Missions 4 and 10
- In `resources/missions/mission_04.tres`:
  - Line 19: `spawn_config = [{"type": "dog", "weight": 0.5}, {"type": "fast", "weight": 0.3}, {"type": "reptile", "weight": 0.2}]`
  - Line 20: Wave 3 contains `{"enemy_type": "reptile", "count": 1, "spawn_direction": "front", "delay": 2.0}`
- In `resources/missions/mission_10.tres`:
  - Line 19: `spawn_config = [{"type": "mutant", "weight": 0.4}, {"type": "heavy", "weight": 0.3}, {"type": "spitter", "weight": 0.3}]`
  - Line 20: Waves 1, 2, and 3 all spawn `{"enemy_type": "mutant", ...}`.
- In `scripts/Zombies/EnemyBase.gd` (lines 53-160):
  - Archetypes defined in `archetype_data`: `"normal"`, `"fast"`, `"heavy"`, `"special"`, `"spitter"`, `"dog"`, `"boss"`, `"rat"`, `"rats"`, `"bat"`.
  - Neither `"reptile"` nor `"mutant"` exists in `archetype_data`.
  - `EnemyBase._apply_archetype()` (line 265) defaults missing keys to `archetype_data["normal"]`. Both `"reptile"` and `"mutant"` silently instantiate as standard normal zombies with mismatched visual meshes.

### 1.3 Linked Environment Scenes & Spawn Markers
- Parsing all 9 environment scenes (`UrbanStreet.tscn`, `AirportServiceRoad.tscn`, `RailwayStation.tscn`, `AbandonedTrain.tscn`, `DarkIndustrial.tscn`, `ApartmentComplex.tscn`, `NightCityStreet.tscn`, `AirportTerminal.tscn`, `FinalLockdown.tscn`):
  - Every scene defines all four canonical directional spawn markers: `SpawnFront`, `SpawnBack`, `SpawnLeft`, `SpawnRight`.
  - In every scene, `ZombieSpawner` (running `scripts/GameManager.gd`) exports `spawn_points = [NodePath(...)]` containing all defined directional spawn nodes.
  - `FinalLockdown.tscn` contains an additional `BossSpawn` node at `(0, 0, -14)` exported in `spawn_points`.
  - All external resource dependencies in all 9 scenes exist on disk (100% resolution).
- **Critical Scene Issue (P0 Asset Provenance Violation)**:
  - `scenes/environments/UrbanStreet.tscn` lines 11 and 55:
    ```ini
    [ext_resource type="PackedScene" path="res://scenes/environments/GTAGroveStreetDirect.tscn" id="17_gta_grove"]
    ...
    [node name="GTAGroveStreet" parent="." instance=ExtResource("17_gta_grove")]
    ```
  - `PROJECT_STATUS.md` line 16 claimed: `Replaced the active GTA Grove Street reference in scenes/environments/UrbanStreet.tscn with street_city_7_for_games_free.glb.`
  - Direct file inspection proves that `UrbanStreet.tscn` **still directly instantiates `GTAGroveStreetDirect.tscn`** (a 22.6 MB scene file containing embedded base64 meshes/textures from GTA Grove Street). This is a severe legal provenance failure and causes 30+ second load delays in headless tests.

### 1.4 Mission Progression Deadlock in `scripts/GameManager.gd`
In `scripts/GameManager.gd` lines 330-342:
```gdscript
330: 	var total_waves = mission.wave_count if mission else 3
331: 	if current_wave < total_waves:
332: 		if not is_inside_tree() or not get_tree():
333: 			return
334: 		if mission.objective_type == MissionData.ObjectiveType.SURVIVE_WAVES:
335: 			await get_tree().create_timer(wave_delay).timeout
336: 			if is_inside_tree():
337: 				start_next_wave()
338: 		else:
339: 			if mission_mgr and mission_mgr.kill_count < mission.target_count:
340: 				await get_tree().create_timer(wave_delay).timeout
341: 				if is_inside_tree():
342: 					start_next_wave()
```
- In Mission 12 (`mission_12.tres`):
  - `objective_type = 2` (`BOSS_KILL`)
  - `target_count = 1`
  - `wave_count = 3`
  - Wave 1 spawns 8 enemies. When all 8 are killed, `mission_mgr.kill_count` becomes 8.
  - `_check_wave_end()` is called with `current_wave = 1` and `total_waves = 3`.
  - Condition `mission.objective_type == SURVIVE_WAVES` evaluates to `false`.
  - In the `else` branch, line 339 evaluates: `if mission_mgr and mission_mgr.kill_count < mission.target_count:`.
  - `8 < 1` is **`false`**.
  - `start_next_wave()` is **NEVER CALLED**.
  - Meanwhile, in `scripts/MissionManager.gd` line 143:
    `if wave_count >= current_mission.wave_count and boss_kill_count >= current_mission.target_count:`
    `1 >= 3` is `false`, so mission completion is never triggered either.
  - **Result**: Mission 12 hangs permanently at the end of Wave 1. Wave 2 and Wave 3 (where the Boss spawns) cannot execute.

### 1.5 Boss Objective Completion Logic & Duplicate Scripts
- In `scripts/MissionManager.gd` (the registered Autoload in `project.godot`), lines 142-145:
  ```gdscript
  MissionData.ObjectiveType.BOSS_KILL:
      if wave_count >= current_mission.wave_count and boss_kill_count >= current_mission.target_count:
          completed = true
  ```
  The boss objective CANNOT trigger early completion before all waves are cleared in `scripts/MissionManager.gd`, because `wave_count >= current_mission.wave_count` is strictly enforced.
- In `scripts/Missions/MissionManager.gd` (an unreferenced duplicate file), lines 114-116:
  ```gdscript
  MissionData.ObjectiveType.BOSS_KILL:
      if boss_kill_count >= current_mission.target_count:
          completed = true
  ```
  This duplicate script lacks wave validation and lacks the `_is_finishing` re-entrancy guard.

### 1.6 Idempotency and Restart Vulnerabilities
- `SaveManager.claim_mission_reward(mission_id, reward_amount)` in `scripts/SaveManager.gd` (lines 206-212) verifies `if is_mission_completed(mission_id): return false`. Single-claim cash rewards are idempotent.
- In `scripts/MissionManager.gd` (lines 154-159):
  ```gdscript
  if success and is_inside_tree() and DisplayServer.get_name() != "headless":
      Engine.time_scale = 0.25
      await get_tree().create_timer(1.2, true, false, true).timeout
      Engine.time_scale = 1.0
  ```
  If a player triggers a restart (`HUD._execute_restart()`) or exits to menu during this unscaled 1.2-second slow-motion await, `current_mission` remains dirty or becomes reassigned, but the deferred code resumes after the await, writing stats and resetting `current_mission = null`, corrupting the newly started mission state.

### 1.7 Endless Mode Unlock Mapping
- In `resources/missions/mission_endless.tres` line 14:
  `unlock_requirement_id = "12-7"`
- In `scripts/SaveManager.gd` line 20:
  `LEGACY_MISSION_MAP` maps `"mission_12": "12-7"`.
- While this permits unlocking when completing `mission_12` via the legacy dictionary, it decouples `mission_endless.tres` from the standard 12-mission naming scheme (`"mission_01"` to `"mission_12"`), creating fragility if `LEGACY_MISSION_MAP` is cleaned up.

---

## 2. Logic Chain

1. **Premise**: Per Requirement R1 and R2 in `ORIGINAL_REQUEST.md`, each campaign mission must contain exactly 3 large waves, and the campaign contract test must strictly verify this.
   - **Observation Reference**: Section 1.1 shows missions 03-12 have `waves.size() == 4`, while `test_campaign_contract.gd:25` only checked `waves.size() >= 3`.
   - **Inference**: Wave 4 was appended during earlier 4-wave prototyping or migration. The engine property `wave_count = 3` causes `GameManager.gd` to never spawn wave 4, leaving wave 4 as orphaned residual data. `test_campaign_contract.gd` had its assertion weakened to `>= 3` to artificially pass despite the dirty data.

2. **Premise**: Waves must instantiate predictable enemy variants with correct attributes.
   - **Observation Reference**: Section 1.2 shows `"reptile"` in `mission_04.tres` and `"mutant"` in `mission_10.tres`, while neither exists in `EnemyBase.gd:archetype_data`.
   - **Inference**: Unrecognized archetype strings cause `EnemyBase.gd:265` to silently fall back to `"normal"` zombie stats and mesh, breaking intended mission design and atmosphere.

3. **Premise**: In a stationary wave shooter, clearing wave $N$ ($N < \text{total\_waves}$) must trigger a countdown and launch wave $N+1$.
   - **Observation Reference**: Section 1.4 shows `GameManager.gd:338` guards wave advancement behind `mission_mgr.kill_count < mission.target_count` for all non-`SURVIVE_WAVES` objectives.
   - **Inference**: For `BOSS_KILL` (Mission 12), `target_count` is 1 (the boss kill count). Wave 1 spawns 8 enemies. Once wave 1 is eliminated, `kill_count == 8`. Because $8 < 1$ is false, `start_next_wave()` is never called. And because `wave_count` is only 1 (not 3), `MissionManager.gd` does not complete the mission. The game enters an irrecoverable hang at the end of Wave 1.
   - **Inference**: For `KILL_COUNT` missions, gating wave transitions on `kill_count < target_count` is also erroneous: if a player achieves the kill target in wave 2, wave 3 will not launch, yet `wave_count < 3` blocks mission completion. Wave transitions must be unconditional for all $current\_wave < total\_waves$.

4. **Premise**: Boss missions must never complete prior to the clearing of all configured waves.
   - **Observation Reference**: Section 1.5 shows canonical `MissionManager.gd:143` checks `wave_count >= current_mission.wave_count and boss_kill_count >= current_mission.target_count`.
   - **Inference**: The active Autoload correctly requires all 3 waves to complete before granting victory. However, the duplicate script `scripts/Missions/MissionManager.gd:115` omits the wave check and would cause premature completion if ever called.

5. **Premise**: Asynchronous operations in mission completion coroutines must be resilient to scene reloads.
   - **Observation Reference**: Section 1.6 shows `MissionManager.gd:157` pauses execution for 1.2s via `await` before mutating `current_mission`.
   - **Inference**: Coroutine re-entrancy without validating that `current_mission` is still the mission being completed creates a race condition if `_execute_restart()` is invoked during the slow-mo window.

---

## 3. Caveats

- **No modifications to game code were performed**: In strict adherence to read-only constraints, all tests and parsers were executed from `.agents/explorer_r2/`. No files in `resources/`, `scenes/`, or `scripts/` were edited.
- **GTA Grove Street replacement**: `UrbanStreet.tscn` was inspected via text parsing and byte inspection. The file definitely contains `GTAGroveStreetDirect.tscn`. The replacement asset `street_city_7_for_games_free.glb` referenced in `PROJECT_STATUS.md` exists in `scenes/environments/models/` but was never wired into `UrbanStreet.tscn`.
- **Sub-campaign (84 missions)**: The repository contains both a 12-mission campaign (`resources/missions/mission_01.tres` through `mission_12.tres`) and an 84-mission sub-campaign (`resources/missions/campaign/mission_01_01.tres` to `mission_12_07.tres`). The `MissionSelectUI.gd` supports both via Intel List and Tactical Map. The findings in this report focus on the canonical 12 campaign missions and Endless mode per Requirement R2.

---

## 4. Conclusion

Requirement R2 cannot be satisfied in the current codebase without resolving four primary blockers:

1. **P0 Wave Data Corruption**: Missions 03 through 12 contain residual 4th wave dictionaries in their `waves` array. `test_campaign_contract.gd` fails to catch this due to a loose `>= 3` check.
2. **P0 Mission 12 Wave Deadlock**: `GameManager.gd:338` prevents Mission 12 from ever reaching Wave 2 or Wave 3 because `kill_count (8) < target_count (1)` evaluates to `false`.
3. **P0 Copyright Asset in Environment Scene**: `scenes/environments/UrbanStreet.tscn` still actively instantiates `GTAGroveStreetDirect.tscn` (22.6 MB), directly contradicting `PROJECT_STATUS.md` and posing an immediate legal provenance risk.
4. **P1 Invalid Enemy Archetypes & Duplicate Scripts**: Missions 04 and 10 reference non-existent archetypes (`reptile`, `mutant`), and duplicate `scripts/Missions/MissionManager.gd` contains stale, non-idempotent logic.

---

## 5. Verification Method & Step-by-Step Fix Recommendations

### Step-by-Step Worker Action Plan

#### Task 1: Fix GameManager Wave Advance Logic (`scripts/GameManager.gd`)
- **Location**: `scripts/GameManager.gd`, lines 330-342
- **Current Code**:
  ```gdscript
  var total_waves = mission.wave_count if mission else 3
  if current_wave < total_waves:
      if not is_inside_tree() or not get_tree():
          return
      if mission.objective_type == MissionData.ObjectiveType.SURVIVE_WAVES:
          await get_tree().create_timer(wave_delay).timeout
          if is_inside_tree():
              start_next_wave()
      else:
          if mission_mgr and mission_mgr.kill_count < mission.target_count:
              await get_tree().create_timer(wave_delay).timeout
              if is_inside_tree():
                  start_next_wave()
  ```
- **Replacement Code**:
  ```gdscript
  var total_waves = mission.wave_count if mission else 3
  if current_wave < total_waves:
      if not is_inside_tree() or not get_tree():
          return
      await get_tree().create_timer(wave_delay).timeout
      if is_inside_tree():
          start_next_wave()
  ```
- **Rationale**: For all missions, if `current_wave < total_waves`, the game must transition to the next wave once the current wave's enemies are cleared.

#### Task 2: Truncate Residual 4th Waves in Mission Resources
- **Target Files**: `resources/missions/mission_03.tres` through `mission_12.tres` (10 files).
- **Action**: In each file, remove the 4th dictionary element from the `waves` JSON array so that `waves` contains exactly 3 wave objects (`wave_num: 1`, `wave_num: 2`, `wave_num: 3`).

#### Task 3: Normalize Archetypes in Missions 04 and 10
- **Target File 1**: `resources/missions/mission_04.tres`
  - Change `"reptile"` in `spawn_config` and `Wave 3` to `"rat"` or `"dog"`. (`"rat"` is already supported in `EnemyBase.gd`).
- **Target File 2**: `resources/missions/mission_10.tres`
  - Change `"mutant"` in `spawn_config` and `Waves 1, 2, 3` to `"special"` or `"heavy"`. (`"special"` is defined in `EnemyBase.gd`).

#### Task 4: Clean Up Urban Street Scene (`scenes/environments/UrbanStreet.tscn`)
- Replace the `GTAGroveStreetDirect.tscn` instance with the CC0/cleared asset `res://scenes/environments/models/street_city_7_for_games_free.glb` as originally specified in `PROJECT_STATUS.md`.

#### Task 5: Tighten Campaign Contract Test (`scripts/Tools/test_campaign_contract.gd`)
- **Location**: `scripts/Tools/test_campaign_contract.gd`, line 25
- **Change**:
  ```gdscript
  _check("Exactly three active waves: %s" % mission.mission_id, mission.wave_count == 3 and mission.waves.size() == 3)
  ```
- Add verification for `res://resources/missions/mission_endless.tres`:
  ```gdscript
  var endless = load("res://resources/missions/mission_endless.tres") as MissionData
  _check("Endless mode resource loads", endless != null)
  _check("Endless mode is_endless flag", endless.is_endless == true)
  _check("Endless mode scene exists", ResourceLoader.exists(endless.scene_path))
  ```

#### Task 6: Harden Coroutine in `scripts/MissionManager.gd` & Remove Duplicate
- Delete or archive `scripts/Missions/MissionManager.gd`.
- In `scripts/MissionManager.gd:finish_mission()`:
  ```gdscript
  func finish_mission(success: bool):
      if not current_mission or _is_finishing:
          return
      _is_finishing = true
      var target_mission = current_mission
      
      if success and is_inside_tree() and DisplayServer.get_name() != "headless":
          Engine.time_scale = 0.25
          await get_tree().create_timer(1.2, true, false, true).timeout
          Engine.time_scale = 1.0
          if current_mission != target_mission or not is_inside_tree():
              _is_finishing = false
              return
  ```

### Verification Commands

1. **Verify Contract Test (after fixes)**:
   ```bash
   godot --headless --script scripts/Tools/test_campaign_contract.gd
   ```
   *Pass criteria*: Output emits `0 FAILED` and exit code is `0`.

2. **Run Explorer Audit Harness**:
   ```bash
   godot --headless --script .agents/explorer_r2/verify_r2_audit.gd
   ```
   *Pass criteria*: All 34 checks in the audit suite report `[PASS]` with 0 failures.

3. **Verify Scene Dependencies**:
   ```bash
   python3 .agents/explorer_r2/check_scene_deps.py
   python3 .agents/explorer_r2/parse_scenes.py
   ```
   *Pass criteria*: All 9 scenes resolve all dependencies and define Front/Back/Left/Right spawn points.
