## 2026-10-10T18:20:28Z
You are the Project Orchestrator (Generation 6) for Sector Zero: Lockdown in Godot 4.7.2 Mono (C# / .NET 8).

Project Root / Working Directory: /home/am/targetkill
Agent Coordination Directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_6
Authoritative Request: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md

Please read /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md and establish your plan.md and progress.md in your coordination directory.

Your mission is to fulfill all requirements from the latest user request:
1. R1. Permanent 3D Terrain Collision & Mountain Vehicle Climbing:
   - Ensure all terrain and mountain meshes in CityCarZombieArena.tscn (MountainWest, MountainEast, MountainRoad_West, MountainRoad_East, DirtPath_West, DirtPath_East, ValleyFloor, DirtShoulderLeft/Right, SidewalkLeft/Right) have pre-baked ConcavePolygonShape3D colliders in the scene file itself so there is 0 delay on load and vehicles never fall through into the void.
   - Smooth out the transition angles between the highway shoulder and the mountain paths so cars do not hit collision lips or get beached.
   - Fine-tune DrivableCar.gd and C# VehiclePhysicsHelper.cs with robust 4x4 incline torque, suspension travel, anti-dig lift, and grip so the car effortlessly climbs the mountain slopes up to the peaks.

2. R2. Godot 4.7.2 C# (.NET 8) Architecture & Subsystems:
   - Verify that SectorZeroLockdown.sln builds with 0 warnings and 0 errors under /home/am/.dotnet/dotnet.
   - Ensure SectorZeroGameCore.cs, WorldChunkStreamer.cs, ZombieSwarmOptimizer.cs, and DamageSystem.cs are cleanly integrated and active.
   - Ensure the open-world chunk streamer manages render distance within the 3.3 GB APU memory budget without stutter.

3. R3. Visual Clarity & Performance Optimization:
   - Ground materials (mat_real_grass_pbr.tres, mat_dirt_pbr.tres, mat_real_mountain_cliff.tres) must render in true full brightness with crisp world-space UV tiling without blur or grey haze.
   - Optimize MultiMeshes (trees, rocks, bushes) draw distances and shadows to ensure steady 45-60 FPS on OpenGL 3 (gl_compatibility).

Acceptance Criteria:
- Automated headless test verifies car can climb the mountain slopes without falling through ground or stalling.
- Scene verification confirms all mountain and valley meshes possess valid collision shapes from frame 0.
- C# .NET 8 solution builds cleanly (dotnet build SectorZeroLockdown.sln) with 0 errors.
- Headless scene loading and test scripts exit cleanly with code 0.
