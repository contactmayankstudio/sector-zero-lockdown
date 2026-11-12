# BRIEFING — 2026-09-13T18:27:00Z

## Mission
Investigate Requirement R2: Visceral Headshot Decapitation & Impact FX for Sector Zero: Lockdown.

## 🔒 My Identity
- Archetype: explorer
- Roles: investigation, synthesis
- Working directory: /home/am/targetkill/.agents/explorer_decapitation_fx
- Original parent: e02d2964-7812-4936-894c-476d2b599b6f
- Milestone: Requirement R2 (Visceral Headshot Decapitation & Impact FX)

## 🔒 Key Constraints
- Read-only investigation — do NOT implement
- gl_compatibility renderer support (CPUParticles3D preferred for mobile / low spec)
- Zero orphaned nodes / memory leak prevention
- Do not modify source code outside .agents/

## Current Parent
- Conversation ID: e02d2964-7812-4936-894c-476d2b599b6f
- Updated: 2026-09-13T18:27:00Z

## Investigation State
- **Explored paths**: `assets/zombies/RealisticZombie.gd`, `scripts/Zombies/EnemyBase.gd`, `scripts/Combat/HitZone.gd`, `scenes/weapons/Weapon.gd`, `scripts/ImpactPool.gd`, `scripts/VFX/VFXManager.gd`, `scenes/weapons/BloodEffect.tscn`, `scripts/HUD.gd`, all zombie models in `scenes/zombies/models/`.
- **Key findings**:
  1. `RealDoomZombie.scn` (normal/fast/spitter): Bone 25 `ValveBiped.Bip01_Head1_51` controls 25 child facial bones; `Object_8` is specifically the head mesh, `Object_7` is eyes. Both mesh hiding (`Object_8.visible=false`, `Object_7.visible=false`) and bone zero-scaling (`skeleton.set_bone_pose_scale(25, Vector3.ZERO)`) work cleanly without animation override.
  2. `RealSoldierZombie.scn` (heavy): Bone 6 `mixamorig_Head_06`; mesh `Object_10` (head/helmet) and `Object_8`/`Object_9` (goggles/face) can be hidden, and bone 6 zero-scaled.
  3. Other archetypes: `infected_dog.tscn` (Bone 5 `Head`), `zombie_boss.tscn` (Bone 5 `Head`), `zombie_normal.tscn` (Bone 5 `Head`). `RealButcherBoss.scn` has no skeleton (5 meshes); decapitation should be guarded to skip if no skeleton.
  4. Hit detection: `Weapon.gd` calls `HitZone.take_hit(dmg, ray_dir)` -> `parent_entity.take_damage(final_dmg, is_headshot, hit_dir)` -> `health_component.take_damage(amount)` which synchronously triggers `died.emit()` -> `_on_died()`. By caching `var last_hit_dir: Vector3` in `take_damage()`, `_on_died()` has complete context (`last_hit_was_headshot` and `last_hit_dir`) to execute decapitation and directional blood burst.
  5. Blood burst: `CPUParticles3D` verified working 100% in Godot 4.3 `gl_compatibility`. Directional burst via `ImpactPool` pool + neck stump emitter attached to zombie model (moving with collapsing body) guarantees zero orphaned nodes and zero leaks.
  6. Audio/Hitmarker: `sfx_headshot_crunch.ogg` and `HUD.show_hitmarker(true)` already trigger on headshots; decapitation can add visceral flesh squelch sound and neck spurting.
- **Unexplored areas**: None. All 4 target areas thoroughly investigated and validated.

## Key Decisions Made
- Architecture recommendations prepared for implementation team.
- Verification tests confirm 88/88 tests pass on `test_realistic_overhaul.tscn` and 13/13 missions pass on `validate_all_missions.gd`.

## Artifact Index
- handoff.md — Final investigation report
- progress.md — Liveness heartbeat and progress tracking
- inspect_bones.gd — Skeleton and bone inspection tool
- inspect_bone_tree.gd — Bone hierarchy inspection tool
- inspect_meshes.gd — Mesh names and surfaces inspection tool
- inspect_soldier_mesh.gd — Soldier zombie mesh AABB inspector
- test_bone_scale.gd — Bone scaling verification script
- test_anim_scale.gd — AnimationPlayer scale track override tester
- test_cpu_particles.gd — CPUParticles3D gl_compatibility tester
