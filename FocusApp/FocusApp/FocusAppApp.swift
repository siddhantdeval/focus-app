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
        
        MenuBarExtra("Focus", systemImage: "timer") {
            // Simplified Menu Bar Dropdown S8
            VStack(spacing: 12) {
                Text("Focus Session")
                    .font(.headline)
                
                Button("Bring to Front") {
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .padding()
        }
        .menuBarExtraStyle(.window)
    }
}
