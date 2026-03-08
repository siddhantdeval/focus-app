mod database;
#[cfg(test)]
mod tests;
mod timer;

use once_cell::sync::Lazy;
use std::sync::Mutex;

uniffi::setup_scaffolding!();

// --- DATA TYPES ---

#[derive(uniffi::Record)]
pub struct Task {
    pub id: String,
    pub title: String,
    pub is_completed: bool,
}

#[uniffi::export(callback_interface)]
pub trait TimerObserver: Send + Sync {
    fn on_tick(&self, remaining_seconds: u32);
    fn on_state_changed(&self, state: TimerState);
}

#[derive(Clone, Copy, Debug, PartialEq, uniffi::Enum)]
pub enum TimerState {
    Idle,
    Running,
    Paused,
}

// --- SINGLETONS ---

static DB: Lazy<Mutex<database::Database>> = Lazy::new(|| {
    let db = database::Database::open_in_memory().expect("Failed to open database");
    Mutex::new(db)
});

static TIMER: Lazy<timer::TimerEngine> = Lazy::new(timer::TimerEngine::new);

// --- EXPORTED FUNCTIONS ---

#[uniffi::export]
pub fn create_task(title: String) -> Task {
    let id = uuid::Uuid::new_v4().to_string();
    let timestamp = chrono::Utc::now().timestamp();
    let task = Task {
        id: id.clone(),
        title: title.clone(),
        is_completed: false,
    };

    let db = DB.lock().unwrap();
    db.create_task(&id, &title, timestamp)
        .expect("Failed to create task in database");
    task
}

#[uniffi::export]
pub fn get_tasks() -> Vec<Task> {
    let db = DB.lock().unwrap();
    db.get_tasks().expect("Failed to fetch tasks from database")
}

#[uniffi::export]
pub fn start_timer(duration_seconds: u32, observer: Box<dyn TimerObserver>) {
    TIMER.set_observer(observer);
    TIMER.start(duration_seconds);
}

#[uniffi::export]
pub fn pause_timer() {
    TIMER.pause();
}

#[uniffi::export]
pub fn resume_timer() {
    TIMER.resume();
}

#[uniffi::export]
pub fn stop_timer() {
    TIMER.stop();
}

#[uniffi::export]
pub fn get_version() -> String {
    "0.1.0-alpha".to_string()
}
