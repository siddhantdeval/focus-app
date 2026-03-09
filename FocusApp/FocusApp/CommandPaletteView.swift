import SwiftUI
import FocusCore

struct CommandPaletteView: View {
    @ObservedObject var viewModel: FocusViewModel
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    
    var filteredTasks: [FocusTask] {
        if searchText.isEmpty { return viewModel.tasks }
        return viewModel.tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Input
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Type a command or search tasks...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.title3)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Results List
            List(filteredTasks, id: \.id) { task in
                Button(action: {
                    viewModel.activeMode = .tasks
                    viewModel.selectedTaskID = task.id
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                        Text(task.title)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
            
            // Footer
            HStack {
                Text("ENTER to select")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("ESC to dismiss")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 500, height: 400)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}
