import Foundation
import Combine
import SwiftUI
import FocusCore

@MainActor
class FocusViewModel: ObservableObject {
    @Published var tasks: [FocusTask] = []
    @Published var newTaskTitle: String = ""
    @Published var searchQuery: String = ""
    
    @Published var timerRemaining: UInt32 = 0
    @Published var timerState: TimerState = .idle
    
    // Navigation State
    @Published var activeMode: AppMode = .dashboard
    @Published var selectedTaskID: String? = nil
    
    private let timerObserver: SwiftTimerObserver
    private let eventObserver: SwiftEventObserver
    
    init() {
        self.timerObserver = SwiftTimerObserver()
        self.eventObserver = SwiftEventObserver()
        
        self.timerObserver.viewModel = self
        self.eventObserver.viewModel = self
        
        setEventObserver(observer: self.eventObserver)
        
        fetchTasks()
    }
    
    func fetchTasks() {
        if searchQuery.isEmpty {
            self.tasks = getTasks()
        } else {
            self.tasks = searchTasks(query: searchQuery)
        }
    }
    
    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let _ = createTask(title: newTaskTitle)
        self.newTaskTitle = ""
        // No manual fetch needed anymore, observer handles it
    }
    
    func toggleTaskCompletion(task: FocusTask) {
        updateTaskStatus(id: task.id, completed: !task.isCompleted)
        // No manual fetch needed anymore, observer handles it
    }
    
    func delete(id: String) {
        deleteTask(id: id)
        // No manual fetch needed anymore, observer handles it
    }
    
    // MARK: - Timer Actions
    
    func start(duration: UInt32) {
        startTimer(durationSeconds: duration, observer: self.timerObserver)
    }
    
    func pause() {
        pauseTimer()
    }
    
    func resume() {
        resumeTimer()
    }
    
    func stop() {
        stopTimer()
    }
}

// React to backend events (e.g. database worker finished a write)
class SwiftEventObserver: EventObserver {
    weak var viewModel: FocusViewModel?
    
    func onEvent(event: CoreEvent) {
        guard let viewModel = viewModel else { return }
        
        switch event {
        case .tasksUpdated:
            DispatchQueue.main.async {
                viewModel.fetchTasks()
            }
        case .sessionComplete:
            DispatchQueue.main.async {
                viewModel.handleSessionComplete()
            }
        }
    }
}

// Bridging the Rust trait to Swift (Timer)
class SwiftTimerObserver: TimerObserver {
    weak var viewModel: FocusViewModel?
    
    func onTick(remainingSeconds: UInt32) {
        DispatchQueue.main.async {
            self.viewModel?.timerRemaining = remainingSeconds
        }
    }
    
    func onStateChanged(state: TimerState) {
        DispatchQueue.main.async {
            self.viewModel?.timerState = state
        }
    }
}


// Helper to format the Time string
func formatTime(_ totalSeconds: UInt32) -> String {
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

enum AppMode: String, CaseIterable {
    case dashboard = "Dashboard"
    case tasks = "Tasks"
    case reports = "Reports"
    case settings = "Settings"
    case focus = "Focus Mode"
}

import UserNotifications

extension FocusViewModel {
    func handleSessionComplete() {
        print("Session completed event received from Rust")
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Complete"
        content.body = "Great job! Time for a short break."
        content.sound = UNNotificationSound.default
        
        // Native S10 Notification Actions
        let skipAction = UNNotificationAction(identifier: "SKIP_ACTION", title: "Skip Break", options: .foreground)
        let breakAction = UNNotificationAction(identifier: "BREAK_ACTION", title: "Start Break", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "FOCUS_CATEGORY", actions: [breakAction, skipAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "FOCUS_CATEGORY"
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Fire immediately
        UNUserNotificationCenter.current().add(request)
    }
}
