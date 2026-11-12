## 2026-10-10T19:02:38Z
You are the Worker for Milestone 1: Core Implementation (Permanent 3D Terrain Collision, 4x4 Mountain Climbing Vehicle Physics, C# Subsystems & Alpine Visuals).
Your working directory is: /home/am/targetkill/.agents/teamwork/teamwork_preview_worker_m1_gen6

MANDATORY READS BEFORE STARTING WORK:
1. /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md
2. /home/am/targetkill/PROJECT.md
3. /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_1/handoff.md (Colliders, Serialization & Transitions blueprint)
4. /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_2/handoff.md (Vehicle Physics & C# Subsystems blueprint)
5. /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_3/handoff.md (PBR Materials, Viewport & MultiMesh blueprint)

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE FILE OWNERSHIP:
- `tools/bake_terrain_colliders.gd`
- `scenes/environments/CityCarZombieArena.tscn`
- `scenes/environments/CityCarZombieArena.gd`
- `scenes/environments/WeatherController.gd`
- `scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs`
- `scripts/Vehicles/DrivableCar.gd`
- `scenes/vehicles/DrivableCar.tscn`
- `resources/materials/mat_real_grass_pbr.tres`
- `resources/materials/mat_dirt_pbr.tres`
- `resources/materials/mat_real_mountain_cliff.tres`

TASKS:
1. Terrain Colliders & Transitions (F1, F2, F3):
   - Update `tools/bake_terrain_colliders.gd` with the exact logic from Explorer M1 1 handoff:
     - Generate `create_trimesh_shape()` and bake `ConcavePolygonShape3D` for MountainWest, MountainEast, ValleyFloor, MountainNorthWall, MountainSouthWall, MountainRoad_West, MountainRoad_East, DirtPath_West, DirtPath_East, SidewalkLeft, SidewalkRight, DirtShoulderLeft, DirtShoulderRight.
     - Ensure proper `cs.owner = scene` and `body.owner = scene` so PackedScene serializes shapes.
     - Set sidewalk mesh height flush to `y = 0.01m` (<= 0.02m step) and match `cs.transform = mi.transform` on sidewalks and shoulders.
     - Remove the 8 concrete barriers `Barrier_0` through `Barrier_7` at x = ±10.5m.
     - Pack and save `scenes/environments/CityCarZombieArena.tscn`.
   - Run `godot --headless -s tools/bake_terrain_colliders.gd` to bake the colliders into the scene.
   - In `scenes/environments/CityCarZombieArena.gd`:
     - Replace the runtime `_ensure_solid_terrain_collisions()` loop (lines 159–208) with the lightweight pre-baked collider verification loop from Explorer M1 1 (eliminating 65s load delay and OOM 137).
     - Remove watchdog fall recovery or make it non-interfering.

2. Vehicle Physics & C# Subsystems (F4, F5, F6):
   - In `scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs`:
     - Convert from `public static class` to `[GlobalClass] public partial class VehiclePhysicsHelper : RefCounted` with `CalculateInclineAssist` and `ComputeBikeLean` methods.
   - In `scripts/Vehicles/DrivableCar.gd`:
     - Tune suspension rest length `0.28m`, travel `0.38m`, stiffness `35.0`, wheel radius `0.44m`, and center of mass `Vector3(0.0, -0.32, -0.20)`.
     - Replace pure `Vector3.UP` anti-dig lift with slope-aligned crawl torque: `(forward_dir + Vector3.UP * 0.25).normalized()`.
     - Connect `VehiclePhysicsHelper` incline assist.
   - In `scenes/vehicles/DrivableCar.tscn`:
     - Update `WheelFL`, `WheelFR`, `WheelBL`, `WheelBR` with `suspension_rest_length = 0.28`, `suspension_travel = 0.38`, `suspension_stiffness = 35.0`, `wheel_radius = 0.44`.
   - Run `/home/am/.dotnet/dotnet build SectorZeroLockdown.sln` (use `BypassSandbox: true` if needed) and verify 0 warnings and 0 errors.

3. Visual Clarity & Performance (F7, F8, F9):
   - In `resources/materials/mat_real_grass_pbr.tres`: Set `albedo_color = Color(1, 1, 1, 1)`.
   - In `resources/materials/mat_dirt_pbr.tres`: Set `albedo_color = Color(1, 1, 1, 1)`.
   - In `resources/materials/mat_real_mountain_cliff.tres`: Set `albedo_color = Color(1, 1, 1, 1)`.
   - In `scenes/environments/CityCarZombieArena.gd`:
     - Set `vp.scaling_3d_scale = 1.0` (native 100% resolution, no 0.85 bilinear blur).
     - Set `env.fog_density = 0.00010`, `env.fog_aerial_perspective = 0.0`, `env.tonemap_exposure = 1.15`, `env.ambient_light_energy = 0.85`.
   - In `scenes/environments/WeatherController.gd`:
     - In `SUNNY_DAY` preset, align `fog_density = 0.00010`, `fog_aerial_perspective = 0.0`.
   - MultiMeshes: Confirm 1,300 instances (400 trees, 400 rocks, 500 bushes) with `cast_shadow = 0` and visibility ranges 150m/110m/90m.

VERIFICATION REQUIREMENTS:
- Run `/home/am/.dotnet/dotnet build SectorZeroLockdown.sln` -> capture output (0 warnings, 0 errors).
- Run `godot --headless -s tools/verify_mountain_climb_and_clarity.gd` -> capture output (all tests pass, exit code 0).
- Run `grep -c "ConcavePolygonShape3D" scenes/environments/CityCarZombieArena.tscn` -> verify >= 9 colliders pre-baked.
- Document all modified files, commands executed, and verification logs in `/home/am/targetkill/.agents/teamwork/teamwork_preview_worker_m1_gen6/handoff.md`.
- Send completion message to parent when done.
