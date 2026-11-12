# Orchestration Plan — Generation 6

## Objective
Deliver all requirements from ORIGINAL_REQUEST.md (2026-10-10T18:17:26Z):
1. R1: Permanent 3D Terrain Collision (pre-baked ConcavePolygonShape3D) & Mountain Vehicle Climbing.
2. R2: Godot 4.7.2 C# (.NET 8) Architecture, zero-warning/zero-error build, and active core subsystems.
3. R3: Visual Clarity (bright PBR grass/dirt/cliff) & MultiMesh performance optimization for AMD Kabini APU.

## Step-by-Step Phases

### Phase 0: Parallel Codebase Survey
- **Explorer 1 (R1 Focus)**: Investigate terrain mesh colliders in `CityCarZombieArena.tscn` and `tools/build_advanced_terrain.gd` / `build_gta5_open_world.gd`. Check pre-baked ConcavePolygonShape3D vs dynamic generation. Check highway shoulder transitions and `DrivableCar.gd` / `VehiclePhysicsHelper.cs` climbing torque/suspension.
- **Explorer 2 (R2 Focus)**: Investigate `SectorZeroLockdown.sln`, C# source files (`SectorZeroGameCore.cs`, `WorldChunkStreamer.cs`, `ZombieSwarmOptimizer.cs`, `DamageSystem.cs`), `/home/am/.dotnet/dotnet`, build state, and chunk streamer memory management.
- **Explorer 3 (R3 Focus)**: Investigate ground materials (`mat_real_grass_pbr.tres`, `mat_dirt_pbr.tres`, `mat_real_mountain_cliff.tres`), MultiMesh instance counts/draw distances/shadows, and headless test scripts (`tools/verify_*.gd`, headless scene runner).

### Phase 1: PROJECT.md & Decomposition
- Synthesize all three survey reports into `PROJECT.md`.
- Map all features to cohesive milestones with clear interface contracts.

### Phase 2: Implementation & Verification Cycles
- Implement each milestone via Worker, Reviewers (2), Challengers (2), and Forensic Auditor.
- Verify through automated headless tests and compiler checks.

### Phase 3: Final Acceptance & Victory Audit
- Headless test verifies car climbing mountain slopes without stalling or falling through.
- Scene verification confirms all terrain and mountain meshes have valid colliders from frame 0.
- C# .NET 8 build succeeds with 0 errors.
- Headless scene loads cleanly with exit code 0.
