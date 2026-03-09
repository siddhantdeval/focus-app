//
//  FocusAppApp.swift
//  FocusApp
//
//  Created by Siddhant Deval on 09/03/26.
//

import SwiftUI

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
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
