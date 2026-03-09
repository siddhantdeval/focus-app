import SwiftUI
import FocusCore

struct FocusModeView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Subtle Collapsible Sidebar Line
            HStack {
                Rectangle()
                    .fill(Color.slate100)
                    .frame(width: 2)
                    .ignoresSafeArea()
                Spacer()
            }
            
            // Top Status Message
            VStack {
                Text("FOCUS SESSION ACTIVE")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2.0)
                    .foregroundColor(Color.slate400)
                    .padding(.top, 48)
                Spacer()
            }
            
            VStack(spacing: 0) {
                // Mammoth Timer
                Text(timeString(from: viewModel.timerRemaining))
                    .font(.system(size: 220, weight: .bold, design: .rounded))
                    .tracking(-6.0)
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                
                // Task info
                VStack(spacing: TWSpacing.p(4)) {
                    Text(activeTask()?.title ?? "Design System Audit")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color.black)
                    
                    Text("3 of 5 SUBTASKS COMPLETED")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(Color.slate400)
                    
                    // Subtle Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.slate100)
                                .frame(height: 4)
                                .cornerRadius(2)
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: geometry.size.width * 0.6, height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(width: 260, height: 4)
                }
                .padding(.top, TWSpacing.p(4))
            }
            
            // Bottom Controls and Quote
            VStack {
                Spacer()
                
                HStack(spacing: 64) {
                    Button(action: {
                        if viewModel.timerState == .running {
                            viewModel.pause()
                        } else if viewModel.timerState == .paused {
                            viewModel.resume()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(viewModel.timerState == .running ? "PAUSE" : "RESUME")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2.0)
                                .foregroundColor(Color.blue)
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 48, height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Text("SKIP BREAK")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2.0)
                                .foregroundColor(Color.slate400)
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 48, height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        viewModel.stop()
                        exitFocusMode()
                    }) {
                        VStack(spacing: 8) {
                            Text("RESET SESSION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2.0)
                                .foregroundColor(Color.slate400)
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 48, height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 64)
                
                Text("DEEP WORK IS A SUPERPOWER IN OUR INCREASINGLY COMPETITIVE ECONOMY.")
                    .font(.system(size: 9, weight: .light))
                    .tracking(3.0)
                    .foregroundColor(Color.slate300)
                    .padding(.bottom, 32)
            }
            
            // Top Right Utility (Exit Full Screen Fallback)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        exitFocusMode()
                    }) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .font(TWFont.lg)
                            .foregroundColor(Color.slate200)
                    }
                    .buttonStyle(.plain)
                }
                .padding(TWSpacing.p(8))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            enterFullscreen()
        }
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
    
    private func enterFullscreen() {
        if let window = NSApplication.shared.windows.first {
            if !window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }
    }
    
    private func exitFocusMode() {
        if let window = NSApplication.shared.windows.first {
            if window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }
        viewModel.activeMode = .dashboard
    }
}
