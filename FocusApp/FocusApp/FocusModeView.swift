import SwiftUI
import FocusCore

struct FocusModeView: View {
    @ObservedObject var viewModel: FocusViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("FOCUS SESSION ACTIVE")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
            
            Spacer()
            
            Text(formatTime(viewModel.timerRemaining))
                .font(.system(size: 200, weight: .bold, design: .default))
                
            if let activeId = viewModel.selectedTaskID,
               let task = viewModel.tasks.first(where: { $0.id == activeId }) {
                Text(task.title)
                    .font(.largeTitle)
                    .padding()
            }
                
            Spacer()
            
            HStack(spacing: 40) {
                Button(viewModel.timerState == .paused ? "RESUME" : "PAUSE") {
                    if viewModel.timerState == .paused {
                        viewModel.resume()
                    } else {
                        viewModel.pause()
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                
                Button("END SESSION") {
                    viewModel.stop()
                    viewModel.activeMode = .dashboard
                    if let window = NSApplication.shared.windows.first {
                        if window.styleMask.contains(.fullScreen) {
                            window.toggleFullScreen(nil)
                        }
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.gray)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundColor(.white)
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                if !window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                }
            }
        }
    }
}
