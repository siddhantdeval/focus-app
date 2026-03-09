# Phase 1.2: High-Fidelity Design & Core State Bridging
**Status:** Planning / Next Action
**Reference:** [Design Plan](DESIGN_PLAN.md) | [Architecture](ARCHITECTURE.md)

## 1. Phase Objective
Phase 1 established the functional "Skeleton" (Rust Core compiling, FFI boundaries established, simple UI lists working). 
**Phase 1.2** is the bridge between the skeleton and full production. Its goal is to take the 10 high-fidelity screens specified in `screen_specifications/` and definitively map them to the underlying Rust **State, Data Models, and Interaction Logic**. By the end of this phase, the native UI will look exactly like the designs and interact flawlessly with the local SQLite data engine without UI-side business logic.

---

## 2. Technical Mapping & Phase Rollout
The 10 high-fidelity screens from `DESIGN_PLAN.md` are mapped to the `focus_core` Rust backend below. To ensure a stable rollout, their actual implementation and integration is scoped strictly by phase according to `ARCHITECTURE.md`.

### A. Phase 1.2 Implementation Scope (Core App Workflow)
*These screens and their Rust bindings are the primary focus of Phase 1.2.*

**S1: Productivity Dashboard (`S1_PRODUCTIVITY_DASHBOARD.md`)**
*   **UX Goal:** View active timer and today's tasks.
*   **Rust State Subscriptions:** `subscribe_timer_state()`, `subscribe_daily_tasks()`
*   **Business Logic:** `TimerService::start_session(task_id)` transitions state to `RUNNING`. `TaskService::toggle_completion(task_id)` updates SQLite and emits `TasksUpdated` for native UI diffing.

**S2: Task Management View (`S2_TASK_MANAGEMENT.md`)**
*   **UX Goal:** Sortable, groupable list of all tasks.
*   **Rust State Subscriptions:** `subscribe_all_tasks(SortOrder)`
*   **Business Logic:** Inline `onSubmit` calls `TaskService::create_task(title)`. UI calls `get_grouped_tasks(GroupBy::Date)` to enforce "dumb UI" grouping.

**S4: Focus Mode (`S4_FOCUS_MODE.md`)**
*   **UX Goal:** Distraction-free full-screen timer.
*   **Rust State Subscriptions:** `subscribe_timer_state()`
*   **Business Logic:** Handles edge cases like OS Sleep by comparing `current_time` against `expected_end_time` upon wake to snap UI state.

**S6: Settings (`S6_SETTINGS.md`)**
*   **Business Logic:** Edits to application preferences are written directly to the `app_settings` SQLite table via Rust `ConfigService`.

**S7: Command Palette (`S7_COMMAND_PALETTE.md`)**
*   **Business Logic:** Native keystroke (Cmd+K) summons modal. Text piped to `TaskService::fuzzy_search(query)` via FFI, powering an instant lookup against the SQLite `FTS5` virtual table.

---

### B. Phase 2 Implementation Scope (Advanced Workflows & OS Hooks)
*These screens rely on the architecture finalized in Phase 1.2, but their actual native build-out happens in Phase 2.*

**S3: Task Detail Panel (`S3_TASK_DETAIL.md`)**
*   **Rust Dependency:** `subscribe_task_detail(task_id)`.
*   **Phase 2 Logic:** Deep subtask trees (`add_subtask`), recurring task logic (`ReportingEngine::schedule_reminder`), and debounced Markdown parsing (`NoteService::upsert_note`).

**S8: Menu Bar / System Tray (`S8_MENU_BAR.md`)**
*   **Rust Dependency:** `TimerSnapshot`.
*   **Phase 2 Logic:** Requires separate lightweight OS process that queries Rust via RPC/FFI without launching the main heavy UI sandbox.

**S10: Rich Notifications (`S10_NOTIFICATIONS.md`)**
*   **Rust Dependency:** `SessionComplete` events.
*   **Phase 2 Logic:** Native callback handlers hook into Apple `UNUserNotificationCenter` / Windows Toast to provide actionable alerts (e.g., "Skip Break").

---

### C. Phase 3 Implementation Scope (Insights & Polish)
*These screens are implemented in the final pre-release phase once data is collected.*

**S5: Reports & Analytics (`S5_REPORTS.md`)**
*   **Rust Dependency:** `ReportingEngine::get_weekly_summary()`.
*   **Phase 3 Logic:** Aggregates `pomodoro_sessions` table strictly inside Rust to prevent massive JSON string passing over FFI.

**S9: OS Widgets (`S9_OS_WIDGETS.md`)**
*   **Rust Dependency:** `TimerSnapshot`, `Tasks`.
*   **Phase 3 Logic:** Interactive widgets (macOS Sonoma, iOS 17+) require specific App Group / shared container architectures to read the SQLite file concurrently.

---

## 3. Data Integrity & Architecture Constraints

To support the above UI interactions, the underlying SQLite database and memory models enforce the following:

1.  **Immutability in UI:** The Native UI layers (SwiftUI/WinAppSDK) must treat all Rust instances as strictly immutable. Any mutation must go through a command method (e.g., `update_task()`).
2.  **Thread Safety:** The Rust shared library encapsulates raw SQLite connections within a dedicated, synchronous Database Worker thread. Native UI actions send commands via an `mpsc` channel to this worker, avoiding blocking the UniFFI boundary and bypassing `tokio` async complexity.
3.  **No Native State:** If a variable represents business logic (e.g., "is the timer running?"), it cannot be stored as a local `@State` variable in Swift. It must be derived entirely from the Rust Event Stream.

---

## 4. Revalidation & Testing Plan

Before concluding Phase 1.2, the implementation must be validated against the following criteria:

### Validation 1: Structural Completeness
- [ ] All 10 `screen_specifications/` documents have been translated to native view structurally (e.g., all buttons exist, layouts match the 8px grid).

### Validation 2: FFI Coupling
- [ ] Mock UI actions (pressing "Start", adding a task) correctly route through the UniFFI bridge.
- [ ] The Rust logger outputs confirm the state has been mutated.

### Validation 3: UI Reactivity (The "Dumb UI" Test)
- [ ] Updating a task via a direct SQLite insertion locally (bypassing the UI) should trigger an event stream that causes the Native UI to automatically visually update without a manual refresh action.

### Validation 4: Performance & Leaks
- [ ] Render a list of 1,000 tasks. Ensure scrolling FPS remains at 60/120Hz natively.
- [ ] Ensure `TimerState` subscriptions do not create runaway memory leaks on the FFI boundary after 100+ start/stop toggles.
