import SwiftUI
import FocusCore
import Combine

// MARK: - Subtask model (lightweight local struct)
struct SubtaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

// MARK: - TaskDetailView
struct TaskDetailView: View {
    @ObservedObject var viewModel: FocusViewModel
    var task: FocusTask

    // Local subtask state (stored in SQLite via notes for now; could extend schema)
    @State private var subtasks: [SubtaskItem] = [
        SubtaskItem(title: "Audit existing components",  isCompleted: true),
        SubtaskItem(title: "Define color primitives",    isCompleted: true),
        SubtaskItem(title: "Build typography scale",     isCompleted: false),
        SubtaskItem(title: "Create icon library",        isCompleted: false),
        SubtaskItem(title: "Documentation handoff",      isCompleted: false),
    ]

    @State private var notesText: String = ""
    @State private var isDeleteHovered = false

    // Debounced note saving
    private let notesPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()

    // Derived
    private var completedCount: Int { subtasks.filter(\.isCompleted).count }
    private var completionPct: Int {
        subtasks.isEmpty ? 0 : Int(Double(completedCount) / Double(subtasks.count) * 100)
    }
    private var timerDisplay: String {
        let remaining = viewModel.timerRemaining > 0 ? viewModel.timerRemaining : 1500
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Scrollable body ──────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header badge + actions
                    HStack {
                        // PRODUCTIVITY badge: text-[10px] font-bold px-2.5 py-1 bg-primary/10
                        Text("PRODUCTIVITY")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.2)
                            .textCase(.uppercase)
                            .foregroundColor(Color.primaryBackground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.primaryBackground.opacity(0.1))
                            .cornerRadius(4)

                        Spacer()

                        // Action buttons: p-1.5 hover:bg-slate-100 rounded
                        HStack(spacing: TWSpacing.p(1)) {
                            ActionIconButton(icon: "square.and.arrow.up")
                            ActionIconButton(icon: "ellipsis")
                        }
                    }
                    .padding(.horizontal, TWSpacing.p(8))
                    .padding(.top, TWSpacing.p(8))
                    .padding(.bottom, TWSpacing.p(6))

                    // Task title: text-2xl font-black
                    Text(task.title)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color.primaryBackground)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                        .padding(.horizontal, TWSpacing.p(8))
                        .padding(.bottom, TWSpacing.p(8))

                    // ── SUBTASKS section ────────────────────────────────
                    VStack(alignment: .leading, spacing: TWSpacing.p(4)) {
                        HStack {
                            Text("SUBTASKS")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color.slate400)
                            Spacer()
                            Text("\(completionPct)% Complete")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.slate400)
                        }

                        VStack(spacing: TWSpacing.p(3)) {
                            ForEach($subtasks) { $item in
                                SubtaskRow(item: $item)
                            }

                            // Add subtask row
                            HStack(spacing: TWSpacing.p(3)) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.slate400)
                                Text("Add subtask")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.slate400)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                subtasks.append(SubtaskItem(title: "New subtask", isCompleted: false))
                            }
                        }
                    }
                    .padding(.horizontal, TWSpacing.p(8))
                    .padding(.bottom, TWSpacing.p(8))

                    // ── NOTES section ────────────────────────────────────
                    VStack(alignment: .leading, spacing: TWSpacing.p(4)) {
                        Text("NOTES")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(Color.slate400)

                        // min-h-[120px] p-4 rounded-xl bg-slate-50 border border-slate-100
                        TextEditor(text: $notesText)
                            .font(.system(size: 14).italic())
                            .foregroundColor(Color.slate500)
                            .lineSpacing(4)
                            .padding(TWSpacing.p(4))
                            .frame(minHeight: 120)
                            .background(Color.slate50)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.slate100, lineWidth: 1)
                            )
                            .scrollContentBackground(.hidden)
                            .onChange(of: notesText) { newValue in
                                notesPublisher.send(newValue)
                            }
                    }
                    .padding(.horizontal, TWSpacing.p(8))
                    .padding(.bottom, TWSpacing.p(8))

                    // ── POMODORO SESSION card ────────────────────────────
                    // p-6 rounded-2xl bg-slate-900 text-white
                    VStack(spacing: 0) {
                        HStack {
                            HStack(spacing: TWSpacing.p(2)) {
                                Image(systemName: "timer")
                                    .font(.system(size: 16, weight: .bold))
                                Text("POMODORO SESSION")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(0.5)
                            }
                            Spacer()
                            Text("2/4 completed")
                                .font(.system(size: 12, weight: .medium))
                                .opacity(0.7)
                        }
                        .padding(.bottom, TWSpacing.p(4))

                        HStack(alignment: .bottom) {
                            // text-4xl font-black tracking-tighter
                            Text(timerDisplay)
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .tracking(-1.5)

                            Spacer()

                            // START FOCUS button: bg-white text-slate-900 px-5 py-2 rounded-full
                            Button(action: {
                                viewModel.start(duration: 1500)
                                viewModel.activeMode = .focus
                            }) {
                                Text("START FOCUS")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.5)
                                    .padding(.horizontal, TWSpacing.p(5))
                                    .padding(.vertical, TWSpacing.p(2))
                                    .background(Color.white)
                                    .foregroundColor(Color.slate900)
                                    .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(TWSpacing.p(6))
                    .foregroundColor(Color.white)
                    .background(Color.slate900)
                    .cornerRadius(16)
                    .padding(.horizontal, TWSpacing.p(8))
                    .padding(.bottom, TWSpacing.p(8))
                }
            }

            // ── Footer: created date + delete ───────────────────────────
            Divider().background(Color.slate100)
            HStack {
                Text("Created 2 days ago")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.slate400)

                Spacer()

                Button(action: {
                    viewModel.delete(id: task.id)
                    viewModel.selectedTaskID = nil
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(isDeleteHovered ? Color(hex: "#EF4444") : Color.slate400)
                }
                .buttonStyle(.plain)
                .onHover { h in
                    withAnimation(.easeInOut(duration: 0.15)) { isDeleteHovered = h }
                }
            }
            .padding(.horizontal, TWSpacing.p(8))
            .padding(.vertical, TWSpacing.p(6))
            .background(Color.slate50.opacity(0.5))
        }
        .background(Color.white)
        .onAppear {
            notesText = task.notes ?? ""

            notesPublisher
                .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                .sink { upsertNote(id: task.id, note: $0) }
                .store(in: &cancellables)
        }
    }
}

// MARK: - SubtaskRow
private struct SubtaskRow: View {
    @Binding var item: SubtaskItem

    var body: some View {
        HStack(spacing: TWSpacing.p(3)) {
            // Custom checkbox mimicking w-4 h-4 rounded
            Button(action: { item.isCompleted.toggle() }) {
                Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 16))
                    .foregroundColor(item.isCompleted ? Color.slate300 : Color.primaryBackground)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.system(size: 14))
                .foregroundColor(item.isCompleted ? Color.slate500 : Color.slate700)
                .strikethrough(item.isCompleted, color: Color.slate400)
                .lineLimit(1)

            Spacer()
        }
    }
}

// MARK: - ActionIconButton
private struct ActionIconButton: View {
    let icon: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.slate500)
                .padding(6)
                .background(isHovered ? Color.slate100 : Color.clear)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
