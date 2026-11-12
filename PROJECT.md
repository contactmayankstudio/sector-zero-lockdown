# Project: Sector Zero: Lockdown — Generation 6 (Godot 4.7.2 Mono / .NET 8)

## Architecture
- **Engine**: Godot 4.7.2 Mono (`4.7.2.stable.mono.official.ed1daf0bf`)
- **Runtime**: .NET 8.0 SDK (8.0.425) / C#
- **Renderer**: Linux OpenGL 3 (`gl_compatibility`)
- **Target Hardware**: AMD Kabini APU (3.3 GB shared DDR3 RAM, Radeon HD 8210/8400 graphics)
- **Primary Scene**: `scenes/environments/CityCarZombieArena.tscn`
- **Subsystem Architecture**:
  1. **Permanent 3D Terrain Collision & Smooth Transitions**:
     - Pre-baked `ConcavePolygonShape3D` colliders in `.tscn` on `MountainWest_Physics`, `MountainEast_Physics`, `ValleyFloor_Physics`, `MountainNorthWall_Physics`, `MountainSouthWall_Physics`, `DirtPath_West_Physics`, `DirtPath_East_Physics`, `MountainRoad_West_Physics`, `MountainRoad_East_Physics`, `SidewalkLeft/Col`, `SidewalkRight/Col`, `DirtShoulderLeft/Col`, `DirtShoulderRight/Col`.
     - Zero runtime delay: eliminate dynamic `create_trimesh_collision()` loop from `CityCarZombieArena.gd` (saving 65s and >350 MB RAM, eliminating OOM 137).
     - Smooth transitions: flush highway-to-sidewalk and sidewalk-to-shoulder transitions (no 0.12m vertical lips), removal of highway barrier props (`Barrier_0`–`Barrier_7`) at `x = ±10.5m`.
  2. **Vehicle Physics & 4x4 Mountain Climbing**:
     - `DrivableCar`: 4x4 incline crawl torque, suspension travel 0.35m, rest length 0.28m, wheel radius 0.44m, ground clearance >= 0.55m, slope-aligned incline assist (integrated with `VehiclePhysicsHelper.cs`), anti-dig lift that preserves normal wheel contact.
     - `DrivableBike`: responsive lean and climb traction up to 45° inclines.
  3. **C# .NET 8 Architecture & Core Subsystems**:
     - `SectorZeroLockdown.sln`: clean build with 0 warnings and 0 errors under `/home/am/.dotnet/dotnet`.
     - `SectorZeroGameCore.cs`: active Autoload engine coordinator.
     - `WorldChunkStreamer.cs`: 7x7 chunk grid (120m chunk size, 3 chunk view distance = 840m x 840m envelope) managing APU memory budget without stutter.
     - `ZombieSwarmOptimizer.cs`: high-density horde simulation manager.
     - `DamageSystem.cs`: unified damage and hit calculation.
     - `VehiclePhysicsHelper.cs`: C# helper for incline assist and bike lean.
  4. **Alpine Visual Clarity & MultiMesh Optimization**:
     - PBR Materials: `mat_real_grass_pbr.tres`, `mat_dirt_pbr.tres`, `mat_real_mountain_cliff.tres` with `albedo_color = Color(1, 1, 1, 1)`, crisp triplanar world-space UV tiling.
     - Viewport: full native resolution (`scaling_3d_scale = 1.0`, no bilinear blur).
     - Environment: `fog_density = 0.00010`, `fog_aerial_perspective = 0.0`, `tonemap_exposure = 1.15`.
     - MultiMeshes: 400 trees, 400 rocks, 500 bushes (1,300 total) with `cast_shadow = 0` and draw distances 150m/110m/90m for steady 45-60 FPS on AMD Kabini APU.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| F1 | Pre-Baked Terrain ConcavePolygonShape3D Colliders | Embed ConcavePolygonShape3D colliders in CityCarZombieArena.tscn for all 9 terrain/mountain meshes, sidewalks, and shoulders | M1 | Survey 1, Survey 2 |
