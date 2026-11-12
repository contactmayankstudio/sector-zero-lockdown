# BRIEFING — 2026-10-09T12:49:19Z

## Mission
Refine CityCarZombieArena environment in Godot 4: realistic lake with OpenGL3-compatible water shader (depth & waves), ambient atmosphere (audio/particles), low-end performance optimization, verified headless load.

## 🔒 My Identity
- Archetype: teamwork_preview_orchestrator
- Roles: orchestrator, user_liaison, human_reporter, successor
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_3
- Original parent: parent
- Original parent conversation ID: ce61d6cc-a768-4d7e-aeb0-81e6163374d2

## 🔒 My Workflow
- **Pattern**: Project Pattern
- **Scope document**: /home/am/targetkill/PROJECT.md
1. **Decompose**: Survey existing codebase via 3 Explorers, then decompose into milestones.
2. **Dispatch & Execute**:
   - Milestone 1: Realistic Lake Shader & Mesh (depth-based blending, wave animation, gl_compatibility support)
   - Milestone 2: Natural Ambient Atmosphere (ambient jungle audio / 3D particles for insects/birds)
   - Milestone 3: Integration, Performance Optimization & Verification (headless loading, test runner)
   - Parallel E2E Testing Track
3. **On failure**: Retry -> Replace -> Skip -> Redistribute -> Redesign
4. **Succession**: At spawn count >= 16 and all subagents complete, write handoff.md, cancel crons, spawn successor.
- **Work items**:
  1. Survey phase [in-progress]
  2. Milestone 1: Realistic Water Lake [pending]
  3. Milestone 2: Ambient Atmosphere & Wildlife [pending]
  4. Milestone 3: E2E Integration & Performance Verification [pending]
- **Current phase**: 0 (Survey)
- **Current focus**: Parallel codebase survey

## 🔒 Key Constraints
- NEVER write, modify, or create source code files directly.
- NEVER run build/test commands yourself — require workers to do so.
- NEVER investigate or explore the problem at the code level — dispatch Explorers.
- Use file-editing tools ONLY for metadata/state files (.md) in .agents/teamwork/.
- OpenGL3/gl_compatibility renderer compatibility (AMD Kabini APU with 3.3 GB RAM).
- Shader must compile without errors in gl_compatibility mode.
- godot --headless exit code 0.
- Mandatory integrity warning in Worker prompt.
- Binary veto by Forensic Auditor if integrity violation detected.

## Current Parent
- Conversation ID: ce61d6cc-a768-4d7e-aeb0-81e6163374d2
- Updated: not yet

## Key Decisions Made
- Initialized Project Pattern workflow. Starting Survey phase with 3 Explorers.

## Team Roster
| Agent | Type | Work Item | Status | Conv ID |
|-------|------|-----------|--------|---------|
| explorer_survey_1 | teamwork_preview_explorer | Survey Scene Architecture & Terrain | in-progress | 29d8cc57-d8bb-4656-8a8f-abc89df7a1cf |
| explorer_survey_2 | teamwork_preview_explorer | Survey Water Shader & OpenGL3 Tech | in-progress | 1020335d-f08c-42bb-adfe-49c3ad133cba |
| explorer_survey_3 | teamwork_preview_explorer | Survey Atmosphere, Audio & Validation | in-progress | e3f0ae61-c770-4462-93b6-477e3b2e2642 |

## Succession Status
- Succession required: no
- Spawn count: 3 / 16
- Pending subagents: 29d8cc57-d8bb-4656-8a8f-abc89df7a1cf, 1020335d-f08c-42bb-adfe-49c3ad133cba, e3f0ae61-c770-4462-93b6-477e3b2e2642
- Predecessor: none
- Successor: not yet spawned

## Active Timers
- Heartbeat cron: 22f82a51-2f07-4ca9-8758-ceaa338f2f8b/task-10
- Safety timer: none

## Artifact Index
- /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md — Authoritative user request
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_3/DISPATCH.md — Orchestrator dispatch instructions
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_3/progress.md — Progress and liveness tracker
