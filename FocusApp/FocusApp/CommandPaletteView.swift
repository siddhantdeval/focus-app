import SwiftUI
import FocusCore

struct CommandPaletteView: View {
    @ObservedObject var viewModel: FocusViewModel
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredTasks: [FocusTask] {
        if searchText.isEmpty { return Array(viewModel.tasks.prefix(5)) }
        return viewModel.tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Search Input Row
            HStack(spacing: TWSpacing.p(4)) {
                Image(systemName: "magnifyingglass")
                    .font(TWFont.xl)
                    .foregroundColor(Color.slate400)
                
                TextField("Type a command or search tasks...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(TWFont.xl)
                    .foregroundColor(Color.primaryBackground)
                    .focused($isSearchFocused)
                    .onSubmit {
                        if let first = filteredTasks.first {
                            viewModel.activeMode = .tasks
                            viewModel.selectedTaskID = first.id
                            isPresented = false
                        }
                    }
                
                Spacer()
                
                Text("ESC")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, TWSpacing.p(2))
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .foregroundColor(Color.slate400)
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.slate200, lineWidth: 1))
            }
            .padding(TWSpacing.p(6))
            .background(Color.white)
            
            Divider().background(Color.slate100)
            
            // Suggestions / Results list
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    if searchText.isEmpty {
                        // Section: Contextual Suggestions
                        VStack(alignment: .leading, spacing: TWSpacing.p(1)) {
                            Text("CONTEXTUAL SUGGESTIONS")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.0)
                                .foregroundColor(Color.slate400)
                                .padding(.horizontal, TWSpacing.p(6))
                                .padding(.vertical, TWSpacing.p(2))
                            
                            CommandRow(icon: "timer", title: "Start Focus Session", subtitle: "Jump to") {
                                viewModel.start(duration: 1500)
                                viewModel.activeMode = .focus
                                isPresented = false
                            }
                            
                            CommandRow(icon: "plus.circle", title: "Create New Task", subtitle: "") {
                                viewModel.addTask()
                                viewModel.activeMode = .tasks
                                isPresented = false
                            }
                            
                            CommandRow(icon: "chart.bar", title: "Go to Reports", subtitle: "") {
                                viewModel.activeMode = .reports
                                isPresented = false
                            }
                            
                            CommandRow(icon: "gearshape", title: "Settings", subtitle: "") {
                                viewModel.activeMode = .settings
                                isPresented = false
                            }
                        }
                        .padding(.vertical, TWSpacing.p(4))
                    }
                    
                    // Section: Task Results
                    VStack(alignment: .leading, spacing: TWSpacing.p(1)) {
                        Text(searchText.isEmpty ? "RECENT TASKS" : "SEARCH RESULTS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.0)
                            .foregroundColor(Color.slate400)
                            .padding(.horizontal, TWSpacing.p(6))
                            .padding(.vertical, TWSpacing.p(2))
                            .padding(.top, searchText.isEmpty ? TWSpacing.p(4) : 0)
                        
                        ForEach(filteredTasks, id: \.id) { task in
                            CommandRow(
                                icon: task.isCompleted ? "checkmark.circle.fill" : "circle",
                                title: task.title,
                                subtitle: "Task",
                                iconColor: task.isCompleted ? Color.slate300 : Color.slate400
                            ) {
                                viewModel.activeMode = .tasks
                                viewModel.selectedTaskID = task.id
                                isPresented = false
                            }
                        }
                        
                        if !searchText.isEmpty && filteredTasks.isEmpty {
                            Text("No tasks found matching \"\(searchText)\"")
                                .font(TWFont.sm)
                                .foregroundColor(Color.slate400)
                                .padding(.horizontal, TWSpacing.p(8))
                                .padding(.vertical, TWSpacing.p(6))
                        }
                    }
                    .padding(.bottom, TWSpacing.p(4))
                }
            }
            .frame(maxHeight: 320)
            
            Divider().background(Color.slate100)
            
            // Footer Navigation Hints
            HStack(spacing: TWSpacing.p(6)) {
                HintItem(key: "ENTER", action: "to select")
                HintItem(key: "↑ ↓", action: "to navigate")
                HintItem(key: "ESC", action: "to close")
                Spacer()
            }
            .padding(.horizontal, TWSpacing.p(6))
            .padding(.vertical, TWSpacing.p(4))
            .background(Color.slate50.opacity(0.5))
        }
        .frame(width: 640)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.2), radius: 32, x: 0, y: 16)
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct CommandRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = Color.primaryBackground
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TWSpacing.p(4)) {
                Image(systemName: icon)
                    .font(TWFont.lg)
                    .foregroundColor(isHovered ? Color.primaryBackground : Color.slate400)
                
                Text(title)
                    .font(TWFont.sm.weight(isHovered ? .semibold : .medium))
                    .foregroundColor(isHovered ? Color.primaryBackground : Color.slate500)
                
                Spacer()
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.slate400)
                }
            }
            .padding(.horizontal, TWSpacing.p(4))
            .padding(.vertical, TWSpacing.p(3))
            .background(isHovered ? Color.slate50 : Color.clear)
            .cornerRadius(8)
            .padding(.horizontal, TWSpacing.p(2))
        }
        .buttonStyle(.plain)
        .onHover { hover in
            isHovered = hover
        }
    }
}

struct HintItem: View {
    let key: String
    let action: String
    
    var body: some View {
        HStack(spacing: TWSpacing.p(1.5)) {
            Text(key)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, TWSpacing.p(2))
                .padding(.vertical, 4)
                .background(Color.white)
                .foregroundColor(Color.primaryBackground)
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.slate200, lineWidth: 1))
            
            Text(action)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.slate400)
        }
    }
}
