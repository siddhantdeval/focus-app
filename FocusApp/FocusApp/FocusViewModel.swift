import Foundation
import Combine
import SwiftUI

@MainActor
class FocusViewModel: ObservableObject {
    @Published var tasks: [FocusTask] = []
    @Published var newTaskTitle: String = ""
    @Published var searchQuery: String = ""
    
    @Published var timerRemaining: UInt32 = 0
    @Published var timerState: TimerState = .idle
    
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
