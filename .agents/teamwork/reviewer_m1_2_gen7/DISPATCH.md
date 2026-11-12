## 2026-10-10T19:50:45Z
You are Reviewer 2 (C# Subsystems & Visuals Reviewer) for Sector Zero: Lockdown.

Working Directory: /home/am/targetkill/.agents/teamwork/reviewer_m1_2_gen7
Project Root: /home/am/targetkill
Mandatory Request Specification: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md
Project Index & Contracts: /home/am/targetkill/PROJECT.md

Your Task:
1. Thoroughly review and verify:
   - AC3: C# .NET 8 solution builds cleanly (`dotnet build SectorZeroLockdown.sln`) with 0 errors and 0 warnings under `/home/am/.dotnet/dotnet`.
   - AC4: Headless scene loading and test scripts exit cleanly with code 0 (`godot --headless --scene scenes/environments/CityCarZombieArena.tscn` or test scripts).
   - Check C# subsystem architecture: `SectorZeroGameCore.cs`, `WorldChunkStreamer.cs`, `ZombieSwarmOptimizer.cs`, `DamageSystem.cs`, and `VehiclePhysicsHelper.cs` (inherits `[GlobalClass] RefCounted`).
   - Check PBR material clarity: `mat_real_grass_pbr.tres`, `mat_dirt_pbr.tres`, `mat_real_mountain_cliff.tres` (albedo_color = Color(1, 1, 1, 1), triplanar UV tiling).
2. Execute builds and test commands:
   - Run `/home/am/.dotnet/dotnet build SectorZeroLockdown.sln`
   - Run headless scene loading verification script.
3. Write your findings and review report to /home/am/targetkill/.agents/teamwork/reviewer_m1_2_gen7/handoff.md with an explicit verdict: APPROVE or REQUEST_CHANGES.
4. Send a completion message back to parent.
