# Phase 1.2: Design System & High-Fidelity Bridging

## 1. Overview
Phase 1.2 serves as the architectural bridge between the Phase 1 "Skeleton" (functional FFI) and the Phase 2 "Feature Production." In this phase, we analyze the 10 core screens of the Focus application to ensure every visual element has a corresponding Rust state, a data model, and an interaction handler.

## 2. Screen Analysis Workflow
For each screen identified in `DESIGN_PLAN.md` and `design_asset/`, we generate a comprehensive **Screen Specification** document following the "Senior Architect & UX Engineer" prompt format.

| Screen ID | Filename | Description |
| :--- | :--- | :--- |
| S1 | `S1_PRODUCTIVITY_DASHBOARD.md` | Main hub with timer and task list. |
| S2 | `S2_TASK_MANAGEMENT.md` | Grouped views for Today/Upcoming. |
| S3 | `S3_TASK_DETAIL.md` | Subtasks, notes, and scheduling details. |
| S4 | `S4_FOCUS_MODE.md` | Minimalist immersion view. |
| S5 | `S5_REPORTS.md` | Productivity analytics and charts. |
| S6 | `S6_SETTINGS.md` | App-wide preferences. |
| S7 | `S7_COMMAND_PALETTE.md` | Keyboard-driven Cmd+K modal. |
| S8 | `S8_MENU_BAR.md` | System tray / Menu bar dropdown. |
| S9 | `S9_OS_WIDGETS.md` | Desktop and mobile interactive widgets. |
| S10| `S10_NOTIFICATIONS.md` | Rich OS alerts and actions. |

## 3. Core Design Tokens
Before implementing the screens, the following tokens must be finalized in the native UI (SwiftUI/WinUI):
- **Colors:** Primary Background (`#000000` / `#FFFFFF`), Accent (`#1c7fe3`), Divider (`#333333`).
- **Typography:** Inter (Primary), System Monospaced (Timer).
- **Spacing:** 8px grid (8, 16, 24, 32, 48).

## 4. State Harmonization
The outcome of this phase is a mapping of every UI trigger to a Rust `Service` call. 
Example:
- `Dashboard -> Start Timer Button` -> `focus_core::TimerService::start_session(task_id)`
- `TaskDetail -> Add Subtask` -> `focus_core::TaskService::add_subtask(parent_id, title)`
