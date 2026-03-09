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

        let mut tasks = db.get_tasks().unwrap();
        assert_eq!(tasks.len(), 1);
        assert_eq!(tasks[0].is_completed, false);

        // Test update
        db.update_task_status("1", true, 2000).unwrap();
        tasks = db.get_tasks().unwrap();
        assert_eq!(tasks[0].is_completed, true);

        // Test delete
        db.delete_task("1").unwrap();
        tasks = db.get_tasks().unwrap();
        assert_eq!(tasks.len(), 0);
    }

    #[test]
    fn test_persistent_database() {
        let temp_dir = std::env::temp_dir();
        let db_path = temp_dir.join("test_focus.db");
        
        // Clean up previous test run if exists
        if db_path.exists() {
            let _ = std::fs::remove_file(&db_path);
        }

        {
            let db = crate::database::Database::open(&db_path).unwrap();
            db.create_task("p1", "Persistent Task", 1000).unwrap();
        } // Connection drops here

        // Re-open and verify
        let db = crate::database::Database::open(&db_path).unwrap();
        let tasks = db.get_tasks().unwrap();
        assert_eq!(tasks.len(), 1);
        assert_eq!(tasks[0].title, "Persistent Task");

        let _ = std::fs::remove_file(&db_path);
    }
    
    #[test]
    fn test_fts5_search_indexing() {
        let db = crate::database::Database::open_in_memory().unwrap();
        
        // Create variations of tasks
        db.create_task("search_task_1", "Finish the quarterly financial report", 1000).unwrap();
        db.create_task("search_task_2", "Buy groceries: apples, milk, bread", 1001).unwrap();
        db.create_task("search_task_3", "Report bugs found in the new release", 1002).unwrap();
        
        // Need a slight buffer to ensure async MPSC commands persist if this was truly async,
        // though our implementation waits on rx.recv(), so it is synchronous to the caller.
        
        // Exact match
        let results = db.search_tasks("financial").unwrap();
        assert_eq!(results.len(), 1);
        assert_eq!(results[0].id, "search_task_1");
        
        // Partial/stem match ("Report" hits "report" in task 1 and "Report" in task 3)
        let results2 = db.search_tasks("report").unwrap();
        assert_eq!(results2.len(), 2);
        
        // Delete a task and ensure it drops from FTS5 index
        db.delete_task("search_task_1").unwrap();
        let results3 = db.search_tasks("financial").unwrap();
        assert_eq!(results3.len(), 0);
        
        // Update a task and verify FTS5 changes
        // (Currently, update_task_status doesn't change title, so we skip title updates
        // but verify status completion via get_tasks).
        db.update_task_status("search_task_2", true, 2000).unwrap();
        let results4 = db.search_tasks("groceries").unwrap();
        assert_eq!(results4.len(), 1);
        assert_eq!(results4[0].is_completed, true);
    }
}
