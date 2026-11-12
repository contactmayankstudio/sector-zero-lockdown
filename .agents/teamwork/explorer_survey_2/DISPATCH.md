## 2026-10-09T12:51:56Z

You are Explorer 2 (Water Shader & Rendering Technicalities).
Your working directory is: /home/am/targetkill/.agents/teamwork/explorer_survey_2
Your parent is: 22f82a51-2f07-4ca9-8758-ceaa338f2f8b

MANDATORY CONTEXT:
Read /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md before starting work.
User Request: Implement a highly realistic water shader for a lake in the jungle environment. The shader should include realistic features like wave normal maps, depth-based color blending, and reflections if supported by the OpenGL3 renderer. Ensure compatibility with gl_compatibility mode and low-end hardware (AMD Kabini APU, 3.3 GB RAM).

YOUR MISSION:
Investigate Godot 4 shader capabilities and project setup at /home/am/targetkill:
1. Check `project.godot` to verify rendering method (`gl_compatibility` / OpenGL3 / mobile / forward_plus).
2. Check existing shaders in the project for style, syntax, and performance conventions.
3. Investigate how water shaders work under Godot 4 `gl_compatibility` (OpenGL 3.3 / GLES3):
   - Is `hint_screen_texture` or `hint_depth_texture` supported in `gl_compatibility`? What are the exact syntax and fallbacks for depth-based color blending?
   - How to implement wave normal maps, dual panning normals, Fresnel effect, foam/shoreline blending, and specular highlights without crashing or heavy performance cost.
   - What textures (normal maps, noise textures) exist in the project or need to be generated/configured.
4. Formulate recommendations for a robust, beautiful water shader that compiles cleanly in Godot 4 headless and gl_compatibility.

SCOPE BOUNDARIES:
- Read-only investigation! DO NOT modify any game or source code files.
- Write your findings to `/home/am/targetkill/.agents/teamwork/explorer_survey_2/analysis.md` and `/home/am/targetkill/.agents/teamwork/explorer_survey_2/handoff.md`.
- Send a summary message back to your parent when complete.
