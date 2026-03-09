Act as a senior Product Designer, UX Architect, and Human-Computer Interaction specialist.

Design high-quality wireframes for a minimalist productivity application focused on task management and the Pomodoro technique.

The application must follow strict usability principles:

• Modern native interface
• Minimalist monochromatic design
• Distraction-free workspace
• Simple task interaction
• Keyboard-friendly navigation
• Clear visual hierarchy
• Low cognitive load

The interface should feel similar in clarity and simplicity to modern productivity apps such as Things, Linear, and Notion.

Target Platforms:
• Windows
• macOS
• Android
• iOS

Ensure the layout adapts naturally between desktop and mobile while maintaining the same design system.

UI DESIGN SYSTEM

Color System (Monochromatic with Subtle Accent)

Background
Primary background: white or near-black depending on theme

Text hierarchy
Primary text: high contrast
Secondary text: medium contrast
Muted text: low contrast

UI elements
Dividers: subtle grey
Interactive states: darker shade of primary color
Accent state: Single muted color (e.g. subtle green or native OS blue) for active states only.

Avoid bright colors, gradients, heavy shadows, or decorative elements.

Typography Hierarchy

Primary display (Pomodoro timer)
Large numeric typography

Section headers
Medium weight

Task text
Regular weight

Metadata
Small subdued text

Spacing System

Use an 8px spacing grid.

Spacing scale examples:
8px
16px
24px
32px

Use whitespace generously to maintain visual clarity.

ICONOGRAPHY

Use simple line icons.

Icons should support actions rather than dominate the UI.

NAVIGATION MODEL

Desktop navigation

Left sidebar
• Dashboard
• Tasks
• Reports
• Settings

Mobile navigation

Bottom tab bar (replaces left sidebar)
Floating Action Button (FAB) for Command bar/Quick actions

Main workspace area

Top command bar
Quick search
New task

Keyboard shortcuts must be supported.

Examples:

N → New task
Space → Toggle task completion
F → Start focus session
Ctrl/Cmd + K → Command palette
Arrow keys → Navigate task list

SCREEN STRUCTURE

Design the following screens with detailed component hierarchy.

SCREEN 1 — PRODUCTIVITY DASHBOARD
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `834685fa805e48cd86d4cf847750c685` | [Mockup](design_asset/productivity_dashboard_mockup.png) | [Code](design_asset/productivity_dashboard_code.html) | [**Full Specification**](screen_specifications/S1_PRODUCTIVITY_DASHBOARD.md)
<!-- slide -->

Purpose
Central workspace for daily productivity.

Layout structure

Top bar
• Current date
• Global search
• Sync status
• Settings access

Focus section (primary visual element)

Large Pomodoro timer
Session label (Focus / Break)
Primary action button (Start / Pause)
Session progress indicator
(Note: On scroll, timer must collapse into a sticky compact header)

Current task panel

Active task title
Subtask progress indicator
Quick edit action

Daily task list

Task rows containing:

Checkbox
Task title
Due date indicator
Subtask progress
Priority marker

Inline add task input.

Quick actions

Start focus session
Add task
Add note

The timer and current task must visually dominate the screen.

SCREEN 2 — TASK MANAGEMENT VIEW
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `4561bf01b3e94bdf9ab4e1d1cac92281` | [Mockup](design_asset/task_management_view_mockup.png) | [Code](design_asset/task_management_view_code.html) | [**Full Specification**](screen_specifications/S2_TASK_MANAGEMENT.md)
<!-- slide -->

Purpose
Manage and organize tasks.

Layout structure

Task list panel

Sortable task list
Grouping options (Today / Upcoming / Completed)

Task row structure

Completion checkbox
Task title
Due date indicator
Subtask count
Reminder indicator

Task details appear in a side panel when selected (Desktop/Wide screens).
On narrow/Mobile screens, animate as a bottom-sheet or full push-transition.

SCREEN 3 — TASK DETAIL PANEL
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `9b35d536a7604974bc9f4d548cd4a162` | [Mockup](design_asset/task_detail_panel_view_mockup.png) | [Code](design_asset/task_detail_panel_view_code.html) | [**Full Specification**](screen_specifications/S3_TASK_DETAIL.md)
<!-- slide -->
Purpose
Edit and manage task details.

Sections

Task header

Task title
Completion toggle
Due date selector

Subtasks

Checklist interface
Add subtask field

Notes

Expandable text area

Scheduling

Reminder time
Repeat rule

Session tracking

Completed Pomodoro sessions
Estimated sessions

SCREEN 4 — FOCUS MODE (DISTRACTION-FREE)
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `95683e0c61694cc0987c83f90968972b` | [Mockup](design_asset/distraction_free_focus_mode_mockup.png) | [Code](design_asset/distraction_free_focus_mode_code.html) | [**Full Specification**](screen_specifications/S4_FOCUS_MODE.md)
<!-- slide -->
Purpose
Deep work environment.

Layout must be extremely minimal.

Center screen

Large Pomodoro timer

Below timer

Current task title
Subtask progress

Controls

Pause
Skip break
Reset session

All other UI elements hidden.

Picture-in-Picture (PiP) / Mini Mode
Must include an "Always on Top" mini floating widget displaying just the active time (e.g., `[ 24:15 ]`) for when the user is utilizing other apps.

