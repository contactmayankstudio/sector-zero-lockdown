# Dispatch: explorer_hud_feedback

## Mission
Investigate the HUD, Player damage signaling, and Audio infrastructure for Requirement R1 (Screen Blood Splatter & Low-HP Feedback).

## Target Systems
- `scenes/UI/HUD.tscn` and `scenes/UI/HUD.gd`
- `scenes/player/Player.tscn` and `scripts/Player.gd`
- Existing damage indication (claw scratches, red damage arcs)
- Audio system: Audio streams, audio buses in `default_bus_layout.tres`, heartbeat sound availability
- Low-HP vignette: How screen vignette is currently handled, how to implement rhythmic pulsing red vignette below 30% HP that subsides on recovery
- Dynamic screen blood splatter: CanvasLayer/Control nodes, fading droplets on damage taking 2.5s to fade out, mobile/gl_compatibility performance.

## Output
Write complete findings and recommendations to `/home/am/targetkill/.agents/explorer_hud_feedback/handoff.md`.

## 2026-09-13T18:26:30Z
Investigate Requirement R1: Screen Blood Splatter & Low-HP Feedback:
- When taking damage from a zombie melee attack, render dynamic, fading blood droplets/splatters on the player's screen/HUD that smoothly dissipate over 2.5 seconds.
- When player health drops below 30% (<30 HP), activate a visible rhythmic pulsing red screen vignette and looping heartbeat audio that subsides upon recovery (>=30 HP).

Examine:
1. scenes/UI/HUD.tscn and scenes/UI/HUD.gd (how HUD handles damage arcs, claw scratches, overlays, textures, and canvas layers).
2. scenes/player/Player.tscn and scripts/Player.gd (health management, take_damage signal/method, how it communicates with HUD and audio).
3. Audio system: default_bus_layout.tres, existing audio files in res://audio/ or res://audio/ambience/, whether a heartbeat audio file exists or needs to be provided/generated/synthesized.
4. Rendering technique for blood splatters (dynamic TextureRect/ColorRect/Custom Control draw or particle overlay) and pulsing vignette (ShaderMaterial vs ColorRect/AnimationPlayer/Tween) under gl_compatibility renderer without memory leak or performance drop.

Document concrete architecture, exact file modifications, node hierarchy additions, and implementation recommendations. Write your complete findings to:
/home/am/targetkill/.agents/explorer_hud_feedback/handoff.md

## 2026-09-13T18:29:17Z
**Context**: Surveying HUD and Audio infrastructure for R1 (Screen Blood Splatter & Low-HP Feedback).
**Content**: You initialized progress.md but stopped before investigating the target files. Please proceed with:
1. View and analyze scenes/UI/HUD.tscn and scenes/UI/HUD.gd.
2. View and analyze scenes/player/Player.tscn and scripts/Player.gd.
3. Check audio bus and available sounds in res://audio/ for heartbeat.
4. Design the dynamic fading blood splatter overlay (2.5s dissipation) and rhythmic pulsing red vignette (<30% HP).
5. Write your complete findings to /home/am/targetkill/.agents/explorer_hud_feedback/handoff.md.
**Action**: Execute these investigations immediately and write handoff.md.
