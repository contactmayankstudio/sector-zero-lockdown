# BRIEFING — 2026-10-07T13:58:00Z

## Mission
Survey codebase for Requirement 2: Soldier Superbike Physics & Riding Posture (Hayabusa physics, mounting/dismounting, soldier riding posture/IK, chase camera).

## 🔒 My Identity
- Archetype: explorer
- Roles: investigation, synthesis
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_2
- Original parent: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720
- Milestone: Requirement 2 Codebase Survey

## 🔒 Key Constraints
- Read-only investigation — do NOT implement
- Base working directory is /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_2
- Write only to your folder; read any folder

## Current Parent
- Conversation ID: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720
- Updated: 2026-10-07T13:43:08Z

## Investigation State
- **Explored paths**:
  - `project.godot`
  - `scripts/Vehicles/DrivableBike.gd`
  - `scenes/vehicles/DrivableBike.tscn`
  - `scenes/characters/RealSoldier.tscn` & `RealSoldier.scn`
  - `scripts/Characters/Player.gd` & `scenes/player/Player.tscn`
  - `scenes/environments/CityCarZombieArena.gd` & `.tscn`
  - `scripts/UI/GTAMinimap.gd`
  - `scripts/Gameplay/CameraController.gd`
  - `tools/build_bike_riding_anim.gd`, `tools/test_drivable_bike.gd`, `tools/test_bike_rider_load.gd`
- **Key findings**:
  1. Hayabusa physics uses `CharacterBody3D` with dynamic lean, torque curve, front fork steer, and RPM pitch modulation. Lacks ground normal alignment (slope pitching).
  2. Mount/Dismount with [F] works smoothly, but `player_ref.global_position` is not synced during ride (causes zombie AI and minimap radar desync).
  3. Rider soldier has severe floating bug: hips at Y=1.50m (85cm above seat), hands at Y=1.83m (~1m above handlebars), feet at chest height Y=1.53m due to faulty animation authoring in `build_bike_riding_anim.gd`. Moving rider root to `Vector3(0.0, -0.42, -0.04)` and applying proper bone rotations brings shoulders to within 5.8cm of grips and feet to footpegs.
  4. Chase camera uses rigid `SpringArm3D` without yaw follow damping, look-ahead, or auto-recenter.
- **Unexplored areas**: None within Requirement 2 scope.

## Key Decisions Made
- Executed diagnostic headless Godot scripts to calculate exact 3D coordinates of bike contact points (seat, grips, pegs) and bone transformations.
- Formulated concrete fixes for posture, physics slope alignment, player sync, and camera damping.

## Artifact Index
- DISPATCH.md — Dispatch log
- BRIEFING.md — Persistent context index
- progress.md — Liveness and step tracking
- inspect_rider_alignment.gd — Contact point and bone position diagnostic script
- find_geometry_points.gd — Hayabusa mesh bounding box inspector
- test_pose_solver.gd — Seat offset solver
- test_reachability.gd — Shoulder/hip reachability calculator
- handoff.md — Comprehensive 5-component survey report
