## 2026-09-07T21:56:00Z
You are Worker M1: Realistic Environment Staging & Mobile Lighting Worker.
Working directory: /home/am/targetkill/.agents/worker_m1_environment
Original request path: /home/am/targetkill/.agents/ORIGINAL_REQUEST.md
Project specification: /home/am/targetkill/PROJECT.md

Read the 3 Explorer handoff reports before implementing:
- /home/am/targetkill/.agents/explorer_m1_urban/handoff.md
- /home/am/targetkill/.agents/explorer_m1_tram/handoff.md
- /home/am/targetkill/.agents/explorer_m1_lighting/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Exclusive File Ownership:
- /home/am/targetkill/real assent grafix import karna he/.gdignore
- /home/am/targetkill/assets/3d/environments/street_city_7.glb
- /home/am/targetkill/assets/3d/environments/street_buildings.glb
- /home/am/targetkill/assets/3d/environments/tram_station.glb
- /home/am/targetkill/resources/environments/env_post_apocalypse_day.tres
- /home/am/targetkill/scenes/environments/UrbanStreet.tscn
- /home/am/targetkill/scenes/environments/RailwayStation.tscn
- /home/am/targetkill/scenes/environments/DarkIndustrial.tscn
- /home/am/targetkill/scenes/environments/AbandonedTrain.tscn
- /home/am/targetkill/scenes/environments/FinalLockdown.tscn
- /home/am/targetkill/scripts/QualityManager.gd

Implementation Tasks:
1. Asset Protection & Curation:
   - Create empty file `/home/am/targetkill/real assent grafix import karna he/.gdignore` to prevent Godot import storms.
   - Clean stale `.import` files in `real assent grafix import karna he/`.
   - Copy `real assent grafix import karna he/street_city_7_for_games_free(1).glb` (13.3 MB) to `assets/3d/environments/street_city_7.glb`.
   - Copy `real assent grafix import karna he/street_city_buildings_8.glb` to `assets/3d/environments/street_buildings.glb`.
   - Copy `real assent grafix import karna he/tram_station(1).glb` (85.7 MB) to `assets/3d/environments/tram_station.glb`.

2. Mobile PBR Lighting & Environment Resource:
   - Create `resources/environments/env_post_apocalypse_day.tres` with the exact ProceduralSkyMaterial, ambient fill (energy 0.8), filmic tonemapping (tonemap_mode=2, exposure=1.05), orthogonal shadows, and anti-glare distance fog as specified in explorer_m1_lighting/handoff.md.
   - Update `QualityManager.gd` lines 132-136 / `setup_high_profile()` to guard against SSAO/SSIL on GLES3.
   - In `RailwayStation.tscn`, `DarkIndustrial.tscn`, `AbandonedTrain.tscn`, and `FinalLockdown.tscn`, replace `ssao_enabled = true` with `ssao_enabled = false` to eliminate runtime GLES3 warnings.

3. Stage Tram Station Arena (`scenes/environments/RailwayStation.tscn`):
   - Replace `RailwayStation.tscn` using the exact drop-in definition in explorer_m1_tram/handoff.md:
     - Keep child node name `RailwayStationGLB` instantiating `assets/3d/environments/tram_station.glb` (required by TestRunner.gd line 255).
     - Align track concourse bed to Y = 0.0 (`transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1.8, 0)`).
     - Configure `NavigationRegion3D` with flat navigation polygon covering 50m x 70m.
     - Configure 4-quadrant spawners (`SpawnFront`, `SpawnBack`, `SpawnLeft`, `SpawnRight`, `SpawnFrontLeft`, `SpawnFrontRight`) matching GameManager directional wave requirements.
     - Configure DirectionalLight3D with orthogonal shadows and 2 sodium platform omni lights.

4. Stage Urban Street Arena (`scenes/environments/UrbanStreet.tscn`):
   - Replace GTA Grove Street geometry with `UrbanStreetGeometry` instantiating `assets/3d/environments/street_city_7.glb` offset at `(3.0, 0, 1.0)`.
   - Keep `Ground` StaticBody3D with `BoxShape3D(60, 0.2, 60)` and asphalt material.
   - Configure `NavigationRegion3D` covering 50m x 50m.
   - Update `ZombieSpawner` with calibrated 4-quadrant spawners: `SpawnFront` (0, 0, -16), `SpawnBack` (0, 0, 16), `SpawnLeft` (-15, 0, 0), `SpawnRight` (15, 0, 0), and preserve `SpawnFrontLeft`, `SpawnFrontRight`.

5. Verification & Tests:
   Run the following verification commands and record verbatim outputs in your handoff report:
   - `godot --headless scenes/test/TestRunner.tscn` (must PASS 54/54)
   - `godot --headless assets_tests/Zombie360Test.tscn` (must PASS 5/5)
   - `godot --headless -s scripts/Tools/test_mission1_gameplay.gd` (must PASS)
   - `godot --headless -s tools/test_urban_street.gd` (must PASS)
   - Check console log for 0 GLES3 / SSAO warnings and 0 missing texture errors.

Write your report to `/home/am/targetkill/.agents/worker_m1_environment/handoff.md` and send a completion message to the orchestrator.
