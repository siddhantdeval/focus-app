import SwiftUI
import FocusCore

struct SettingsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    // In a real app, bind these directly to the ConfigService using property wrappers
    @State private var pomodoroDuration: Int = 25
    
    var body: some View {
        Form {
            Section("General") {
                Picker("Default Pomodoro Duration", selection: $pomodoroDuration) {
                    Text("15 minutes").tag(15)
                    Text("25 minutes").tag(25)
                    Text("50 minutes").tag(50)
                }
                .onChange(of: pomodoroDuration) { newValue in
                    setSetting(key: "pomodoro_duration", value: String(newValue))
                }
            }
            
            Section("Data Management") {
                Button("Sync Now") {
                    print("Triggering manual sync...")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if let durationStr = getSetting(key: "pomodoro_duration"),
               let duration = Int(durationStr) {
                self.pomodoroDuration = duration
            }
        }
    }
}
