import SwiftUI
import FocusCore

struct DashboardView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack {
            Text("S1 Productivity Dashboard")
                .font(.largeTitle)
            
            Text(formatTime(viewModel.timerRemaining))
                .font(.system(size: 80, weight: .bold, design: .default))
                
            Button(viewModel.timerState == .idle ? "Start Session" : "Stop Session") {
                if viewModel.timerState == .idle {
                    viewModel.start(duration: 1500)
                } else {
                    viewModel.stop()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
