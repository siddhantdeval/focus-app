import SwiftUI
import FocusCore

struct SettingsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    @State private var pomodoroDuration: String = "25"
    @State private var breakDuration: String = "5"
    @State private var sessionReminders: Bool = true
    @State private var completionAlerts: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TWSpacing.p(16)) {
                
                // Header
                VStack(alignment: .leading, spacing: TWSpacing.p(2)) {
                    Text("Settings")
                        .font(TWFont.xxxl.weight(.bold))
                        .foregroundColor(Color.primaryBackground)
                    Text("Manage your application preferences and account data.")
                        .font(TWFont.base)
                        .foregroundColor(Color.slate500)
                }
                .padding(.bottom, TWSpacing.p(4))
                
                // 1. General Section
                SettingSection(title: "General", icon: "slider.horizontal.3") {
                    HStack(spacing: TWSpacing.p(8)) {
                        VStack(alignment: .leading, spacing: TWSpacing.p(2)) {
                            Text("Default Pomodoro Duration")
                                .font(TWFont.sm.weight(.medium))
                                .foregroundColor(Color.slate700)
                            
                            Picker("", selection: $pomodoroDuration) {
                                Text("15 minutes").tag("15")
                                Text("25 minutes").tag("25")
                                Text("50 minutes").tag("50")
                                Text("60 minutes").tag("60")
                            }
                            .labelsHidden()
                            .pickerStyle(MenuPickerStyle())
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, TWSpacing.p(2))
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.slate200, lineWidth: 1))
                            .onChange(of: pomodoroDuration) { newValue in
                                setSetting(key: "pomodoro_duration", value: newValue)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: TWSpacing.p(2)) {
                            Text("Break Duration")
                                .font(TWFont.sm.weight(.medium))
                                .foregroundColor(Color.slate700)
                            
                            Picker("", selection: $breakDuration) {
                                Text("5 minutes").tag("5")
                                Text("10 minutes").tag("10")
                                Text("15 minutes").tag("15")
                            }
                            .labelsHidden()
                            .pickerStyle(MenuPickerStyle())
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, TWSpacing.p(2))
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.slate200, lineWidth: 1))
                        }
                    }
                }
                
                // 2. Notifications Section
                SettingSection(title: "Notifications", icon: "bell") {
                    VStack(spacing: TWSpacing.p(6)) {
                        ToggleRow(
                            title: "Session Reminders",
                            description: "Receive alerts when it's time to start a session",
                            isOn: $sessionReminders
                        )
                        ToggleRow(
                            title: "Completion Alerts",
                            description: "Play a sound when a task or session is finished",
                            isOn: $completionAlerts
                        )
                    }
                }
                
                // 3. Synchronization Section
                SettingSection(title: "Synchronization", icon: "arrow.triangle.2.circlepath") {
                    HStack {
                        HStack(spacing: TWSpacing.p(4)) {
                            Image(systemName: "cloud")
                                .font(TWFont.xl)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.slate200, lineWidth: 1))
                                .foregroundColor(Color.primaryBackground)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("local-device-sync")
                                    .font(TWFont.sm.weight(.semibold))
                                    .foregroundColor(Color.primaryBackground)
                                Text("Last synced: 2 minutes ago")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.slate500)
                            }
                        }
                        Spacer()
                        
                        Button(action: {
                            viewModel.fetchTasks() // manual sync trigger
                        }) {
                            Text("Sync Now")
                                .font(TWFont.sm.weight(.semibold))
                                .padding(.horizontal, TWSpacing.p(6))
                                .padding(.vertical, TWSpacing.p(2))
                                .background(Color.white)
                                .foregroundColor(Color.primaryBackground)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.slate200, lineWidth: 1))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(TWSpacing.p(6))
                    .background(Color.slate50)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate100, lineWidth: 1))
                }
                
                // 4. Data Management Section
                SettingSection(title: "Data Management", icon: "externaldrive") {
                    HStack(spacing: TWSpacing.p(4)) {
                        Button(action: {}) {
                            HStack(spacing: TWSpacing.p(2)) {
                                Image(systemName: "square.and.arrow.down")
                                Text("Export Data (.json)")
                            }
                            .font(TWFont.sm.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TWSpacing.p(3))
                            .background(Color.white)
                            .foregroundColor(Color.primaryBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.slate200, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {}) {
                            HStack(spacing: TWSpacing.p(2)) {
                                Image(systemName: "arrow.up.doc")
                                Text("Create Backup")
                            }
                            .font(TWFont.sm.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TWSpacing.p(3))
                            .background(Color.white)
                            .foregroundColor(Color.primaryBackground)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.slate200, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // 5. Danger Zone
                VStack(spacing: TWSpacing.p(8)) {
                    HStack {
                        VStack(alignment: .leading, spacing: TWSpacing.p(1)) {
                            Text("Danger Zone")
                                .font(TWFont.sm.weight(.bold))
                                .foregroundColor(Color.primaryBackground)
                            Text("Permanently delete your account and all productivity data.")
                                .font(.system(size: 12))
                                .foregroundColor(Color.slate500)
                        }
                        Spacer()
                        Button(action: {}) {
                            Text("Delete Account")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, TWSpacing.p(4))
                                .padding(.vertical, TWSpacing.p(2))
                                .background(Color.white)
                                .foregroundColor(Color.primaryBackground)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primaryBackground, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(TWSpacing.p(6))
                    .background(Color.slate50)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slate200, lineWidth: 1))
                }
                .padding(.top, TWSpacing.p(8))
                
                // Footer
                HStack {
                    Text("FocusFlow v2.4.0")
                    Spacer()
                    Text("© 2024 Productivity Systems Inc.")
                }
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.0)
                .textCase(.uppercase)
                .foregroundColor(Color.slate400)
                .padding(.top, TWSpacing.p(8))
                .padding(.bottom, TWSpacing.p(12))
            }
            .padding(TWSpacing.p(12))
            .frame(maxWidth: 800)
        }
        .background(Color.white)
        .onAppear {
            if let durationStr = getSetting(key: "pomodoro_duration") {
                self.pomodoroDuration = durationStr
            }
        }
    }
}

// Subcomponents

struct SettingSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: TWSpacing.p(6)) {
            HStack(spacing: TWSpacing.p(2)) {
                Image(systemName: icon)
                    .font(TWFont.base)
                    .foregroundColor(Color.primaryBackground)
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1.0)
                    .textCase(.uppercase)
                    .foregroundColor(Color.slate500)
            }
            .padding(.bottom, TWSpacing.p(2))
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.slate100), alignment: .bottom)
            
            content
        }
    }
}

struct ToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: TWSpacing.p(1)) {
                Text(title)
                    .font(TWFont.sm.weight(.medium))
                    .foregroundColor(Color.primaryBackground)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(Color.slate500)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color.primaryBackground))
        }
    }
}
