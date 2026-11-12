# DISPATCH — 2026-09-07T15:52:42Z

You are the Project Orchestrator (orchestrator_4) for Sector Zero: Lockdown.

Working Directory: `/home/am/targetkill/.agents/orchestrator_4`
Project Workspace: `/home/am/targetkill`
Original Request: `/home/am/targetkill/.agents/ORIGINAL_REQUEST.md` (and `/home/am/targetkill/ORIGINAL_REQUEST.md`)

## Core Mission:
Overhaul "Sector Zero: Lockdown" into a high-clarity 3D mobile zombie shooter matching the visual style, weapon mechanics, and enemy diversity of Dead Target, fully optimized for 30 FPS on low-spec hardware.

## Requirements:

### R1. First-Person Tactical Weapons & SWAT Combat Arms
- All weapons in the armory (USP-45, MP5, M4A1, AK-47, Remington 870, Desert Eagle, AWP, Combat Knife, Crossbow, Grenade Launcher) must load complete native 3D weapon models with authentic materials and textures.
- The player's first-person view must feature realistic tactical SWAT combat arms (gloved hands and forearm skin) correctly aligned with the equipped firearm.
- Gunplay must feature dynamic muzzle flashes, realistic recoil kick, weapon switching, and automatic magazine reload when ammo reaches 0.

### R2. Zombie Roster, Quadruped Infected Dogs, and Audio
- The infected dog archetype must spawn as a genuine 4-legged skeletal canine with full animation playback (run, attack, hit_head, hit_body, death, idle), lower ground-level collision capsule, and dedicated barking, biting, and death audio streams.
- Humanoid zombies must display vivid Dead Target-style outfit variations: safety orange worker jumpsuits with blue undershirts and blood stains, civilian denim jeans with stained shirts, and necrotic diseased skin with glowing red eyes.
- Support all enemy archetypes across missions (normal, fast, heavy, spitter, dog, boss) with appropriate stats, rewards, and audio cues.

### R3. High-Clarity Environments & Atmosphere
- Environment scenes (AirportServiceRoad, AirportTerminal, etc.) must render with high visual clarity: dark aggregate asphalt road with yellow boundary/lane divider lines, road wear, barriers, and shipping containers matching Dead Target's look.
- Clear atmospheric lighting: warm sunlight, rich ground shadows, vibrant procedural sky, and complete elimination of washed-out white fog glare or overexposed bloom.
- Maintain low-spec optimization: native 1.0 3D resolution scale with FXAA, zero texture recompression hangs, locked 30 FPS, and low processor mode safeguards.

### R4. Pure Mobile / Android HUD & Input Controls
- Maintain full Android mobile touch controls: visible virtual movement joystick on bottom-left, responsive swipe look/aim area, large circular Fire button on bottom-right, circular Reload button, weapon Switcher button, and Grenade button.
- The mouse cursor must remain free and visible (never captured or trapped: `Input.MOUSE_MODE_VISIBLE`) so the player can interact seamlessly via mouse click/drag touch emulation.
- Include tactical HUD feedback: directional red damage indicator arcs, bloody claw scratch overlays on screen edges when taking damage, crosshair hitmarkers, and top bar with health and ammo counters.

## Acceptance Criteria
- [ ] Switching between all unlocked weapons loads the complete 3D model without missing `.scn` or resource errors.
- [ ] Combat arms (`FPSArms`) are visible in first-person camera view holding the active weapon.
- [ ] Firing an empty magazine automatically triggers reload without freezing the weapon state.
- [ ] Mission 2 spawns 4-legged animated infected dogs (`infected_dog.tscn`) that run, leap, bite, and collapse on death.
- [ ] Dog barks and snarling play through `SfxGrowl`, bite attacks play through `SfxAttack`, and death whimpers play through `SfxDeath`.
- [ ] Normal and fast zombies display vivid randomized clothing palettes (orange overalls, blue jeans, blood stains) instead of monochrome meshes.
- [ ] Road surfaces display realistic asphalt texturing with yellow divider lines and tire tracks.
- [ ] The environment renders sharp, high-contrast visuals with zero milky white fog glare.
- [ ] The project starts and runs smoothly at 30 FPS on the AMD APU without system freeze or hanging importer tasks.
- [ ] Virtual Joystick and all HUD buttons (Fire, Reload, Switch, Grenade) are visible and responsive to touch / click events.
- [ ] Mouse cursor is never captured (`Input.MOUSE_MODE_VISIBLE` is maintained).
- [ ] Directional damage arcs and claw scratch effects trigger properly upon taking zombie hits.

## Verification Resources
- Verification scripts: `test_m2_play.gd`, `test_capture_mission2.gd`, `test_p_verify.gd`
- Reference visuals: `/home/am/Music/real/` (Dead Target benchmark screenshots)

Please initialize your BRIEFING.md and progress.md, decompose this work into workstreams, dispatch specialist subagents, coordinate them to completion, and notify the Sentinel when the overhaul is ready for Victory Audit.