| F2 | Eliminate Runtime Trimesh Collision Loop | Remove dynamic create_trimesh_collision() from CityCarZombieArena.gd, eliminating 65s load delay and OOM 137 | M1 | Survey 1, Survey 2 |
| F3 | Smooth Highway Shoulder & Off-Road Transition | Remove 0.12m vertical lips on sidewalks/shoulders, remove highway concrete barrier props at x = ±10.5m | M1 | Survey 1 |
| F4 | 4x4 Mountain Climbing Vehicle Physics | Fine-tune DrivableCar.gd and VehiclePhysicsHelper.cs with slope-aligned crawl torque, suspension travel, and anti-dig lift | M1 | Survey 1 |
| F5 | C# .NET 8 Zero-Error Build & Subsystems | Verify SectorZeroLockdown.sln compiles with 0 errors/0 warnings; ensure SectorZeroGameCore, WorldChunkStreamer, ZombieSwarmOptimizer, DamageSystem active | M1 | Survey 2 |
| F6 | Open-World Chunk Streamer Memory Management | Configure WorldChunkStreamer within 3.3 GB APU memory budget (840m envelope) without stutter | M1 | Survey 2 |
| F7 | Full Brightness PBR Ground Materials & UV Tiling | Set albedo_color = Color(1,1,1,1) on grass, dirt, and cliff materials with crisp world-space UV tiling | M1 | Survey 3 |
| F8 | Razor-Sharp Atmosphere & Viewport Tuning | Set scaling_3d_scale = 1.0, fog_density = 0.00010, fog_aerial_perspective = 0.0, tonemap_exposure = 1.15 in CityCarZombieArena.gd | M1 | Survey 3 |
| F9 | MultiMesh Optimization for OpenGL 3 | Maintain 1,300 instances (trees/rocks/bushes) with cast_shadow = 0 and visibility ranges 150m/110m/90m for 45-60 FPS | M1 | Survey 3 |
| F10 | Comprehensive Headless Automated E2E Test Suite | Automated test verifies car mountain climb, frame-0 collisions, C# build, and scene load with exit code 0 | M2 | Survey 1, 2, 3 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Core Implementation: Permanent 3D Collision, Vehicle Climbing, C# & Visuals | F1, F2, F3, F4, F5, F6, F7, F8, F9 | None | IN_PROGRESS |
| M2 | Automated E2E Verification & Adversarial Hardening | F10 | M1 | PLANNED |

## Interface Contracts
### Terrain Collision ↔ Physics Engine
- All 9 terrain and mountain meshes (`ValleyFloor`, `MountainWest`, `MountainEast`, `MountainNorthWall`, `MountainSouthWall`, `DirtPath_West`, `DirtPath_East`, `MountainRoad_West`, `MountainRoad_East`) plus sidewalks and shoulders must have pre-baked `ConcavePolygonShape3D` children on their static bodies in `CityCarZombieArena.tscn`.
- Collision exists from frame 0 upon scene instantiation before `_ready()` runs.
- Highway asphalt (y = 0.0m) to sidewalk and dirt shoulder step height must be <= 0.02m (no 0.12m vertical cliff).
- Highway edge at `|x| <= 28m` is cleared of obstructing barriers.

### Vehicles ↔ Mountain Surface
- `DrivableCar`: `wheel_radius = 0.44`, `suspension_rest_length = 0.28`, `suspension_travel = 0.35`, `BodyCollision` bottom clearance >= 0.55m.
- Incline crawling: assist directed along slope tangent vector `(forwardDir + Vector3.Up * 0.25).Normalized()`, avoiding pure `Vector3.UP` tire unloading.
- Mountain slope climbing capability verified up to 45° slopes.

### C# Subsystems ↔ Engine Architecture
- Build command: `/home/am/.dotnet/dotnet build SectorZeroLockdown.sln` outputs 0 warnings, 0 errors.
- Target assembly: `.godot/mono/temp/bin/Debug/SectorZeroLockdown.dll`.
- `SectorZeroGameCore` registered as Autoload singleton.
- `WorldChunkStreamer` and `ZombieSwarmOptimizer` active in arena scene.

### Shading Engine ↔ Materials
- `resources/materials/mat_real_grass_pbr.tres`: `albedo_color = Color(1, 1, 1, 1)`, `uv1_triplanar = true`.
- `resources/materials/mat_dirt_pbr.tres`: `albedo_color = Color(1, 1, 1, 1)`, `uv1_triplanar = true`.
- `resources/materials/mat_real_mountain_cliff.tres`: `albedo_color = Color(1, 1, 1, 1)`, `uv1_triplanar = true`.
- Viewport: `scaling_3d_scale = 1.0` (100% native 3D resolution).
- Atmosphere: `fog_density = 0.00010`, `fog_aerial_perspective = 0.0`, `tonemap_exposure = 1.15`.

## Code Layout
- `scenes/environments/CityCarZombieArena.tscn`: Main arena scene with pre-baked colliders.
- `scenes/environments/CityCarZombieArena.gd`: Arena manager script (clean, no runtime trimesh loop).
- `tools/bake_terrain_colliders.gd`: Tool script to pre-bake ConcavePolygonShape3D colliders into scene.
- `tools/build_advanced_terrain.gd`: Procedural terrain builder.
- `scenes/vehicles/DrivableCar.tscn`: Police cruiser vehicle scene.
- `scripts/Vehicles/DrivableCar.gd`: Vehicle physics and driving controller.
- `scripts/CSharp/Vehicles/VehiclePhysicsHelper.cs`: C# vehicle physics assist helper.
- `scripts/CSharp/Core/SectorZeroGameCore.cs`: Core C# engine singleton.
- `scripts/CSharp/World/WorldChunkStreamer.cs`: Open-world chunk streamer.
- `scripts/CSharp/AI/ZombieSwarmOptimizer.cs`: Zombie swarm optimization.
- `scripts/CSharp/Combat/DamageSystem.cs`: Damage system calculation.
- `resources/materials/mat_real_grass_pbr.tres`: PBR grass material.
- `resources/materials/mat_dirt_pbr.tres`: PBR dirt material.
- `resources/materials/mat_real_mountain_cliff.tres`: PBR cliff rock material.
- `tools/verify_all_requirements.gd`: Comprehensive headless E2E verification suite.
