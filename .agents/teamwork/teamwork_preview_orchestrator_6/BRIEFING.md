# BRIEFING — 2026-10-10T19:05:00Z

## Mission
Deliver Sector Zero: Lockdown in Godot 4.7.2 Mono (C# / .NET 8) with permanent 3D terrain collision, 4x4 mountain vehicle climbing, zero-error C# architecture & subsystems, and crisp PBR visuals optimized for AMD Kabini APU.

## 🔒 My Identity
- Archetype: teamwork_preview_orchestrator
- Roles: orchestrator, user_liaison, human_reporter, successor
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_6
- Original parent: parent
- Original parent conversation ID: 784a9f26-50a0-4c22-8212-4fb5989bd46d

## 🔒 My Workflow
- **Pattern**: Project Pattern
- **Scope document**: /home/am/targetkill/PROJECT.md
1. **Decompose**:
   - Survey: Map existing codebase via 3 Explorers (COMPLETE).
   - Decompose into cohesive milestones:
     - M1: Core Implementation — Permanent 3D Collision, Vehicle Climbing, C# & Visuals (F1-F9) [IN_PROGRESS]
     - M2: Automated E2E Verification & Adversarial Hardening (F10) [PLANNED]
2. **Dispatch & Execute**:
   - Direct iteration loop per milestone: 3 Explorers -> 1 Worker -> 2 Reviewers -> 2 Challengers -> 1 Auditor -> Gate check in GATE_STATUS.md.
3. **On failure** (in this order):
   - Retry: nudge stuck agent or re-send task
   - Replace: spawn fresh agent with partial progress
   - Skip: proceed without (only if non-critical)
   - Redistribute: split stuck agent's remaining work
   - Redesign: re-partition decomposition
4. **Succession**: Self-succeed when spawn count >= 16 and all subagents complete.
- **Work items**:
  1. Survey phase (3 Explorers) [DONE]
  2. Decomposition & PROJECT.md update [DONE]
  3. Milestone 1 implementation [IN_PROGRESS]
  4. Milestone 2 verification [PLANNED]
- **Current phase**: 2 (Milestone M1 Execution)
- **Current focus**: Milestone M1 Worker execution (F1 to F9)

## 🔒 Key Constraints
- NEVER write, modify, or create source code files directly.
- NEVER run build/test commands yourself — require workers to do so.
- NEVER investigate or explore the problem at the code level — dispatch Explorers for technical investigation.
- Use file-editing tools ONLY for metadata/state files (.md) in .agents/teamwork/.
- Mandate strict integrity warnings in Worker prompt (no hardcoding, no dummy facades).
- Forensic Auditor INTEGRITY VIOLATION is a binary veto.
- gl_compatibility / OpenGL 3 mode on AMD Kabini (3.3 GB RAM).
- Headless tests must exit 0.

## Current Parent
- Conversation ID: 784a9f26-50a0-4c22-8212-4fb5989bd46d
- Updated: not yet

## Key Decisions Made
- Dispatched Worker `14e5384c-2d31-4c68-a1f4-df39326ce020` armed with comprehensive blueprints from Explorers M1 1, M1 2, and M1 3.
- Exclusive write ownership granted for target terrain scene, scripts, materials, and vehicle files.

## Team Roster
| Agent | Type | Work Item | Status | Conv ID |
|-------|------|-----------|--------|---------|
| explorer_survey_1_gen6 | teamwork_preview_explorer | Survey R1: Terrain Collision & Car Physics | completed | dfafc622-6bc0-418c-8da1-dac30ba5f3e9 |
| explorer_survey_2_gen6 | teamwork_preview_explorer | Survey R2: C# .NET 8 Subsystems & Build | completed | f3fb2869-4fe6-4c0d-ac44-e24293b56b62 |
| explorer_survey_3_gen6 | teamwork_preview_explorer | Survey R3: Visuals, MultiMeshes & Verification | completed | c9b3bff8-eee3-4806-a8fb-21b2747eb31a |
| explorer_m1_1 | teamwork_preview_explorer | M1 Blueprint: Colliders, Serialization & Transitions | completed | 7915678e-38b3-4593-8de6-dcef5c3bacf9 |
| explorer_m1_2 | teamwork_preview_explorer | M1 Blueprint: 4x4 Vehicle Physics & C# Subsystems | completed | 04e1cc69-17fb-4f61-a03a-87c83d571eb7 |
| explorer_m1_3 | teamwork_preview_explorer | M1 Blueprint: Visuals, Atmosphere & MultiMeshes | completed | f4b90f67-5dc2-4b97-a22d-e87da065cdc1 |
| worker_m1_gen6 | teamwork_preview_worker | M1 Core Implementation: F1 through F9 | in-progress | 14e5384c-2d31-4c68-a1f4-df39326ce020 |

## Succession Status
- Succession required: no
- Spawn count: 7 / 16
- Pending subagents: 14e5384c-2d31-4c68-a1f4-df39326ce020
- Predecessor: teamwork_preview_orchestrator_5
- Successor: not yet spawned

## Active Timers
- Heartbeat cron: 9b0d70d2-fb33-4bea-a8d5-73de0e0182f7/task-36
- Safety timer: none
- On succession: kill all timers before spawning successor
- On context truncation: run `manage_task(Action="list")` — re-create if missing

## Artifact Index
- /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md — Authoritative user request
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_6/DISPATCH.md — Orchestrator dispatch instructions
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_6/BRIEFING.md — Working memory & state
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_6/plan.md — Orchestration plan
- /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_6/progress.md — Progress and heartbeat log
- /home/am/targetkill/PROJECT.md — Global architecture and milestone plan
