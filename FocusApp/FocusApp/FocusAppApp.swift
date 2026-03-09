//
//  FocusAppApp.swift
//  FocusApp
//
//  Created by Siddhant Deval on 09/03/26.
//

import SwiftUI
import FocusCore
import UserNotifications

@main
struct FocusAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Find the Application Support directory for this app
        if let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            // Create the directory if it doesn't exist
            try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
            
            // Set the path for the SQLite database
            let dbURL = appSupportDir.appendingPathComponent("focus_tasks.db")
            print("Initializing Rust Core at path: \(dbURL.path)")
            
            // Initialize the Rust Core
            initCore(dbPath: dbURL.path)
            
            // Request Notification Permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    print("Notifications permission granted")
                } else if let error = error {
                    print("Notifications error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        
        MenuBarContainer()
    }
}

// Shell view to hold the ViewModel for the Menu Bar isolated context
struct MenuBarRootView: View {
    @StateObject var viewModel = FocusViewModel()
    var body: some View {
        MenuBarCompanionView(viewModel: viewModel)
    }
}

// Wrapper to hold the shared state for the MenuBar title
struct MenuBarContainer: Scene {
    @StateObject private var viewModel = FocusViewModel()
    
    var body: some Scene {
        MenuBarExtra(content: {
            MenuBarCompanionView(viewModel: viewModel)
        }, label: {
            HStack {
                Image(systemName: "timer")
                if viewModel.timerState == .running || viewModel.timerState == .paused {
                    Text(timeString(from: viewModel.timerRemaining))
                }
            }
        })
        .menuBarExtraStyle(.window)
    }
    
    private func timeString(from seconds: UInt32) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// Global Notification Delegate for S10 implementation
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Handle notification action events globally
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        
        if actionIdentifier == "BREAK_ACTION" {
            // S10: Trigger 5 minute rest cycle via ViewModel/Core
            print("User requested: Start Break")
            // Implementation requires accessing the shared ViewModel instance or Core directly
        } else if actionIdentifier == "SKIP_ACTION" {
            // S10: User skips break, continue working
            print("User requested: Skip Break")
        }
        
        completionHandler()
    }
}

