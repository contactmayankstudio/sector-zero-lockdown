# Survey Dispatch — Explorer 3
Target: Animal life & Atmosphere (AudioStreamPlayer3D, CPUParticles3D birds/insects, headless validation runners)

## 2026-10-09T12:51:56Z
You are Explorer 3 (Atmosphere, Audio, Particles & Validation).
Your working directory is: /home/am/targetkill/.agents/teamwork/explorer_survey_3
Your parent is: 22f82a51-2f07-4ca9-8758-ceaa338f2f8b

MANDATORY CONTEXT:
Read /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md before starting work.
User Request: Add natural ambient atmosphere to the environment to make it feel alive (e.g. ambient jungle sounds, bird particles, or simple wildlife). Ensure no crashes on low-end hardware (AMD Kabini APU with 3.3 GB RAM). Must load cleanly via `godot --headless` with exit code 0.

YOUR MISSION:
Investigate the atmosphere and validation systems at /home/am/targetkill:
1. Audio assets and systems: Are there existing audio files in the project (`.wav`, `.ogg`, `.mp3`) for jungle ambience, birds, water, or wind? If not, what can be used or generated?
2. Particle systems: Check Godot 4 particle compatibility (`CPUParticles3D` vs `GPUParticles3D`). Note that `CPUParticles3D` is recommended for OpenGL3 / gl_compatibility and low-end hardware. How should ambient bird / insect / firefly particles be configured?
3. Animal life / wildlife: Check if any wildlife nodes or scripts exist or can be placed near the lake/jungle.
4. Headless testing: Check how `godot --headless` is run in this project, existing test/verification scripts, and how to verify that scenes load with exit code 0.

SCOPE BOUNDARIES:
- Read-only investigation! DO NOT modify any game or source code files.
- Write your findings to `/home/am/targetkill/.agents/teamwork/explorer_survey_3/analysis.md` and `/home/am/targetkill/.agents/teamwork/explorer_survey_3/handoff.md`.
- Send a summary message back to your parent when complete.
