# Orchestration Plan — Generation 7

## Objective
Conclusively verify, stress test, and audit all Acceptance Criteria from ORIGINAL_REQUEST.md (2026-10-10T18:17:26Z) for Sector Zero: Lockdown in Godot 4.7.2 Mono (C# / .NET 8):
1. **AC1: Vehicle Mountain Climbing**: Automated headless test verifies car and superbike can climb mountain slopes up to 45° without falling through or stalling.
2. **AC2: Frame-0 3D Terrain Collisions**: Scene verification confirms all mountain and valley meshes (26 shapes in `CityCarZombieArena.tscn`) possess valid pre-baked `ConcavePolygonShape3D` colliders from frame 0 with 0 runtime load delay.
3. **AC3: C# .NET 8 Build**: C# .NET 8 solution builds cleanly (`dotnet build SectorZeroLockdown.sln`) with 0 errors and 0 warnings.
4. **AC4: Headless Scene Load & Clean Exit**: Headless scene loading and test scripts exit cleanly with code 0.

## Verification & Iteration Strategy

### Step 1: Initialize Setup & State
- Establish `DISPATCH.md`, `BRIEFING.md`, `plan.md`, `progress.md`, and recurring heartbeat cron (task-22).

### Step 2: Dispatch Independent Reviewers (2)
- **Reviewer 1 (`reviewer_1`)**: Focus on AC1 (Vehicle Mountain Climbing) and AC2 (Pre-baked terrain colliders, 0 fall-through, frame-0 collisions). Execute verification scripts (`tools/verify_mountain_climb_and_clarity.gd`, etc.).
- **Reviewer 2 (`reviewer_2`)**: Focus on AC3 (C# .NET 8 build, `SectorZeroLockdown.sln`, C# subsystems) and AC4 (Headless scene loading, visual clarity materials, exit code 0).

### Step 3: Dispatch Adversarial Challengers (2)
- **Challenger 1 (`challenger_1`)**: Empirically stress test vehicle climbing at boundary angles, test terrain contact points for collision voids or sinkholes, check highway-to-shoulder transition.
- **Challenger 2 (`challenger_2`)**: Stress test C# subsystem interop, scene load under headless runner, memory and process stability, verify no runtime exceptions.

### Step 4: Dispatch Forensic Auditor (1)
- **Forensic Auditor (`auditor_1`)**: Perform static and runtime integrity checks. Verify that collider baking is authentic (genuine `ConcavePolygonShape3D` nodes in `.tscn`), C# code is genuine and compiled, test scripts don't cheat or hardcode passes.

### Step 5: Gate Check & Victory Synthesis
- Collect handoffs from all 5 agents.
- Record verdicts in `GATE_STATUS.md`.
- Evaluate strict AND criteria:
  1. Build and tests pass.
  2. Reviewer 1 & Reviewer 2 APPROVE.
  3. Challenger 1 & Challenger 2 APPROVE.
  4. Forensic Auditor reports CLEAN (zero tolerance for violations).
- Synthesize all findings and evidence.
- Send completion message to caller (parent agent) with evidence for the Victory Audit.
