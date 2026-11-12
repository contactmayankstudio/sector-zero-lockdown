# BRIEFING — 2026-10-10T07:45:00Z

## Mission
Finalize and optimize the open-world 3D mountain arena in Godot 4 (gl_compatibility renderer, AMD Kabini APU target), ensuring full vehicle mountain drivability (Police Cruiser car & Hayabusa superbike can climb mountain slopes smoothly), crystal-clear alpine visuals (grass/dirt full brightness, UV tiling, cliff triplanar, relocated lake, fog/tonemap tuning), and stable 45-60 FPS performance with automated headless verification.

## 🔒 My Identity
- Archetype: teamwork_preview_orchestrator
- Roles: orchestrator, user_liaison, human_reporter, successor
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_5
- Original parent: parent
- Original parent conversation ID: 9d1bab3a-9eb5-41e5-bbf2-c22b9537d814

## 🔒 My Workflow
- **Pattern**: Project Pattern
- **Scope document**: /home/am/targetkill/PROJECT.md
1. **Decompose**:
   - Survey: Map existing codebase, vehicle physics, curb colliders, terrain generators, materials/shaders, and tests via 3 Explorers.
   - Decompose into cohesive milestones (M1: Vehicle Drivability & Physics, M2: Visual Quality & Alpine Materials, M3: Integration, E2E Testing & Performance).
2. **Dispatch & Execute**:
   - Direct iteration loop per milestone: Explorer(s) -> Worker -> Reviewers (2) -> Challengers (2) -> Auditor -> Gate check in GATE_STATUS.md.
3. **On failure** (in this order):
   - Retry: nudge stuck agent or re-send task
   - Replace: spawn fresh agent with partial progress
   - Skip: proceed without (only if non-critical)
   - Redistribute: split stuck agent's remaining work
   - Redesign: re-partition decomposition
4. **Succession**: Self-succeed when spawn count >= 16 and all subagents complete.
- **Work items**:
  1. Survey phase [in-progress]
  2. Decomposition & PROJECT.md update [pending]
  3. Milestone execution [pending]
  4. Final E2E and adversarial verification [pending]
- **Current phase**: 0 (Survey)
- **Current focus**: Parallel codebase survey across R1, R2, R3

## 🔒 Key Constraints
- NEVER write, modify, or create source code files directly.
- NEVER run build/test commands yourself — require workers to do so.
- NEVER investigate or explore the problem at the code level — dispatch Explorers for technical investigation.
- Use file-editing tools ONLY for metadata/state files (.md) in .agents/teamwork/.
- Mandatory integrity warning in Worker prompt.
- Binary veto by Forensic Auditor if integrity violation detected.
- Maintain gl_compatibility / OpenGL 3 compatibility on Linux under AMD Kabini 3.3 GB memory budget.
- godot --headless exit code 0.

## Current Parent
- Conversation ID: 9d1bab3a-9eb5-41e5-bbf2-c22b9537d814
- Updated: not yet

## Key Decisions Made
- Initialized Generation 5 orchestrator. Dispatched 3 parallel Explorers for full codebase survey across R1, R2, R3.

## Team Roster
| Agent | Type | Work Item | Status | Conv ID |
|-------|------|-----------|--------|---------|
| explorer_survey_1 | teamwork_preview_explorer | Survey R1: Vehicle Physics & Curbs | in-progress | 7ae6ff58-dcb7-4da8-8fe0-4b3580fe2c21 |
| explorer_survey_2 | teamwork_preview_explorer | Survey R2: Visuals, Lake & Materials | in-progress | 4c7de90c-84a5-487e-a408-61212dcfed95 |
| explorer_survey_3 | teamwork_preview_explorer | Survey R3: Test Suite & Performance | in-progress | c17d5274-7a3f-47f1-be57-98cd84f9280c |

## Succession Status
- Succession required: no
- Spawn count: 3 / 16
- Pending subagents: 7ae6ff58-dcb7-4da8-8fe0-4b3580fe2c21, 4c7de90c-84a5-487e-a408-61212dcfed95, c17d5274-7a3f-47f1-be57-98cd84f9280c
- Predecessor: 9d1bab3a-9eb5-41e5-bbf2-c22b9537d814
- Successor: not yet spawned

## Active Timers
- Heartbeat cron: 2e84f16f-f7b1-498c-9ad7-62da48296ae3/task-38
- Safety timer: none
- On succession: kill all timers before spawning successor
- On context truncation: run `manage_task(Action="list")` — re-create if missing

## Artifact Index
- /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md — Authoritative user request
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_5/DISPATCH.md — Orchestrator dispatch instructions
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_5/BRIEFING.md — Working memory & state
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_5/progress.md — Progress and heartbeat log
