import SwiftUI
import FocusCore

struct MainSidebarView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        List(selection: $viewModel.activeMode) {
            ForEach(AppMode.allCases, id: \.self) { mode in
                if mode != .focus {
                    NavigationLink(value: mode) {
                        Text(mode.rawValue)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
}
