# Phase 2: Productivity Features & Production Integration

## 1. Overview
This document outlines the detailed implementation, design, and revalidation strategy for Phase 2 of the Focus native application. It transitions the application from a raw FFI-hooked prototype into a stable, feature-rich productivity tool seamlessly integrated with the host OS.

## 2. Prerequisites & Ambiguities to Clarify

Before commencing Phase 2 execution, the following prerequisites must be confirmed:
1.  **Phase 1 Completion:** Are the core SQLite CRUD for Tasks, basic Rust Timer Engine, and UniFFI bindings stable and fully tested?
2.  **Subtask Depth Strategy:** The architecture mentions "endless or 1-level deep nesting." We need to finalize this constraint as "endless" requires recursive CTE SQL queries, whereas "1-level" simplifies data modeling significantly.
3.  **XCFramework vs. SPM Plugin:** Will the Rust binary be generated externally and linked as a static `binaryTarget` locally in SPM, or are we aiming for an automated Xcode Build plugin? (Recommendation: Pre-compiled local binary via a shell script for maximum Xcode stability).
4.  **Menu Bar Scope:** Should the macOS Menu Bar / Windows System Tray app contain a full mini-dashboard (Task list + Timer) or strictly a localized control for the active Pomodoro session?
5.  **Notifications Trigger:** Do we want user-actionable notifications (e.g., a "Snooze 5m" or "Complete Task" button directly inside the macOS/Windows notification banner)?

## 3. Implementation Plan

### 3.1 Production Integration (Build System)
*   **Goal:** Move away from raw Xcode "Run Script" phases relying on `$PATH` rustc to a resilient Swift Package Manager (SPM) architecture.
*   **Actionable Steps:**
    1.  Create a `build_apple.sh` script to compile `focus-core` for `aarch64-apple-darwin`, `x86_64-apple-darwin`, and `aarch64-apple-ios`.
    2.  Use `xcodebuild -create-xcframework` to bundle the static `.a` or dynamic `.dylib` libraries alongside the UniFFI generated `focus_core.swift` and bridging headers.
    3.  Wrap the XCFramework in a local SPM `Package.swift` so the main Xcode project merely imports `FocusCore` cleanly.

### 3.2 Feature Build-out: Subtasks & Notes
*   **Goal:** Implement complex UI binding for hierarchical task data and markdown notes.
*   **Actionable Steps:**
    1.  **Rust Core:** Implement `get_task_tree()` returning nested data structures.
    2.  **SwiftUI/WinUI:** Implement recursive views (e.g., `OutlineGroup` in SwiftUI) to render subtasks.
    3.  **Notes Schema:** Integrate a native Markdown renderer (e.g., simple `AttributedString` parsing) directly bound to the `Note` entity updates.

### 3.3 Scheduling: Recurring Tasks
*   **Goal:** Local rule-based recurrence engine.
*   **Actionable Steps:**
    1.  **Rust Core:** Adopt a lightweight RFC 5545 parser (`rrule` crate) to calculate `next_instance`.
    2.  **State Logic:** Upon task completion, if an `rrule` exists, automatically generate the cloned Task entry for the next interval and persist to SQLite.

### 3.4 Notifications & Accessibility
*   **Goal:** Deep OS integration for timers and global hotkeys.
*   **Actionable Steps:**
    1.  **Native Notifications:** Implement `UNUserNotificationCenter` delegates in Swift responding to Rust `SessionComplete` events. If app is backgrounded, schedule local notifications.
    2.  **Menu Bar App:** Implement `NSStatusItem` in macOS Application Delegate. Bind its view to a small, memory-efficient SwiftUI `MenuBarTimerView`.
    3.  **Global Hotkeys:** Use a lightweight native hook (e.g., `NSEvent.addGlobalMonitorForEvents` or `HotKey` SPM package) to bind `Cmd+Shift+Space` -> Summons "Quick Add" window floating above all spaces.

## 4. UI/UX Design Refinements
*   **Menu Bar UX:** The menu bar icon should dynamically change (e.g., a pie chart filling up) representing the background timer progress, even without clicking the dropdown.
*   **Notification UX:** Ensure notifications have distinct, non-jarring sounds. Provide clear "Take 5m Break" and "Skip Break" action buttons directly in the notification payload.
*   **Interaction:** Ensure adding a subtask opens an embedded text field seamlessly below the parent without pushing a new navigation view context (maintaining the minimalist philosophy).

## 5. Revalidation & Testing
*   **Testing Strategy:**
    1.  **Memory Leak Audit:** FFI bridges passing large strings (like Markdown notes) or recursive trees (Subtasks) are prone to leaks. Run Xcode Instruments (Allocations/Leaks) rigorously over list scrolling and detail view pop/push events.
    2.  **UI Performance:** Profile the SwiftUI `List` when displaying 100+ tasks with embedded subtasks. Ensure the Rust Core state diffing triggers surgical UI redraws, not full view reloads.
    3.  **OS Integration Tests:** Background the app, let a 1-minute test timer run out. Verify the OS notification delivers precisely on time. Check deep-link metric: clicking notification correctly launches the app and focuses the target task.
