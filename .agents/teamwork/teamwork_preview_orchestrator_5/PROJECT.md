# Project: Sector Zero: Lockdown — Mountain Arena Drivability, Visuals & Verification

## Architecture
- **Engine**: Godot 4.3 (gl_compatibility renderer / OpenGL 3)
- **Target Hardware**: AMD Kabini APU (3.3 GB RAM, Radeon HD 8210/8400, Linux)
- **Core Scene**: `scenes/environments/CityCarZombieArena.tscn`
- **Subsystems**:
  1. **Vehicle Physics & Off-Road Traversal**:
     - `DrivableCar` (suspension travel 0.32m, rest length 0.28m, stiffness 52.0, wheel radius 0.42m, bottom clearance 0.525m, center of mass -0.45m, 4x4 crawl assist & hill hold).
     - `DrivableBike` (capsule collider radius 0.32m, height 1.2m, floor_snap_length 0.8m, slope climb boost up to 75°).
     - Highway boundary: removal of 0.4m curb box colliders (`SidewalkLeft/Col`, `SidewalkRight/Col`, `DirtShoulderLeft/Col`, `DirtShoulderRight/Col`) allowing smooth rolling from highway across sidewalks and shoulders.
     - Foothill transition at x = ±75m: valley floor width clamped to 150m (-75m to +75m), zero vertical skirts or voids.
  2. **Ground & Alpine Visuals**:
     - Ground grass (`mat_real_grass_pbr.tres`) & dirt (`mat_dirt_pbr.tres`): full brightness `albedo_color = Color(1, 1, 1, 1)`, uniform UV tiling `Vector3(1, 1, 1)`.
     - `CityCarZombieArena.gd`: eliminate runtime dark tint `Color(0.38, 0.56, 0.22, 1.0)` and `uv1_scale = Vector3(5, 5, 1)`.
     - `JungleLake`: relocate to East valley `Vector3(55, 0.45, -190)`, shore to `Vector3(55, 0.35, -190)` (unobstructed central highway).
     - Mountain cliff faces (`mat_real_mountain_cliff.tres`): `Color(0.92, 0.90, 0.88, 1)`, triplanar rock details.
     - Atmosphere: `fog_aerial_perspective = 0.0`, `fog_density = 0.00010`, `tonemap_exposure = 1.15`.
  3. **Verification & Testing**:
     - Automated headless verification suite `tools/verify_all_requirements.gd` covering 7 phases.
     - Hardware stability: static RAM < 450 MB, draw calls ~150, gl_compatibility compliant.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| F1 | Curb & Shoulder Collider Removal | Remove 0.4m vertical box colliders at x = ±11m to ±28m in arena scene and terrain builder | M1 | Survey 1 |
| F2 | DrivableCar Suspension & Clearance Upgrade | Wheel radius 0.42m, suspension travel 0.32m, rest length 0.28m, body clearance 0.525m, CoM -0.45m, hill hold | M1 | Survey 1 |
| F3 | DrivableBike Capsule Collider & Snap | Replace BoxShape3D with CapsuleShape3D (radius 0.32m, clearance 0.10m), floor_snap_length 0.8m | M1 | Survey 1 |
| F4 | Foothill Transition & Builder Syntax Fix | Fix `h` parse error in `build_advanced_terrain.gd:1070`, clamp ValleyFloor width to 150m (x = ±75m) | M1 | Survey 1 |
| F5 | Grass & Dirt Full Brightness & UV Tiling | Set albedo Color(1,1,1,1) and uv1_scale Vector3(1,1,1) in CityCarZombieArena.gd and scene subresources | M1 | Survey 2 |
| F6 | JungleLake Relocation to East Valley | Move JungleLake to Vector3(55, 0.45, -190) and shore to Vector3(55, 0.35, -190) in scene and builder | M1 | Survey 2 |
| F7 | Mountain Cliff Daylight Shading | Set cliff subresource albedo to Color(0.92, 0.90, 0.88, 1) with triplanar rock detail | M1 | Survey 2 |
| F8 | Razor-Sharp Fog & Tonemap Exposure | Set fog_density = 0.00010, fog_aerial_perspective = 0.0, tonemap_exposure = 1.15 in WeatherController and Arena | M1 | Survey 2 |
| F9 | Comprehensive Headless Test Suite | Implement tools/verify_all_requirements.gd validating all 7 phases with exit code 0 | M2 | Survey 3 |
| F10 | Hardware Performance & Memory Compliance | Verify memory < 450 MB and gl_compatibility stability on Linux AMD Kabini | M2 | Survey 3 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Vehicle Drivability & Alpine Visuals Implementation | F1, F2, F3, F4, F5, F6, F7, F8 | None | IN_PROGRESS |
| M2 | Comprehensive E2E Verification & Performance Hardening | F9, F10 | M1 | PLANNED |

## Interface Contracts
### Vehicles ↔ Terrain Surface
- Highway surface at `y = 0.0m`, sidewalk/shoulder colliders removed or flush with asphalt (`step < 0.02m`).
- `DrivableCar`: `wheel_radius = 0.42`, `suspension_rest_length = 0.28`, `suspension_travel = 0.32`, `BodyCollision` bottom clearance >= 0.50m.
- `DrivableBike`: `CapsuleShape3D` bottom clearance >= 0.10m, `floor_snap_length = 0.8`.
- Foothill transition at `x = ±75.0m`: smooth elevation continuous with mountain mesh, zero vertical skirts.

### Visuals ↔ Shading Engine
- `mat_real_grass_pbr`: `albedo_color = Color(1, 1, 1, 1)`, `uv1_scale = Vector3(1, 1, 1)`.
- `mat_real_mountain_cliff`: `albedo_color = Color(0.92, 0.90, 0.88, 1)`, `uv1_triplanar = true`.
- `JungleLake`: centered at `Vector3(55, 0.45, -190)`, highway at `abs(x) < 28m` is completely unobstructed.
- `WorldEnvironment`: `fog_density = 0.00010`, `fog_aerial_perspective = 0.0`, `tonemap_exposure = 1.15`.

## Code Layout
- `scenes/environments/CityCarZombieArena.tscn`, `CityCarZombieArena.gd`
- `scenes/environments/WeatherController.gd`
- `tools/build_advanced_terrain.gd`
- `scenes/vehicles/DrivableCar.tscn`, `scripts/Vehicles/DrivableCar.gd`, `tools/build_realistic_drivable_car.gd`
- `scenes/vehicles/DrivableBike.tscn`, `scripts/Vehicles/DrivableBike.gd`
- `resources/materials/mat_real_grass_pbr.tres`, `mat_dirt_pbr.tres`, `mat_real_mountain_cliff.tres`
- `tools/verify_all_requirements.gd`
