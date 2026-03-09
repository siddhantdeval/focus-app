# Focus: Minimalist Cross-Platform Productivity Application
## Production-Ready SDLC Design & Implementation Plan

---

## 1. Product Overview

### Problem Statement
Modern productivity applications are increasingly bloated, slow, and overly complex. Users seeking deep work and focus are constantly bombarded by confusing interfaces, slow web-based wrappers (Electron), and features they never use. A true productivity tool should disappear into the background and allow the user to work frictionlessly.

### Target Users
*   **Knowledge Workers & Developers:** Needing distraction-free task management.
*   **Students & Academics:** Requiring structured Pomodoro sessions and clean notes.
*   **Minimalists:** Users who prefer native performance and low cognitive load over feature abundance.

### UX Philosophy
*   **Focus-First:** The timer and current task take center stage.
*   **Minimalist:** Zero visual clutter, utilizing negative space.
*   **Keyboard-Centric:** Instant task entry, navigation, and control via global shortcuts.
*   **Local-First:** Immediate interactions with zero latency. No loading spinners.

### Core User Workflows
1.  **Capture:** Press global hotkey → Type task → Hit Enter.
2.  **Focus:** Select Task → Hit Spacebar (Start Pomodoro) → Interface minimizes to a floating widget/menu bar.
3.  **Review:** Open app end-of-day → View daily completion report.

---

## 2. System Architecture

To guarantee absolute **Native Look and Feel**, **Fast Performance**, and **Clean Modular Architecture**, the application will use a **Shared Core Architecture** powered by Rust, with fully native UI layers.

### High-Level Architecture
The system follows a strict **Clean Architecture** pattern, segmented into three primary layers:
1.  **UI Layer (Native):** SwiftUI (macOS/iOS), Jetpack Compose (Android), WinUI 3 (Windows). 
2.  **FFI Boundary:** UniFFI to generate bindings between the Rust Core and Native UI.
3.  **Core Logic & State (Rust):** The single source of truth for business logic, state management, timer engines, and local database interaction.

### Module Architecture
*   **State Layer:** Centralized Redux-style unidirectional data flow managed in Rust.
*   **Service Layer:** Contains use cases (`StartPomodoro`, `CompleteTask`, `SyncData`).
*   **Timer Engine:** High-precision background tick generator in Rust, dispatching events to the State Layer.
*   **Task Manager:** Handles CRUD operations, subtask trees, and recurrence generation.
*   **Reporting Engine:** Queries local SQLite to generate daily/weekly analytics.

### Local-First & Sync Architecture
*   **Local Database:** SQLite acts as the primary data store (offline-first).
*   **Sync Engine:** Employs a CRDT (Conflict-Free Replicated Data Type) or timestamp-based reconciliation over SQLite to seamlessly merge offline changes across devices via a lightweight cloud API when a connection is available.

---

## 3. Architecture Wiring (Detailed)

### Pomodoro Session Flow
1.  **User:** Clicks "Start Timer" in Native UI.
2.  **UI:** Calls `start_timer(task_id)` via FFI to Rust Core.
3.  **Timer Engine (Rust):** Initializes a ticker, updates `SessionState` to `Active`.
4.  **State Manager (Rust):** Broadcasts state change event `TimerTick(25:00)`.
5.  **UI (Native):** Observes the state stream and safely updates the visual timer.
6.  **Timer Engine:** Reaches 00:00, triggers `SessionComplete` event.
7.  **Notification Service (Native callback):** Calls OS APIs (UNUserNotification, Windows Toast) to alert the user.
8.  **Report Engine & DB:** `PomodoroSession` record is saved to SQLite contextually linked to the original Task.

