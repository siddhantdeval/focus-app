import SwiftUI
import FocusCore

struct MenuBarCompanionView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Top Status Bar
            HStack {
                HStack(spacing: TWSpacing.p(1.5)) {
                    Image(systemName: "timer")
                        .font(TWFont.sm)
                        .foregroundColor(.blue) // Primary Accent
                    Text("\(timeString(from: viewModel.timerRemaining)) | Focus")
                        .font(TWFont.sm.weight(.bold))
                        .foregroundColor(Color.primary)
                }
                
                Spacer()
                
                HStack(spacing: TWSpacing.p(2)) {
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .font(TWFont.sm)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color.secondary)
                    
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "ellipsis")
                            .font(TWFont.sm)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color.secondary)
                }
            }
            .padding(.horizontal, TWSpacing.p(4))
            .padding(.top, TWSpacing.p(4))
            .padding(.bottom, TWSpacing.p(2))
            
            // 2. Active Task Section
            VStack(spacing: TWSpacing.p(1)) {
                Text("ACTIVE TASK")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.0)
                    .foregroundColor(Color.secondary)
                
                if let task = activeTask() {
                    Text(task.title)
                        .font(TWFont.lg.weight(.semibold))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TWSpacing.p(4))
                } else {
                    Text("No task running")
                        .font(TWFont.lg.weight(.semibold))
                        .foregroundColor(Color.primary)
                }
                
                // Big Controls
                HStack(spacing: TWSpacing.p(6)) {
                    controlButton(icon: "play.fill", label: "Start", isActive: true) {
                        viewModel.start(duration: 1500)
                    }
                    controlButton(icon: "pause.fill", label: "Pause", isActive: false) {
                        viewModel.pause()
                    }
                    controlButton(icon: "stop.fill", label: "Stop", isActive: false) {
                        viewModel.stop()
                    }
                }
                .padding(.top, TWSpacing.p(3))
            }
            .padding(.vertical, TWSpacing.p(4))
            
            // 3. Quick Input Field
            HStack(spacing: TWSpacing.p(2)) {
                Image(systemName: "plus")
                    .foregroundColor(Color.secondary)
                    .font(TWFont.sm)
                TextField("Hit Enter to add...", text: $viewModel.newTaskTitle)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(TWFont.sm)
                    .onSubmit {
                        viewModel.addTask()
                    }
            }
            .padding(.horizontal, TWSpacing.p(4))
            .padding(.bottom, TWSpacing.p(2))
            
            Divider()
                .padding(.horizontal, TWSpacing.p(4))
            
            // 4. Upcoming Focus
            VStack(alignment: .leading, spacing: TWSpacing.p(3)) {
                Text("UPCOMING FOCUS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundColor(Color.secondary)
                    .padding(.bottom, TWSpacing.p(1))
                
                // Top 3 tasks
                ForEach(viewModel.tasks.filter { !$0.isCompleted }.prefix(3), id: \.id) { task in
                    HStack(spacing: TWSpacing.p(3)) {
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.secondary.opacity(0.5), lineWidth: 1)
                            .frame(width: 16, height: 16)
                            .onTapGesture {
                                viewModel.toggleTaskCompletion(task: task)
                            }
                        
                        Text(task.title)
                            .font(TWFont.sm)
                            .foregroundColor(Color.primary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(TWSpacing.p(4))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 5. Footer Stats
            HStack {
                Text("DAILY PROGRESS: 4 / 12")
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                    Text("FOCUS SCORE: 88")
                }
            }
            .font(.system(size: 10, weight: .medium))
            .tracking(0.5)
            .padding(.horizontal, TWSpacing.p(4))
            .padding(.vertical, TWSpacing.p(3))
            .background(Color.black.opacity(0.05))
            .foregroundColor(Color.secondary)
            
        }
        .frame(width: 320)
        // Background relies on native MenuBarExtra material style
    }
    
    // Helpers
    private func activeTask() -> FocusTask? {
        return viewModel.tasks.first(where: { !$0.isCompleted })
    }
    
    private func timeString(from seconds: UInt32) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func controlButton(icon: String, label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isActive ? Color.blue : Color.primary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isActive ? .white : .primary)
                }
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
