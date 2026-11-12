## 2026-10-10T07:40:41Z
You are the Project Orchestrator (Generation 5).
Your working directory is: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_5
The project root is: /home/am/targetkill
The authoritative user request is recorded in: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md

Please execute the following request:

Finalize and optimize the open-world 3D mountain arena in Godot 4 (gl_compatibility renderer, AMD Kabini APU target), ensuring full vehicle mountain drivability (Police Cruiser car & Hayabusa superbike can drive off-road and climb mountain slopes smoothly), crystal-clear alpine visuals (high-definition grass, realistic dirt roads, no blurry mipmap smear, vibrant lighting), and stable 45-60 FPS performance.

Working directory: /home/am/targetkill
Integrity mode: demo

## Requirements

### R1. Vehicle Mountain Climbing & Off-Road Transition
- Ensure vehicles (Police Cruiser Sedan & Hayabusa Superbike) can drive seamlessly from the highway across sidewalks and dirt shoulders without being blocked by 0.4m curb box colliders.
- Upgrade `DrivableCar` suspension, wheel radius, ground clearance, and 4x4 hill-climbing crawl torque so it climbs steep mountain passes without getting beached, stalled, or flipping.
- Ensure the terrain foothill transition at x = ±75m has zero vertical cliffs, skirts, or mesh voids.

### R2. Crystal-Clear Ground & Alpine Visuals
- Ground grass (`mat_real_grass_pbr.tres`) and dirt tracks (`mat_dirt_pbr.tres`) must render in true full brightness (`albedo_color = Color(1, 1, 1, 1)`) with uniform world-space UV tiling (no 6400x mipmap smear or grey-blue wash).
- Clear the central highway by relocating `JungleLake` off-road into the East valley (`Vector3(55, 0.45, -190)`), ensuring unobstructed views of the road and mountain passes.
- Mountain cliff faces (`mat_real_mountain_cliff.tres`) must render with crisp triplanar rock details under daylight.
- Tune fog (`fog_aerial_perspective = 0.0`, density = `0.00010`) and tonemap exposure (`1.15`) for razor-sharp visual clarity without washed-out haze.

### R3. Hardware Stability & Performance
- Maintain stable 45-60 FPS performance on the Linux OpenGL 3 / gl_compatibility renderer within the AMD Kabini 3.3 GB memory budget.
- Clean scene instantiation and validation with zero errors.

## Acceptance Criteria

### Drivability & Physics Verification
- [ ] Automated headless test confirms the Police Cruiser car drives from highway (x = 0) all the way up the West Mountain slope (x < -100m) without getting stuck, stopped, or flipped.
- [ ] No vertical curb colliders or edge cliffs exist at the highway shoulder boundary (x = ±13m to ±28m).
- [ ] Hayabusa superbike and police car can climb mountain inclines up to 45° with full responsive traction.

### Visual Quality & Clarity Verification
- [ ] Valley floor grass renders rich green blades and soil detail without flat grey-blue patches.
- [ ] Highway center is free of water plane obstructions; lake is located in the scenic East valley.
- [ ] Mountain ridges, rocks, and foliage render sharply without blurry mipmap downscaling or heavy grey haze.
- [ ] Scene verification script (`godot --headless`) loads and executes with exit code 0.