### Task Creation Flow
1.  **User:** Types "Draft API Docs" and presses Enter.
2.  **UI:** Calls `create_task(title)` on the Rust Task Service.
3.  **Task Service (Rust):** Validates input, constructs a `Task` entity with a local UUID and current timestamp.
4.  **Database (Rust SQLite):** Executes `INSERT` statement into `tasks` table.
5.  **State Manager (Rust):** Detects data mutation, re-runs local query, broadcasts `TaskListUpdated`.
6.  **UI:** Re-renders the list optimally using native diffing (e.g., SwiftUI `List`).

### Reminder Trigger Flow
1.  **Scheduler (Rust):** Periodically checks the SQLite `reminders` table against the system clock.
2.  **Reminder Service (Rust):** Identifies due items and dispatches `TriggerReminder(id)`.
3.  **OS FFI Callback:** Invokes the native OS alarm/notification API.
4.  **User Interaction:** Clicks notification → Maps via Deep Link/OS Intent back to the UI focusing the specific Task.

### Sync Flow
1.  **Local DB:** Saves an entity with `updated_at` and a monotonic `version_vector`.
2.  **Sync Service (Rust):** Background queue detects unsynced changes.
3.  **Cloud API:** Sends batched payload (JSON/Protobuf) via HTTPS.
4.  **Remote Device (Rust):** Receives push event (or pulls periodically), merges changes via CRDT logic into local SQLite.
5.  **State Manager:** Emits broad `DataRefreshed` event for the UI to paint the new data.

---

## 4. Recommended Technology Stack

We avoid Electron/WebView frameworks to ensure maximum performance and minimal battery/RAM usage.

