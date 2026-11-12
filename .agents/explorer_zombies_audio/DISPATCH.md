# DISPATCH — Explorer Zombies & Audio

You are the Zombie Roster & Canine Audio Explorer (`explorer_zombies_audio`).
Working Directory: `/home/am/targetkill/.agents/explorer_zombies_audio`
Original Request: `/home/am/targetkill/.agents/ORIGINAL_REQUEST.md`
Project Index: `/home/am/targetkill/PROJECT.md`

## Mission:
Investigate R2: Zombie Roster, Quadruped Infected Dogs, and Audio for the Dead Target visual & audio overhaul.

## Key Investigation Scope:
1. Quadruped Infected Dogs:
   - Check `InfectedDog.tscn`, `scripts/InfectedDog.gd`, `assets/3d/zombies/infected_dog.glb` or `.tscn`.
   - Verify genuine 4-legged skeletal canine model and animation playback: `run`, `attack`, `hit_head`, `hit_body`, `death`, `idle`.
   - Check ground-level collision capsule and hit zones (`HeadHitZone` 2.5x, `BodyHitZone` 1.0x).
   - Audio integration: dedicated barking/snarling (`SfxGrowl`), bite attacks (`SfxAttack`), and death whimpers (`SfxDeath`).
   - Check Mission 2 spawning (`AirportServiceRoad.tscn`, `resources/missions/mission_02.tres`, `ZombieDirector.gd`).
2. Humanoid Zombies & Dead Target Outfit Variations:
   - Check all humanoid zombie archetypes: normal, fast, heavy, spitter, boss.
   - Inspect models, materials, textures, and shaders in `scenes/zombies/` and `assets/3d/zombies/`.
   - Check Dead Target visual style requirements: safety orange worker jumpsuits with blue undershirts and blood stains, civilian denim jeans with stained shirts, necrotic diseased skin, and glowing red eyes.
   - Verify stats, rewards, and audio cues for each archetype.
3. Verification Scripts:
   - Check `test_m2_play.gd`, `test_capture_mission2.gd`, `test_p_verify.gd`, and reference visuals at `/home/am/Music/real/`.
4. Concrete Implementation Plan:
   - Specific files needing modifications or creation.
   - Clear recommendations for the implementation Worker.

## Deliverables:
- Detailed technical report at `/home/am/targetkill/.agents/explorer_zombies_audio/report.md`.
- Handoff file at `/home/am/targetkill/.agents/explorer_zombies_audio/handoff.md`.

## 2026-09-07T15:57:08Z
You are explorer_zombies_audio.
Working Directory: /home/am/targetkill/.agents/explorer_zombies_audio
Original Request: /home/am/targetkill/.agents/ORIGINAL_REQUEST.md
Dispatch Instructions: /home/am/targetkill/.agents/explorer_zombies_audio/DISPATCH.md
Project Index: /home/am/targetkill/PROJECT.md

Investigate R2: Zombie Roster, Quadruped Infected Dogs, and Audio.
Analyze the infected dog archetype (genuine 4-legged skeletal canine with full animations: run, attack, hit_head, hit_body, death, idle; lower ground-level collision capsule; dedicated audio SfxGrowl, SfxAttack, SfxDeath), humanoid zombie variations matching Dead Target (safety orange jumpsuits, blue undershirts, blood stains, denim jeans, necrotic skin, glowing red eyes), and enemy archetypes across missions.
Check test scripts test_m2_play.gd, test_capture_mission2.gd, test_p_verify.gd.
Write your detailed report to /home/am/targetkill/.agents/explorer_zombies_audio/report.md and your final handoff to /home/am/targetkill/.agents/explorer_zombies_audio/handoff.md.
Send a message to your orchestrator when done.

## 2026-09-07T16:16:12Z
**Context**: Survey Phase Step 0
**Content**: Checking in on your investigation progress. Explorer weapons_arms has completed. What is your current status and ETA for report.md and handoff.md?
**Action**: Please provide a brief status update or finalize your handoff report.
