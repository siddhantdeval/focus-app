import SwiftUI
import FocusCore

struct TaskDetailView: View {
    @ObservedObject var viewModel: FocusViewModel
    var task: FocusTask
    
    @State private var notesText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(task.title)
                .font(.largeTitle)
                .bold()
            
            Text("Notes")
                .font(.headline)
            
            TextEditor(text: $notesText)
                .frame(minHeight: 200)
                .border(Color.gray.opacity(0.2))
                .onChange(of: notesText) { newValue in
                    // Debounce saving in real app
                    upsertNote(id: task.id, note: newValue)
                }
            
            Spacer()
            
            Button("START FOCUS") {
                viewModel.activeMode = .focus
                viewModel.start(duration: 1500)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            self.notesText = task.notes ?? ""
        }
    }
}
