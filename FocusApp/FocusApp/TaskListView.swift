import SwiftUI
import FocusCore

struct TaskListView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        NavigationSplitView {
            List(viewModel.tasks, id: \.id, selection: $viewModel.selectedTaskID) { task in
                HStack {
                    Toggle("", isOn: Binding(
                        get: { task.isCompleted },
                        set: { _ in viewModel.toggleTaskCompletion(task: task) }
                    ))
                    .labelsHidden()
                    
                    Text(task.title)
                        .strikethrough(task.isCompleted, color: .primary)
                }
            }
            .navigationTitle("Today's Focus")
        } detail: {
            if let selectedId = viewModel.selectedTaskID,
               let task = viewModel.tasks.first(where: { $0.id == selectedId }) {
                TaskDetailView(viewModel: viewModel, task: task)
            } else {
                Text("Select a task")
            }
        }
    }
}