SCREEN 5 — REPORTS
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `137123b61b7042fdbd4addb1f332d1df` | [Mockup](design_asset/productivity_reports_view_mockup.png) | [Code](design_asset/productivity_reports_view_code.html) | [**Full Specification**](screen_specifications/S5_REPORTS.md)
<!-- slide -->
Purpose
Show productivity insights.

Sections

Daily summary

Focus time
Tasks completed
Sessions completed

Weekly activity chart

Pomodoro sessions per day

Task productivity

Top focused tasks

Insights panel

Short productivity summaries

SCREEN 6 — SETTINGS
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `624156aa196a4791b239c1dd2529ec6e` | [Mockup](design_asset/application_settings_view_mockup.png) | [Code](design_asset/application_settings_view_code.html) | [**Full Specification**](screen_specifications/S6_SETTINGS.md)
<!-- slide -->
Sections

General

Default Pomodoro duration
Break duration

Notifications

Reminder alerts
Session alerts

Synchronization

Sync account
Sync status

Data

Export data
Backup data

SCREEN 7 — COMMAND PALETTE (Cmd+K)
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `32c0c09f808241dba081d3ab71eae2da` | [Mockup](design_asset/command_palette_modal_view_mockup.png) | [Code](design_asset/command_palette_modal_view_code.html) | [**Full Specification**](screen_specifications/S7_COMMAND_PALETTE.md)
<!-- slide -->
Purpose
Rapid, keyboard-only access to all app features.

Layout structure

Centered floating modal
Blurred background overlay

Content

Large input field at the top
Contextual Suggestions below (e.g., "Start Timer", "Create Task", "Settings")
Recent Searches or Views
Keyboard hints (`↵ to select`, `Esc to close`) aligned to right

SCREEN 8 — MENU BAR DROPDOWN (macOS & Windows System Tray)
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `dee40ed0aaf14439aed7a827339368c7` | [Mockup](design_asset/menu_bar_status_app_dropdown_mockup.png) | [Code](design_asset/menu_bar_status_app_dropdown_code.html) | [**Full Specification**](screen_specifications/S8_MENU_BAR.md)
<!-- slide -->
Purpose
Ambient command center for the app while working in other windows. Must be summonable natively via a customizable global OS shortcut (e.g., `Option+Cmd+Space`).

Layout structure
Narrow, vertically stacked popover dropping from the menu bar / system tray.
Native macOS vibrancy (translucent background) or Windows Acrylic material.

Content
Top banner: Compact Pomodoro timer (e.g., `24:15 | Focus`). Ensure the text color shifts to the subtle active accent color while running.
Active state: Current task name, play/pause/stop simple line icons.
Quick input: Single-line input field to add new tasks instantly without stealing mouse focus.
Upcoming focus list: Minimalist checklist of top 3 upcoming tasks.

SCREEN 9 — OS WIDGETS (Desktop & Mobile)
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `36100c0e6c3f4d7cbf579343b28f871a` | [Mockup](design_asset/productivity_desktop_widgets_mockup.png) | [Code](design_asset/productivity_desktop_widgets_code.html) | [**Full Specification**](screen_specifications/S9_OS_WIDGETS.md)
<!-- slide -->

Purpose
Glanceable awareness of time and daily progress without opening the app at all.
Must utilize strictly interactive widget APIs (macOS Sonoma, iOS 17+, Windows 11) allowing users to pause the timer or check off tasks *directly* from the widget without launching the main app.

Small Widget
Minimalist circular progress ring.
Large, bold timer countdown in center.
Active task title below.

Medium Widget
Split view. Left: Timer ring and active task. Right: Clean checklist of top 3 tasks.

SCREEN 10 — RICH NOTIFICATIONS
**Stitch Reference:** Project ID `14675736852343732341` | Screen ID `e18fb17488754f0eb20e87678d837cec` | [Mockup](design_asset/macos_rich_notification_popup_mockup.png) | [Code](design_asset/macos_rich_notification_popup_code.html) | [**Full Specification**](screen_specifications/S10_NOTIFICATIONS.md)
<!-- slide -->

Purpose
Actionable OS-level alerts that guide sessions and minimize context switching.

Layout
Native OS notification style.
Actions: 'Start Break', 'Add +5 Mins', 'Skip', and 'Mark Complete'.
Input: Emulate the native 'Quick Reply' text-field to let users log a sudden distraction (saved later inside Notes) or quickly define their next task for the break.

INTERACTION PRINCIPLES

Every common action must be achievable in 1–2 interactions.

Avoid multi-step workflows.

Prefer inline editing.

Example task creation interaction

User presses "N"
Inline task field appears
User types task name
Press Enter → task created

Gestures & Haptics

Native swipe gestures must be utilized (e.g., swipe task row left/right to Complete, Reschedule, or Delete).
Subtle haptic feedback upon completing a task or finishing a Pomodoro session.

VISUAL HIERARCHY PRIORITY

The UI should guide the eye in this order:

1 Pomodoro timer
2 Current task
3 Task list
4 Secondary actions

No screen should contain more than 3 primary visual zones.

ACCESSIBILITY

Ensure the design supports:

Keyboard navigation
High contrast text
Large click targets
Clear focus indicators

OUTPUT FORMAT

Generate wireframes showing:

Screen layout
Component hierarchy
UI sections
Interaction areas
Navigation flow

Ensure designs are clean, minimalist, and optimized for productivity.