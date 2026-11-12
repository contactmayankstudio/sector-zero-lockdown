# Dispatch: explorer_decapitation_fx

## Mission
Investigate Zombie models, HitZone/headshot architecture, decapitation feasibility, particle effects, and audio sync for Requirement R2 (Visceral Headshot Decapitation & Impact FX).

## Target Systems
- `assets/zombies/RealisticZombie.gd`, `scripts/Zombies/EnemyBase.gd`, `assets/zombies/realistic_zombie.tscn`
- Mesh hierarchy: Skeleton3D, bone names (Head bone), mesh instances, how to hide or scale head bone/mesh or spawn decapitated head prop
- HitZone architecture: `HitZone.gd`, `scenes/weapons/Weapon.gd`, how lethal headshot is determined and signaled
- Blood burst particles: `CPUParticles3D` directional blood spray (gl_compatibility safe)
- Audio synchronization: 2.5x critical hitmarker sound and `sfx_headshot_crunch.ogg`

## Output
Write complete findings and recommendations to `/home/am/targetkill/.agents/explorer_decapitation_fx/handoff.md`.

## 2026-09-13T18:27:00Z
Investigate Requirement R2: Visceral Headshot Decapitation & Impact FX:
- Lethal critical headshots against zombies must trigger immediate head dismemberment/decapitation effects and a directional blood burst particle spray, synchronized with the existing 2.5x critical hitmarker sound.
Examine:
1. assets/zombies/RealisticZombie.gd, scripts/Zombies/EnemyBase.gd, assets/zombies/realistic_zombie.tscn (and other enemy scenes like dogs, heavy, spitter, boss). Check the mesh structure, Skeleton3D, bone hierarchy (e.g. "Head" or "mixamorig_Head"), and how to execute head dismemberment/decapitation (e.g., bone scaling to 0, hiding mesh/bone attachment, spawning headless neck stump blood FX or detached head prop).
2. Hit detection in HitZone.gd, scenes/weapons/Weapon.gd, and EnemyBase.gd / RealisticZombie.gd: How damage and headshots are calculated, how lethal status (health <= 0 from headshot) is determined and dispatched.
3. Blood burst particle spray: Gl_compatibility compatible particle setup (CPUParticles3D or GPUParticles3D with mobile budget), directional spray based on bullet impact vector/normal, auto-cleanup to prevent memory leaks/orphaned nodes.
4. Audio & Hitmarker synchronization: Existing 2.5x critical hitmarker sound (sfx_headshot_crunch.ogg, HUD show_hitmarker).
