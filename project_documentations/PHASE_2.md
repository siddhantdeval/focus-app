# Phase 2: Productivity Features & Production Integration

## 1. Overview
This document outlines the detailed implementation, design, and revalidation strategy for Phase 2 of the Focus native application. It transitions the application from a raw FFI-hooked prototype into a stable, feature-rich productivity tool seamlessly integrated with the host OS.

## 2. Prerequisites & Resolved Ambiguities

Before commencing Phase 2 execution, the following prerequisites and architectural decisions are confirmed:
1.  **Phase 1 Completion:** Are the core SQLite CRUD for Tasks, basic Rust Timer Engine, and UniFFI bindings stable and fully tested?
2.  **Subtask Depth Strategy:** Decided: **1-level deep nesting** only. This prevents cognitive overload and simplifies the SQLite/Rust data representation.
3.  **XCFramework vs. SPM Plugin:** Decided: Generate XCFramework locally and link via SPM. Avoid complex Xcode build scripts inside the IDE.
4.  **Menu Bar Scope:** Decided: Strictly **Pomodoro Session Context** (Active Timer, Current Task, Control buttons). No task lists.
5.  **Notifications Trigger:** Decided: User-actionable notifications indicating timer completion with options to "Start Break" or "Skip Break".

## 3. Implementation Plan

### 3.1 Production Integration (Build System)
*   **Goal:** Move away from raw Xcode "Run Script" phases relying on `$PATH` rustc to a resilient Swift Package Manager (SPM) architecture.
*   **Actionable Steps:**
    1.  Create a `build_apple.sh` script to compile `focus-core` for `aarch64-apple-darwin`, `x86_64-apple-darwin`, and `aarch64-apple-ios`.
    2.  Use `xcodebuild -create-xcframework` to bundle the static `.a` or dynamic `.dylib` libraries alongside the UniFFI generated `focus_core.swift` and bridging headers.
    3.  Wrap the XCFramework in a local SPM `Package.swift` so the main Xcode project merely imports `FocusCore` cleanly.

### 3.2 Feature Build-out: Subtasks & Notes (Screen S3)
*   **Goal:** Implement UI binding for strictly 1-level hierarchical task data and debounced markdown notes inside the **S3: Task Detail Panel**.
*   **Actionable Steps:**
    1.  **Rust Core:** Implement `get_task_with_subtasks()` returning a 1-level nested data structure.
    2.  **SwiftUI/WinUI:** Implement standard List views to render subtasks (recursive views are untracked since depth is locked at 1).
    3.  **Notes Schema:** Integrate a native Markdown renderer. To prevent UI lag and FFI blockages, native clients hold the Markdown string in memory and push to Rust only via debouncer (e.g., 1.5s invariant) or `onBlur`.

### 3.3 Scheduling: Recurring Tasks
*   **Goal:** Local rule-based recurrence engine with eager generation.
*   **Actionable Steps:**
    1.  **Rust Core:** Adopt a lightweight RFC 5545 parser (`rrule` crate) to calculate `next_instance`.
    2.  **State Logic:** Proactively calculate and generate future cloned Task entries up to a 30-day horizon to ensure they appear in upcoming scheduled lists, bypassing the limitation of strict "on-completion" generation.

### 3.4 Notifications & Accessibility (Screens S8 & S10)
*   **Goal:** Deep OS integration for timers and global hotkeys, implementing **S8: Menu Bar** and **S10: Rich Notifications**.
*   **Actionable Steps:**
    1.  **Rich Notifications (S10):** Implement `UNUserNotificationCenter` delegates in Swift responding to Rust `SessionComplete` events, providing native quick-actions.
    2.  **Menu Bar App (S8):** Implement `NSStatusItem` in macOS Application Delegate. Limit its UI exclusively to timer controls and current task status.
    3.  **Global Hotkeys:** Use a lightweight native hook (e.g., `NSEvent.addGlobalMonitorForEvents` or `HotKey` SPM package) to bind `Cmd+Shift+Space` -> Summons "Quick Add" window floating above all spaces.

## 4. UI/UX Design Refinements
*   **Menu Bar UX:** The menu bar icon dynamically updates representing the background timer progress. The dropdown remains exclusively focused on Pomodoro functionality.
*   **Notification UX:** Ensure notifications have distinct, non-jarring sounds. Provide clear "Take 5m Break" and "Skip Break" action buttons directly in the notification payload.
*   **Interaction:** Ensure adding a subtask opens an embedded text field seamlessly below the parent without pushing a new navigation view context (maintaining the minimalist philosophy).

## 5. Revalidation & Testing
*   **Testing Strategy:**
    1.  **Memory Leak Audit:** FFI bridges passing large strings (like Markdown notes) or recursive trees (Subtasks) are prone to leaks. Run Xcode Instruments (Allocations/Leaks) rigorously over list scrolling and detail view pop/push events.
    2.  **UI Performance:** Profile the SwiftUI `List` when displaying 100+ tasks with embedded subtasks. Ensure the Rust Core state diffing triggers surgical UI redraws, not full view reloads.
    3.  **OS Integration Tests:** Background the app, let a 1-minute test timer run out. Verify the OS notification delivers precisely on time. Check deep-link metric: clicking notification correctly launches the app and focuses the target task.
