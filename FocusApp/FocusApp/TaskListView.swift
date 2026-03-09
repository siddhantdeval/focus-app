import SwiftUI
import FocusCore

struct TaskListView: View {
    @ObservedObject var viewModel: FocusViewModel
    @State private var showAddTask = false

    // Three logical groups from the HTML mockup
    private var todayTasks:     [FocusTask] { viewModel.tasks.filter { !$0.isCompleted } }
    private var completedTasks: [FocusTask] { viewModel.tasks.filter {  $0.isCompleted } }

    var body: some View {
        HStack(spacing: 0) {

            // ── Master List ───────────────────────────────────────────────────
            VStack(spacing: 0) {

                // Header: h-16 border-b flex items-center justify-between px-8
                HStack {
                    Text("Today's Focus")
                        .font(.system(size: 18, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(Color.primaryBackground)

                    Spacer()

                    // Search icon button  p-2 hover:bg-slate-50 rounded-full
                    IconCircleButton(icon: "magnifyingglass") {}

                    // New Task button  bg-primary text-white px-4 py-2 rounded-lg text-sm font-semibold
                    Button(action: {
                        viewModel.newTaskTitle = "New task"
                        viewModel.addTask()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("New Task")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, TWSpacing.p(4))
                        .padding(.vertical, TWSpacing.p(2))
                        .background(Color.primaryBackground)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, TWSpacing.p(8))
                .frame(height: 64)
                .background(Color.white)

                Divider().background(Color.slate100)

                // Scrollable task list
                ScrollView {
                    VStack(alignment: .leading, spacing: TWSpacing.p(10)) {

                        // TODAY section
                        if !todayTasks.isEmpty {
                            TaskSection(
                                label: "TODAY",
                                badge: "\(todayTasks.count) Task\(todayTasks.count == 1 ? "" : "s")"
                            ) {
                                ForEach(todayTasks, id: \.id) { task in
                                    PreciseTaskRow(
                                        task: task,
                                        isSelected: viewModel.selectedTaskID == task.id,
                                        onToggle: { viewModel.toggleTaskCompletion(task: task) },
                                        onTap:   { viewModel.selectedTaskID = task.id }
                                    )
                                }
                            }
                        }

                        // UPCOMING section (placeholder — tasks without a due-date concept)
                        if false { // kept for future due-date filtering
                            TaskSection(label: "UPCOMING", badge: nil) {
                                EmptyView()
                            }
                        }

                        // COMPLETED section
                        if !completedTasks.isEmpty {
                            TaskSection(label: "COMPLETED", badge: nil) {
                                ForEach(completedTasks, id: \.id) { task in
                                    PreciseTaskRow(
                                        task: task,
                                        isSelected: viewModel.selectedTaskID == task.id,
                                        onToggle: { viewModel.toggleTaskCompletion(task: task) },
                                        onTap:   { viewModel.selectedTaskID = task.id }
                                    )
                                    .opacity(0.5) // completed tasks dimmed per HTML: opacity-50
                                }
                            }
                        }

                        // Inline add-task row at the bottom
                        InlineAddTaskRow(viewModel: viewModel)
                            .padding(.top, TWSpacing.p(2))

                    }
                    .padding(.horizontal, TWSpacing.p(8))
                    .padding(.vertical, TWSpacing.p(6))
                }
                .background(Color.white)
            }
            .frame(minWidth: 320, idealWidth: 500, maxWidth: .infinity)

            Divider().background(Color.slate200)

            // ── Detail Panel: w-[420px] ───────────────────────────────────────
            if let selectedId = viewModel.selectedTaskID,
               let task = viewModel.tasks.first(where: { $0.id == selectedId }) {
                TaskDetailView(viewModel: viewModel, task: task)
                    .frame(width: 420)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                EmptyDetailState()
                    .frame(width: 420)
            }
        }
        .background(Color.white)
    }
}

// MARK: - TaskSection (TODAY / UPCOMING / COMPLETED header)
private struct TaskSection<Content: View>: View {
    let label: String
    let badge: String?
    let content: Content

    init(label: String, badge: String?, @ViewBuilder content: () -> Content) {
        self.label   = label
        self.badge   = badge
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TWSpacing.p(2)) {
            // Section header: text-xs font-bold text-slate-400 uppercase tracking-widest
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(Color.slate400)
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.slate100)
                        .foregroundColor(Color.primaryBackground)
                        .cornerRadius(99)
                }
            }
            .padding(.bottom, TWSpacing.p(2))

            content
        }
    }
}

// MARK: - PreciseTaskRow (pixel-perfect row from HTML)
struct PreciseTaskRow: View {
    let task:       FocusTask
    let isSelected: Bool
    let onToggle:   () -> Void
    let onTap:      () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: TWSpacing.p(4)) {

            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? Color.slate300 : Color.primaryBackground)
            }
            .buttonStyle(.plain)

            // Title + metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(task.isCompleted ? Color.slate500 : Color.primaryBackground)
                    .strikethrough(task.isCompleted, color: Color.slate400)
                    .lineLimit(1)

                // Metadata: Due Today / subtask count
                HStack(spacing: TWSpacing.p(3)) {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text("Due Today")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color.slate400)

                    HStack(spacing: 3) {
                        Image(systemName: "checklist")
                            .font(.system(size: 11))
                        Text("2/5")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color.slate400)
                }
            }

            Spacer()

            // Bell: always visible on selected, group-hover on others
            Image(systemName: "bell")
                .font(.system(size: 16))
                .foregroundColor(isSelected ? Color.primaryBackground : Color.slate300)
                .opacity((isHovered || isSelected) ? 1 : 0)
        }
        // py-3 px-4 -mx-4 rounded-xl
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        // Active selected styling: bg-slate-50 border border-slate-200
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.slate50 : (isHovered ? Color.slate50.opacity(0.6) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.slate200 : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { onTap() } }
        .onHover { h in withAnimation(.easeInOut(duration: 0.13)) { isHovered = h } }
    }
}

// MARK: - InlineAddTaskRow
private struct InlineAddTaskRow: View {
    @ObservedObject var viewModel: FocusViewModel
    @State private var isFocused = false

    var body: some View {
        HStack(spacing: TWSpacing.p(4)) {
            Image(systemName: "plus")
                .foregroundColor(Color.slate400)
                .font(.system(size: 15))

            TextField("Add a task...", text: $viewModel.newTaskTitle)
                .font(.system(size: 14))
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Color.slate500)
                .onSubmit { viewModel.addTask() }

            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(Color.slate400)
                    .font(.system(size: 13))
                Image(systemName: "flag")
                    .foregroundColor(Color.slate400)
                    .font(.system(size: 13))
            }
        }
        .padding(.horizontal, TWSpacing.p(6))
        .padding(.vertical, TWSpacing.p(4))
        .background(Color.slate50)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate100, lineWidth: 1))
    }
}

// MARK: - EmptyDetailState
private struct EmptyDetailState: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(Color.slate200)
                .padding(.bottom, TWSpacing.p(4))
            Text("Select a task to view details")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.slate400)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundLight)
        .overlay(Divider().background(Color.slate200), alignment: .leading)
    }
}

// MARK: - IconCircleButton
private struct IconCircleButton: View {
    let icon: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.slate400)
                .padding(8)
                .background(isHovered ? Color.slate50 : Color.clear)
                .cornerRadius(99)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
