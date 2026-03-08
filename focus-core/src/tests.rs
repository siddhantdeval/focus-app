use crate::TimerObserver;
use crate::timer::{TimerEngine, TimerState};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

struct TestObserver {
    ticks: Mutex<Vec<u32>>,
    states: Mutex<Vec<TimerState>>,
}

impl TimerObserver for TestObserver {
    fn on_tick(&self, remaining_seconds: u32) {
        self.ticks.lock().unwrap().push(remaining_seconds);
    }
    fn on_state_changed(&self, state: TimerState) {
        self.states.lock().unwrap().push(state);
    }
}

// Implement a wrapper to handle the Box vs Arc issue in tests
struct ObserverWrapper(Arc<TestObserver>);
impl TimerObserver for ObserverWrapper {
    fn on_tick(&self, remaining_seconds: u32) {
        self.0.on_tick(remaining_seconds);
    }
    fn on_state_changed(&self, state: TimerState) {
        self.0.on_state_changed(state);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_timer_lifecycle() {
        let timer = TimerEngine::new();
        let observer = Arc::new(TestObserver {
            ticks: Mutex::new(Vec::new()),
            states: Mutex::new(Vec::new()),
        });

        // Use the wrapper to fulfill the Box<dyn TimerObserver> requirement
        timer.set_observer(Box::new(ObserverWrapper(Arc::clone(&observer))));
        timer.start(1); // 1 second timer

        thread::sleep(Duration::from_secs(3));

        let states = observer.states.lock().unwrap();
        let ticks = observer.ticks.lock().unwrap();

        assert!(states.contains(&TimerState::Running));
        assert!(states.contains(&TimerState::Idle));
        assert!(ticks.contains(&1));
    }

    #[test]
    fn test_database_integration() {
        let db = crate::database::Database::open_in_memory().unwrap();
        db.create_task("1", "Test Task", 1000).unwrap();

        let tasks = db.get_tasks().unwrap();
        assert_eq!(tasks.len(), 1);
    }
}
