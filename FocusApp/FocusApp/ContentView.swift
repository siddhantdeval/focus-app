//
//  ContentView.swift
//  FocusApp
//
//  Created by Siddhant Deval on 09/03/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var showingCommandPalette = false
    
    var body: some View {
        ZStack {
            if viewModel.activeMode == .focus {
                FocusModeView(viewModel: viewModel)
            } else {
                NavigationSplitView {
                    MainSidebarView(viewModel: viewModel)
                } detail: {
                    switch viewModel.activeMode {
                    case .dashboard:
                        DashboardView(viewModel: viewModel)
                    case .tasks:
                        TaskListView(viewModel: viewModel)
                    case .settings:
                        SettingsView(viewModel: viewModel)
                    default:
                        Text("Work in Progress: \(viewModel.activeMode.rawValue)")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .frame(minWidth: 800, minHeight: 600)
            }
            
            // Command Palette Overlay (S7)
            if showingCommandPalette {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingCommandPalette = false
                    }
                
                CommandPaletteView(viewModel: viewModel, isPresented: $showingCommandPalette)
            }
        }
        // Global Keyboard Shortcut for Command Palette
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.keyCode == 40 { // 40 is 'k'
                    showingCommandPalette.toggle()
                    return nil
                }
                return event
            }
        }
    }
}

#Preview {
    ContentView()
}
