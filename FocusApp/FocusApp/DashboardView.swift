import SwiftUI
import FocusCore

struct DashboardView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top Navigation Bar
            HStack(spacing: TWSpacing.p(6)) {
                Text(currentDateString())
                    .font(TWFont.lg.weight(.semibold))
                    .foregroundColor(Color.primaryBackground)
                
                // Search Input
                HStack(spacing: TWSpacing.p(2)) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.slate400)
                    TextField("Search tasks...", text: $viewModel.searchQuery)
                        .font(TWFont.sm)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, TWSpacing.p(4))
                .padding(.vertical, 8)
                .frame(width: 320)
                .background(Color.slate100)
                .cornerRadius(8)
                
                Spacer()
                
                // Actions
                HStack(spacing: TWSpacing.p(4)) {
                    Button(action: {}) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(TWFont.base)
                            .foregroundColor(Color.slate500)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(TWFont.base)
                            .foregroundColor(Color.slate500)
                    }
                    .buttonStyle(.plain)
                    
                    Divider().frame(height: 24).background(Color.slate200)
                    
                    Button(action: {
                        viewModel.addTask()
                        viewModel.activeMode = .tasks
                    }) {
                        HStack(spacing: TWSpacing.p(2)) {
                            Image(systemName: "plus")
                                .font(TWFont.xs.weight(.bold))
                            Text("New Task")
                                .font(TWFont.sm.weight(.semibold))
                        }
                        .padding(.horizontal, TWSpacing.p(3))
                        .padding(.vertical, 8)
                        .background(Color.primaryBackground)
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TWSpacing.p(8))
            .frame(height: 64)
            .background(Color.white)
            
            Divider().background(Color.slate200)
            
            // 2. Main Scroll Area
            ScrollView {
                VStack(spacing: TWSpacing.p(8)) {
                    
                    // Hero Grid (cols-12 system)
                    HStack(alignment: .top, spacing: TWSpacing.p(8)) {
                        
                        // Left (col-span-7 approx ~58%)
                        // POMODORO CARD
                        VStack(alignment: .center, spacing: 0) {
                            HStack {
                                Text("POMODORO")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(2.0)
                                    .foregroundColor(Color.slate400)
                                Spacer()
                            }
                            
                            Spacer()
                            
                            Text(timeString(from: viewModel.timerRemaining))
                                .font(.system(size: 120, weight: .bold, design: .rounded))
                                // Tracking tighter matching CSS `tracking-tighter`
                                .tracking(-4.0)
                                .foregroundColor(Color.primaryBackground)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            Text("Deep Focus Session")
                                .font(TWFont.xl.weight(.medium))
                                .foregroundColor(Color.slate500)
                                .padding(.bottom, TWSpacing.p(8))
                            
                            Button(action: {
                                viewModel.start(duration: 1500)
                                viewModel.activeMode = .focus
                            }) {
                                Text("START")
                                    .font(TWFont.base.weight(.bold))
                                    .frame(width: 140)
                                    .padding(.vertical, TWSpacing.p(3))
                                    .background(Color.primaryBackground)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(24)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            // Bottom Progress Line
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.slate100)
                                        .frame(height: 4)
                                        .cornerRadius(2)
                                    // Dummy progress
                                    Rectangle()
                                        .fill(Color.primaryBackground)
                                        .frame(width: geometry.size.width * 0.0, height: 4)
                                        .cornerRadius(2)
                                }
                            }
                            .frame(maxWidth: 320)
                            .frame(height: 4)
                            .padding(.top, TWSpacing.p(10))
                        }
                        .padding(TWSpacing.p(8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
                        
                        // Right (col-span-5 approx ~42%)
                        // CURRENT TASK CARD
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("CURRENT TASK")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(2.0)
                                    .foregroundColor(Color.slate400)
                                Spacer()
                                Image(systemName: "ellipsis")
                                    .foregroundColor(Color.slate400)
                            }
                            .padding(.bottom, TWSpacing.p(6))
                            
                            if let task = activeTask() {
                                Text(task.title)
                                    .font(TWFont.xxl.weight(.bold))
                                    .foregroundColor(Color.primaryBackground)
                                    .padding(.bottom, TWSpacing.p(2))
                                    .lineSpacing(4)
                                
                                Text("Design System Improvements")
                                    .font(TWFont.sm)
                                    .foregroundColor(Color.slate500)
                                
                                Spacer()
                                
                                VStack(spacing: TWSpacing.p(2)) {
                                    HStack {
                                        Text("Subtask Progress")
                                            .font(TWFont.sm)
                                            .foregroundColor(Color.slate400)
                                        Spacer()
                                        Text("3 / 5")
                                            .font(TWFont.sm.weight(.medium))
                                            .foregroundColor(Color.primaryBackground)
                                    }
                                    
                                    // Progress Bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.slate100)
                                                .frame(height: 8)
                                                .cornerRadius(4)
                                            Rectangle()
                                                .fill(Color.primaryBackground)
                                                .frame(width: geometry.size.width * 0.6, height: 8)
                                                .cornerRadius(4)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            } else {
                                Spacer()
                                Text("No active task selected")
                                    .foregroundColor(Color.slate400)
                                Spacer()
                            }
                        }
                        .padding(TWSpacing.p(8))
                        .frame(width: 380) // Fixed to mimic col-span prop
                        .frame(height: 380)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
                    }
                    
                    // Daily Tasks Section
                    VStack(alignment: .leading, spacing: TWSpacing.p(4)) {
                        HStack {
                            Text("Daily Tasks")
                                .font(TWFont.xl.weight(.bold))
                            
                            Spacer()
                            
                            HStack(spacing: TWSpacing.p(2)) {
                                Text("All")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, TWSpacing.p(4))
                                    .padding(.vertical, 6)
                                    .background(Color.primaryBackground)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(16)
                                
                                Text("Personal")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, TWSpacing.p(4))
                                    .padding(.vertical, 6)
                                    .foregroundColor(Color.slate400)
                                
                                Text("Work")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, TWSpacing.p(4))
                                    .padding(.vertical, 6)
                                    .foregroundColor(Color.slate400)
                            }
                        }
                        
                        // Tasks List Box
                        VStack(spacing: 0) {
                            ForEach(viewModel.tasks.prefix(3), id: \.id) { task in
                                TaskRowView(
                                    task: task,
                                    isSelected: false,
                                    onToggleComplete: {
                                        viewModel.toggleTaskCompletion(task: task)
                                    }
                                )
                                Divider().background(Color.slate200)
                            }
                            
                            // Inline Add Task Input
                            HStack(spacing: TWSpacing.p(4)) {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.slate400)
                                    .font(TWFont.base)
                                
                                TextField("Add a task to 'Daily List'...", text: $viewModel.newTaskTitle)
                                    .font(TWFont.sm)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onSubmit {
                                        viewModel.addTask()
                                    }
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color.slate400)
                                    Image(systemName: "flag")
                                        .foregroundColor(Color.slate400)
                                }
                            }
                            .padding(.horizontal, TWSpacing.p(6))
                            .padding(.vertical, TWSpacing.p(4))
                            .background(Color.slate50)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
                    }
                    
                    // Footer Actions
                    HStack(spacing: TWSpacing.p(6)) {
                        Button(action: {
                            viewModel.start(duration: 1500)
                            viewModel.activeMode = .focus
                        }) {
                            HStack(spacing: TWSpacing.p(3)) {
                                Image(systemName: "timer")
                                Text("Start focus session")
                            }
                            .font(TWFont.base.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TWSpacing.p(4))
                            .background(Color.primaryBackground)
                            .foregroundColor(Color.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            viewModel.addTask()
                        }) {
                            HStack(spacing: TWSpacing.p(3)) {
                                Image(systemName: "plus.circle")
                                Text("Quick add task")
                            }
                            .font(TWFont.base.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TWSpacing.p(4))
                            .background(Color.white)
                            .foregroundColor(Color.primaryBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {}) {
                            HStack(spacing: TWSpacing.p(3)) {
                                Image(systemName: "note.text.badge.plus")
                                Text("New quick note")
                            }
                            .font(TWFont.base.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TWSpacing.p(4))
                            .background(Color.white)
                            .foregroundColor(Color.primaryBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, TWSpacing.p(8))
                }
                .padding(.horizontal, TWSpacing.p(8))
                .padding(.top, TWSpacing.p(8))
            }
        }
        .background(Color.backgroundLight) // Global Page BG (slate-50 or white depending on theme)
    }
    
    // Helpers
    private func activeTask() -> FocusTask? {
        return viewModel.tasks.first(where: { !$0.isCompleted })
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func timeString(from seconds: UInt32) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

