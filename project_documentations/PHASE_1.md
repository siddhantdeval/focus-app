# Phase 1: Core Engine & Architecting
**Design Assets:** Local mockups can be found in [design_asset/](design_asset/)

## 1. Overview
This document outlines the implementation, design, and validation strategy for Phase 1 of the Minimalist Cross-Platform Productivity Application. The primary goal of this phase is to establish the foundation of the Shared Core Architecture using Rust, expose it via UniFFI, and build the initial native UI skeletons for macOS/iOS (SwiftUI) and Windows (WinUI 3) to prove the bridge.

## 2. Prerequisites & Ambiguities to Clarify
Before fully committing to the execution of Phase 1 code, the following points require clarity:

1.  **Repository Structure**: Are we using a single monorepo (e.g., Cargo workspace with UI folders alongside) or separate repositories for each native client?
    *   *Recommendation: A single monorepo is highly recommended to ensure FFI bindings stay in sync with UI code.*
2.  **Database Tooling**: Will we use `rusqlite` with raw SQL strings, or a query builder/ORM like `SeaORM` or `SQLx`?
    *   *Recommendation: `rusqlite` with raw SQL (and potentially a migration runner like `refinery` or `barrel`) to keep the binary small and performant.*
3.  **UniFFI Toolchain**: Confirm the availability of local toolchains (Rust, Swift, and Windows SDK) for the developer environment to cross-compile and generate bindings successfully.
4.  **Skeleton UI Scope**: How much of the Design System should be implemented in Phase 1?
    *   *Recommendation: Keep it purely functional (a raw list and a raw text clock) to isolate and prove FFI reactivity before introducing complex styling.*
5.  **State Management Binding**: How do we want to bridge the Rust reactive stream with Native state?
    *   *Recommendation: Use Rust async channels mapped to Swift `AsyncStream` and C# `IObservable` to prevent memory leaks across the FFI boundary.*

---

## 3. Implementation Plan

### 3.1 Setup Rust Core & UniFFI
*   **Action**: Initialize the Rust library crate (`focus_core`).
*   **Action**: Configure `uniffi` in `Cargo.toml` and define the initial UDL (UniFFI Definition Language) or procedural macros for our core services.
*   **Action**: Set up GitHub Actions CI/CD to verify compilation across `aarch64-apple-darwin`, `x86_64-apple-darwin`, and `x86_64-pc-windows-msvc`.

### 3.2 Data Layer (SQLite & Tasks CRUD)
*   **Action**: Integrate `rusqlite` into `focus_core`.
*   **Action**: Implement the database bootstrap (creating the `tasks` table based on the schema).
*   **Action**: Implement core CRUD operations in Rust:
    *   `create_task(title: String) -> Task`
    *   `get_tasks() -> Vec<Task>`
    *   `update_task_status(id: String, completed: bool)`
    *   `delete_task(id: String)`

### 3.3 Core Timer State Machine
*   **Action**: Implement a high-precision tick generator running on a background thread in Rust.
*   **Action**: Create a simple state machine for the Pomodoro Timer: `Idle` <-> `Running` <-> `Paused`.
*   **Action**: Expose a subscribe mechanism across UniFFI so native clients receive `TimerTick(duration_left)` and `TimerStateChanged` events.

### 3.4 Skeleton SwiftUI & WinUI Interfaces
*   **Target (Apple - SwiftUI)**: Create a basic SwiftUI app. Import the generated Swift package from UniFFI. Build a simple screen calling `create_task()` and displaying the result in a list. Hook up a "Start Timer" button to the Rust state machine and display the countdown.
*   **Target (Windows - WinUI 3)**: Create a basic C# WinUI 3 app. Import the generated C# bindings. Replicate the Apple UI purely to prove the FFI bridge functions identically.

---

## 4. Design & UI Requirements (Skeleton Phase)

At this stage, we do **not** apply the full minimalist design system outlined in `DESIGN_PLAN.md`. Doing so now risks conflating UI bugs with deeper FFI synchronicity bugs. The design focus is strictly functional.

*   **Task List**: A native stock list component (e.g., `List` in SwiftUI, `ListView` in WinUI). Elements should display a title and a native checkbox.
*   **Task Input**: A native single-line text field and a stock "Add" button placed inline.
*   **Timer Display**: A large standard text label showing `MM:SS`.
*   **Timer Controls**: Native standard buttons for "Start", "Pause", and "Stop".

*Validation Checkpoint*: Does the task list update instantly when a new task is added via Rust core? Does the timer tick synchronously with the Rust backend without locking the main UI thread?

---

## 5. Revalidation & Testing Strategy

### 5.1 Rust Unit Tests (Core Logic)
*   **Tasks Core**: Verify UUID generation, correct timestamp assignment, and database persistence functions using an in-memory SQLite database (`rusqlite::Connection::open_in_memory()`).
*   **Timer State Machine**: Verify state transitions (e.g., cannot pause an idle timer) and tick accuracy (using mock time to simulate rapid session progression).

### 5.2 FFI Boundary Validation
*   Write basic integration tests on the Swift and C# side ensuring that calling a Rust rust function doesn't result in a panic or segment fault.
*   **Memory Lifecycle Profiling**: Specifically test memory leaks by creating 1,000 tasks via FFI rapidly and verifying using profiling tools (e.g., Instruments on macOS) that memory is completely freed and deallocated.

### 5.3 Cross-Compilation Check
*   Ensure that the Rust codebase successfully builds static libraries (for mobile) and dynamic libraries (for desktop) for all intended target triples locally before CI submission.
