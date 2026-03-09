import SwiftUI
import FocusCore

struct MainSidebarView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Branding Header
            VStack(alignment: .leading) {
                Text("FOCUS.")
                    .font(TWFont.xl.weight(.black))
                    .foregroundColor(.primaryBackground)
                    .tracking(-0.5)
            }
            .padding(.horizontal, TWSpacing.p(2))
            .padding(.bottom, TWSpacing.p(10))
            .padding(.top, TWSpacing.p(6))
            
            // Navigation Links
            VStack(spacing: TWSpacing.p(1)) {
                ForEach(AppMode.allCases, id: \.self) { mode in
                    if mode != .focus {
                        Button(action: {
                            viewModel.activeMode = mode
                        }) {
                            HStack(spacing: TWSpacing.p(3)) {
                                // SF Symbols Mapping
                                Image(systemName: icon(for: mode))
                                    .font(TWFont.base)
                                Text(mode.rawValue)
                                    .font(TWFont.sm.weight(.medium))
                                Spacer()
                            }
                            .padding(.horizontal, TWSpacing.p(3))
                            .padding(.vertical, TWSpacing.p(2.5))
                            .background(viewModel.activeMode == mode ? Color.primaryBackground : Color.clear)
                            .foregroundColor(viewModel.activeMode == mode ? Color.white : Color.slate500)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
            
            // User Profile Widget
            VStack {
                Divider().background(Color.slate100)
                HStack(spacing: TWSpacing.p(3)) {
                    Text("JD")
                        .font(TWFont.xs.weight(.bold))
                        .frame(width: 32, height: 32)
                        .background(Color.slate200)
                        .cornerRadius(16)
                    
                    VStack(alignment: .leading) {
                        Text("John Doe")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Pro Plan")
                            .font(.system(size: 10))
                            .foregroundColor(Color.slate400)
                    }
                    Spacer()
                }
                .padding(.horizontal, TWSpacing.p(2))
                .padding(.top, TWSpacing.p(6))
                .padding(.bottom, TWSpacing.p(6))
            }
        }
        .padding(.horizontal, TWSpacing.p(6))
        .frame(width: 256, alignment: .leading)
        .background(Color.backgroundLight)
    }
    
    private func icon(for mode: AppMode) -> String {
        switch mode {
        case .dashboard: return "square.grid.2x2"
        case .tasks: return "checkmark.circle"
        case .reports: return "chart.bar"
        case .settings: return "gearshape"
        case .focus: return ""
        }
    }
}
