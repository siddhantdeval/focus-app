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
                HStack(spacing: 0) {
                    MainSidebarView(viewModel: viewModel)
                        .frame(width: 256)
                        .background(Color.backgroundLight)
                        .border(Color.slate200, width: 1)
                    
                    switch viewModel.activeMode {
                    case .dashboard:
                        DashboardView(viewModel: viewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .tasks:
                        TaskListView(viewModel: viewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .settings:
                        SettingsView(viewModel: viewModel)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default:
                        Text("Work in Progress: \(viewModel.activeMode.rawValue)")
                            .font(TWFont.xxl)
                            .foregroundColor(Color.slate400)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .ignoresSafeArea()
                .frame(minWidth: 900, minHeight: 600)
                .background(Color.backgroundLight)
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
