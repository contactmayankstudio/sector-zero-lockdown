# Dispatch: challenger_2_m1

## Milestone 1 Challenger 2 (Lifecycle & Performance Stress Testing)
Scope: Adversarially stress test the performance and lifecycle stability of Milestone 1 under `gl_compatibility`:
- Benchmark FPS and frame delta consistency during simultaneous 50-cluster blood splatters + pulsating vignette + looping heartbeat.
- Test scene reloads and queue_free transitions while low-HP heartbeat audio is actively playing to verify zero audio thread crashes, zero memory leaks, and clean node destruction.
- Confirm that no `CanvasItemMaterial` custom shaders or heavy fragment operations were introduced that would breach mobile budgets.

Write an empirical stress test script, execute it with Godot headless, and report your verdict (APPROVE or REQUEST_CHANGES) in:
`/home/am/targetkill/.agents/challenger_2_m1/handoff.md`.

## 2026-09-13T20:15:10Z
You are challenger_2_m1, an adversarial testing and verification agent.
Your working directory is: /home/am/targetkill/.agents/challenger_2_m1
Project root is: /home/am/targetkill

MANDATORY FIRST STEP: Read /home/am/targetkill/ORIGINAL_REQUEST.md completely before doing any work. Also read /home/am/targetkill/.agents/challenger_2_m1/DISPATCH.md and /home/am/targetkill/.agents/worker_m1/handoff.md.

YOUR TASK:
Adversarially challenge the performance and lifecycle stability of Milestone 1:
1. Benchmark draw performance and frame time under maximum active blood splatters and low-HP vignette.
2. Test scene reload and node cleanup while heartbeat audio is playing to verify zero audio thread deadlocks or leaked nodes.
3. Confirm gl_compatibility compliance (zero shader compiler errors or mobile VRAM bloat).
4. Run your test harness with godot --headless.
5. Formulate your verdict: APPROVE or REQUEST_CHANGES.
Write your complete findings and test results to: /home/am/targetkill/.agents/challenger_2_m1/handoff.md.
When finished, send a brief message with your handoff path and verdict.
