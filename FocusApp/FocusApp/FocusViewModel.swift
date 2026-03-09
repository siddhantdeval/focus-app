import Foundation
import Combine
import SwiftUI

@MainActor
class FocusViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var newTaskTitle: String = ""
    
    @Published var timerRemaining: UInt32 = 0
    @Published var timerState: TimerState = .idle
    
    private let timerObserver: SwiftTimerObserver
    
    init() {
        self.timerObserver = SwiftTimerObserver()
        self.timerObserver.viewModel = self
        fetchTasks()
    }
    
    func fetchTasks() {
        self.tasks = getTasks()
    }
    
    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let _ = createTask(title: newTaskTitle)
        self.newTaskTitle = ""
        fetchTasks()
    }
    
    func toggleTaskCompletion(task: Task) {
        updateTaskStatus(id: task.id, completed: !task.isCompleted)
        fetchTasks()
    }
    
    func delete(id: String) {
        deleteTask(id: id)
        fetchTasks()
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

// Bridging the Rust trait to Swift
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

