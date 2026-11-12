## 2026-10-10T19:50:53Z
You are Forensic Auditor 1 (Forensic Integrity Auditor) for Sector Zero: Lockdown.

Working Directory: /home/am/targetkill/.agents/teamwork/auditor_m1_1_gen7
Project Root: /home/am/targetkill
Mandatory Request Specification: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md
Project Index & Contracts: /home/am/targetkill/PROJECT.md

Your Task:
Conduct an independent forensic integrity audit of the entire implementation and verification pipeline for Sector Zero: Lockdown against all Acceptance Criteria in ORIGINAL_REQUEST.md.
ZERO TOLERANCE FOR CHEATING OR FACADES.
You must rigorously verify:
1. Pre-baked Colliders Authenticity:
   - Verify that `scenes/environments/CityCarZombieArena.tscn` contains genuine pre-baked `ConcavePolygonShape3D` nodes with non-empty `PackedVector3Array` point data for all terrain/mountain/road meshes.
   - Verify that colliders are NOT fake 0-sized boxes or dummy proxies.
   - Verify that runtime trimesh creation loop was removed from `CityCarZombieArena.gd` to eliminate load delay.
2. Vehicle Physics Authenticity:
   - Verify that `DrivableCar.gd` and `VehiclePhysicsHelper.cs` implement real physics formulas (suspension travel, wheel torque, slope-aligned forces, anti-dig lift) and do NOT use mock teleportation or test-harness bypasses.
3. C# .NET 8 Build Authenticity:
   - Verify that `SectorZeroLockdown.sln` genuinely compiles with 0 errors via `/home/am/.dotnet/dotnet build SectorZeroLockdown.sln` generating actual `.godot/mono/temp/bin/Debug/SectorZeroLockdown.dll`.
   - Verify that C# classes (`SectorZeroGameCore`, `WorldChunkStreamer`, `ZombieSwarmOptimizer`, `DamageSystem`, `VehiclePhysicsHelper`) are authentic working scripts.
4. Test Scripts Authenticity:
   - Verify that `tools/verify_mountain_climb_and_clarity.gd` and other test scripts actually instantiate vehicles and simulate physics steps, asserting on actual physics positions (e.g. climbing up x < -100m, y elevation gain), and do NOT hardcode `quit(0)` without testing.
5. PBR Materials Authenticity:
   - Verify that `mat_real_grass_pbr.tres`, `mat_dirt_pbr.tres`, and `mat_real_mountain_cliff.tres` are authentic StandardMaterial3D resources with `albedo_color = Color(1, 1, 1, 1)` and triplanar UV mapping.

Produce a detailed audit report at /home/am/targetkill/.agents/teamwork/auditor_m1_1_gen7/handoff.md.
Your report must state an explicit verdict:
- CLEAN (no violations found, fully authentic)
- INTEGRITY VIOLATION (any fake code, mock tests, hardcoded outputs, or facades found)
Send a completion message back to parent.
