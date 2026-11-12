# BRIEFING — 2026-10-10T19:03:00Z

## Mission
Implement Milestone 1: Core Implementation (Permanent 3D Terrain Collision, 4x4 Mountain Climbing Vehicle Physics, C# Subsystems & Alpine Visuals).

## 🔒 My Identity
- Archetype: Worker
- Roles: implementer, qa, specialist
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_worker_m1_gen6
- Original parent: 9b0d70d2-fb33-4bea-a8d5-73de0e0182f7
- Milestone: Milestone 1: Core Implementation

## 🔒 Key Constraints
- DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task.
- Exclusive write file ownership:
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
- Write only to your agent folder (`/home/am/targetkill/.agents/teamwork/teamwork_preview_worker_m1_gen6/`) for metadata.
- Pre-bake colliders into `scenes/environments/CityCarZombieArena.tscn` so runtime load delay and OOM are eliminated.
- Dotnet build must pass with 0 warnings and 0 errors.
- Verification script `tools/verify_mountain_climb_and_clarity.gd` must pass with exit code 0.
- >= 9 `ConcavePolygonShape3D` instances pre-baked in CityCarZombieArena.tscn.

## Current Parent
- Conversation ID: 9b0d70d2-fb33-4bea-a8d5-73de0e0182f7
- Updated: not yet

## Task Summary
- **What to build**:
  1. Terrain Colliders & Transitions: bake trimesh shapes into scene, flush sidewalks (y=0.01m), remove concrete barriers, replace runtime collision baking with verification loop.
  2. Vehicle Physics & C# Subsystems: RefCounted `VehiclePhysicsHelper` C# class, tuned suspension and crawl torque in `DrivableCar.gd` and `DrivableCar.tscn`.
  3. Visual Clarity & Performance: pure white albedo for PBR materials, native 100% resolution scale, fog/lighting adjustments in arena and weather controller.
- **Success criteria**:
  - `dotnet build SectorZeroLockdown.sln` produces 0 errors, 0 warnings.
  - `tools/verify_mountain_climb_and_clarity.gd` passes.
  - `grep -c "ConcavePolygonShape3D" scenes/environments/CityCarZombieArena.tscn` >= 9.
- **Interface contracts**: /home/am/targetkill/PROJECT.md
- **Code layout**: /home/am/targetkill/PROJECT.md

## Key Decisions Made
- [TBD]

## Artifact Index
- DISPATCH.md — Task dispatch assignment
- progress.md — Heartbeat and progress tracking
- handoff.md — Final handoff report

## Change Tracker
- **Files modified**: None yet
- **Build status**: Pending
- **Pending issues**: None

## Quality Status
- **Build/test result**: Pending
- **Lint status**: Pending
- **Tests added/modified**: Pending

## Loaded Skills
- None specified by orchestrator
