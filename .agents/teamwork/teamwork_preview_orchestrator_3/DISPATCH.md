## 2026-10-09T12:49:19Z

You are the Project Orchestrator (teamwork_preview_orchestrator) for the project at /home/am/targetkill.

Your working directory is: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_3
The authoritative user request is recorded in: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md

User Request:
Use a very large team of agents. Continue refining the CityCarZombieArena environment in Godot 4 by adding natural elements like a highly realistic lake and ambient atmosphere to make it feel like a dense, living jungle.

Working directory: /home/am/targetkill
Integrity mode: demo

## Requirements

### R1. Realistic Water Lake
Implement a highly realistic water shader for a lake in the jungle environment. The shader should include realistic features like wave normal maps, depth-based color blending, and reflections if supported by the OpenGL3 renderer.

### R2. Animal Life & Atmosphere
Add natural ambient atmosphere to the environment to make it feel alive (e.g., ambient jungle sounds, bird particles, or simple wildlife).

### R3. Performance Optimization
Ensure the water shader and atmosphere elements do not crash the game on low-end hardware (AMD Kabini APU with 3.3 GB RAM). The shader must compile successfully in `gl_compatibility` mode.

## Acceptance Criteria

### Lake Implementation
- [ ] A MeshInstance3D plane representing the lake is added to the scene or generated via the environment script.
- [ ] The water uses a ShaderMaterial that compiles without errors and visualizes depth and waves.

### Atmosphere
- [ ] The scene includes an AudioStreamPlayer3D for ambient jungle sounds or a CPUParticles3D node for ambient insects/birds.
- [ ] The scene loads successfully via `godot --headless` with exit code 0.