*   **Shared Core:** Rust
*   **FFI Bindings:** Mozilla UniFFI (Generates Swift, Kotlin, and C# headers)
*   **macOS / iOS UI:** Swift & SwiftUI
*   **Windows UI:** C# & WinUI 3 (Windows App SDK)
*   **Android UI:** Kotlin & Jetpack Compose
*   **Local Database:** `rusqlite` (Rust SQLite bindings)
*   **Background Services:** Native APIs (e.g., Android WorkManager, Apple BackgroundTasks) accessed via FFI callbacks.
*   **Cloud Sync Option:** Simple Golang or Rust REST/WebSocket API with PostgreSQL (for centralized sync metadata).
*   **State Management:** Reactive streams (Swift Combine/AsyncStream, Kotlin Flow, C# IObservable) subscribed to a Rust Event channel.

---

## 5. Feature Design Specifications

### Pomodoro Timer
*   **Description:** Standard 25m work / 5m break timer, customizable.
*   **Module Responsibility:** `TimerEngine` controls the raw clock; `AppUI` draws the radial/linear progress.
*   **Data Model:** `PomodoroSession { id, task_id, start_time, duration, completed }`
*   **UI Components:** Large minimalist typography, simple play/pause/skip glyphs.
*   **Edge Cases:** OS sleep/hibernate. *Solution:* Calculate time delta upon system wake.

### Tasks & Subtasks
*   **Description:** To-do items with endless or 1-level deep nesting.
*   **Module Responsibility:** `TaskManager`
*   **Data Model:** `Task { id, parent_id (nullable), title, completed, created_at, sort_order }`
*   **UI Components:** Draggable list items, contextual swipe actions.
*   **Edge Cases:** Deleting a parent task must cascade delete or archive subtasks.

### Due Dates, Reminders, Recurring Tasks
*   **Description:** Temporal constraints and repeating logic.
*   **Module Responsibility:** `ReportingEngine` & `Scheduler`
*   **Data Model:** `Reminder { id, task_id, remind_at }`, `RecurrenceRule { task_id, rrule_string }` (iRFC 5545).
*   **UI Components:** Natural language date parsing input (e.g., "Review code tomorrow at 3pm").
*   **Edge Cases:** Timezone changes while traveling. Store all times in UTC and translate at the UI layer.

### Notes
*   **Description:** Markdown-supported rich text attached to a task.
*   **Module Responsibility:** `NoteService`
*   **Data Model:** `Note { id, task_id, markdown_content, updated_at }`
*   **UI Components:** Monospace or clean Sans-Serif markdown viewer/editor.

### Reports
*   **Description:** Visual graphs of focused hours and completed tasks.
*   **Module Responsibility:** `ReportingEngine`
*   **UI Components:** Minimalist bar charts (No external heavy charting libs; build using native drawing paths).

---

## 6. UI/UX Design Specification

### Design System
*   **Color Palette:** Monochromatic. Pure Black (`#000000`), Pure White (`#FFFFFF`), and refined grays (`#F2F2F7`, `#8E8E93`, `#1C1C1E`). Accent status color (e.g., subtle green or pure white inversion) for active timers.
*   **Typography:** System Native (San Francisco on Apple, Segoe on Windows, Roboto/Inter on Android). Emphasize varied font weights over colors.
*   **Spacing System:** 8pt grid. Generous padding, no visible borders. Use typography size for hierarchy.
*   **Animations:** Spring animations for list reordering and task completion. Avoid linear durations.

### Screens
1.  **Dashboard:** Split view (Desktop) or Tab view (Mobile). Left: Task List. Right/Top: Active Timer. [Mockup](design_asset/productivity_dashboard_mockup.png)
2.  **Task Detail:** Slides in over/next to the task list. Contains Subtasks, Notes, and Due Dates. [Mockup](design_asset/task_detail_panel_view_mockup.png)
3.  **Pomodoro Fullscreen:** Distraction-free view containing *only* the clock and current task name. [Mockup](design_asset/distraction_free_focus_mode_mockup.png)
4.  **Mini/Menu Bar View:** (Desktop) Tiny omnipresent timer in the system tray. [Mockup](design_asset/menu_bar_status_app_dropdown_mockup.png)
5.  **Analytics:** Simple daily/weekly summary. [Mockup](design_asset/productivity_reports_view_mockup.png)

---

## 7. Database Design (SQLite)

```sql
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    parent_id TEXT NULL,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT 0,
    due_date INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    sync_version INTEGER DEFAULT 0,
    FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE INDEX idx_tasks_parent ON tasks(parent_id);

CREATE TABLE pomodoro_sessions (
    id TEXT PRIMARY KEY,
    task_id TEXT,
    start_time INTEGER NOT NULL,
    duration_seconds INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT 0,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL
);

CREATE TABLE reminders (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    remind_at INTEGER NOT NULL,
    is_fired BOOLEAN DEFAULT 0,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    task_id TEXT UNIQUE NOT NULL,
    content TEXT,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE sync_metadata (
    key TEXT PRIMARY KEY,
    last_sync_timestamp INTEGER,
    cursor_token TEXT
);
```
*(Users table is omitted as the app is Local-First. Sync authenticates via a secure keychain token hitting the Cloud API directly).*

---

## 8. Native System Integration

*   **Native Notifications:** Rust core emits events; native host intercepts and triggers OS-level notifications (macOS Notification Center, Windows Action Center).
*   **Background Timers:** Mobile OSs aggressively kill background tasks. The timer calculates a definitive `end_time`. On entering the background, an OS local notification is scheduled for `end_time`. Upon foregrounding, the UI calculates `end_time - current_time` to snap the UI to the correct value without keeping a live background thread spinning.
*   **Desktop Tray/Menu Bar:** Implement `NSStatusItem` (macOS) and System Tray API (Windows) linked to the global Rust state manager.
*   **Global Hotkeys:** Register OS-level shortcuts (e.g., `Cmd+Shift+Space`) to immediately summon a "Quick Add" floating window.

---

## 9. Development Milestones

### Phase 1: Core Engine & Architecting (Weeks 1-3)
*See the detailed [Phase 1 Implementation Document](PHASE_1.md) for full specs, prerequisites, and revalidation logic.*
*   Setup Rust Core, UniFFI, and CI/CD for multi-target compilation.
*   Implement SQLite data layer and basic CRUD for Tasks.
*   Implement the core Timer state machine in Rust.
*   Build skeleton SwiftUI & WinUI interfaces proving the FFI bridge.

### Phase 2: Productivity Features & Production Integration (Weeks 4-6)
*   **Production Integration (Apple):** Migrate from the initial "Run Script" build phase to a production-grade **XCFramework + Swift Package Manager (SPM)** architecture. This bypasses Xcode's script sandbox and improves build reliability.
*   **Feature Build-out:** Implement Subtasks, Notes schema, and UI binding.
*   **Scheduling:** Implement Recurring Tasks logic (scheduling engine).
*   **Notifications:** Hook up Native Rich Notifications for Reminders and Timer completion, including OS 'Quick Reply' input.
*   **Accessibility:** Implement Menu Bar (macOS) / System Tray (Windows) Dropdown with global shortcut summoning.

### Phase 3: Insights & Polish (Weeks 7-8)
*   Aggregate Pomodoro data into Daily Reports.
*   Implement the Analytics UI.
*   Build Interactive OS Widgets (macOS Sonoma, iOS 17+, Windows 11) for glanceable tracking. 
*   Apply final Monochromatic Design System polishing, micro-interactions, and animations.

### Phase 4: Sync (Weeks 9-11)
*   Establish backend (sync endpoint).
*   Implement CRDT / Timestamp reconciliation in the Rust Core.
*   Handle conflict resolution and background sync worker on native platforms.

### Phase 5: Release & Packaging (Week 12)
*   Performance profiling (Memory leak checks on FFI boundaries).
*   Code signing and packaging for respective stores.

---

## 10. Testing Strategy

1.  **Core Unit Tests (Rust):** 100% coverage on Timer logic, Recurrence parsing, and State Management.
2.  **Database Integration Tests:** In-memory SQLite tests simulating complex CRUD and Cascading deletes.
3.  **Cross-Platform Tests:** UI automation using XCUITest (Apple), Espresso (Android), and WinAppDriver (Windows) focused purely on critical paths (Create Task, Start Timer).
4.  **Performance Tests:** Ensure sub-10ms UI renders when parsing lists of 10,000+ tasks in local SQLite.

---

## 11. Packaging & Distribution

*   **macOS:** Packaged as an `.app` bundle, Sandbox enabled, distributed via the Mac App Store and as a DMG (Notarized).
*   **Windows:** Distributed as an `MSIX` package via the Microsoft Store, or a standalone `NSIS`/`InnoSetup` executable.
*   **iOS:** `.ipa` package, strictly distributed via the iOS App Store.
*   **Android:** `.aab` for the Google Play Store, `.apk` for GitHub releases.
*   **Update Strategy:** Mobile via App Stores. Desktop (direct downloads) utilize a lightweight background updater (e.g., Sparkle for macOS, WinSparkle for Windows) pinging a GitHub Releases endpoint.

## 12. Codebase & Configuration Standards

To ensure a continuous and consistent cross-platform development environment inside the shared monorepo, strict code-formatting and file tracking rules apply:

*   **Repository Structure:** Single monolithic repository containing both the `focus-core` (Rust workspace) and all native frontend directories (`macos-app/`, etc.).
*   **`.gitignore`:** Global ignore rules are established at the root level handling Cargo targets (`/target/`), Xcode derived data (`DerivedData/`), and OS-specific auto-generated files (like `.DS_Store`).
*   **`.editorconfig`:** Enforces whitespace, charset, and indentation consistency across IDEs (VSCode, Xcode, IntelliJ/RustRover). E.g., Markdown trailing spaces are allowed, JSON/TOML default to 2 spaces.
*   **`rustfmt.toml`:** Custom Rust configuration enforcing a max column width of 100 char, and wrapping comments correctly.

All Rust commits must pass local CI checks:
```bash
cargo fmt --all -- --check
cargo clippy --all -- -D warnings
```

---
*Generated by Antigravity*
