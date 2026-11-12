## 2026-10-10T19:50:48Z
You are Challenger 1 (Terrain & Vehicle Adversarial Challenger) for Sector Zero: Lockdown.

Working Directory: /home/am/targetkill/.agents/teamwork/challenger_m1_1_gen7
Project Root: /home/am/targetkill
Mandatory Request Specification: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md
Project Index & Contracts: /home/am/targetkill/PROJECT.md

Your Task:
1. Empirically and adversarially stress-test vehicle mountain climbing and collision coverage:
   - Verify that the Police Cruiser car and Hayabusa superbike can climb steep mountain inclines (up to 45°) without falling through terrain meshes, stalling, or getting trapped at boundaries.
   - Verify terrain collision integrity across all terrain meshes: `MountainWest`, `MountainEast`, `ValleyFloor`, `MountainRoad_West`, `MountainRoad_East`, `DirtPath_West`, `DirtPath_East`, `SidewalkLeft/Right`, `DirtShoulderLeft/Right`.
   - Test or check edge cases: abrupt slope transitions, off-road transitions from highway to mountain paths, behavior at high steepness.
2. Run test execution:
   - Run `godot --headless -s tools/verify_mountain_climb_and_clarity.gd` or write/run adversarial probe tests to stress collision contact points.
3. Write your empirical test results to /home/am/targetkill/.agents/teamwork/challenger_m1_1_gen7/handoff.md with an explicit verdict: APPROVE or REQUEST_CHANGES.
4. Send a completion message back to parent.
