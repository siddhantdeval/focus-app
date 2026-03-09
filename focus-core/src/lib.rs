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

static DB: Lazy<Mutex<Option<database::Database>>> = Lazy::new(|| {
    Mutex::new(None)
});

static TIMER: Lazy<timer::TimerEngine> = Lazy::new(timer::TimerEngine::new);

// --- EXPORTED FUNCTIONS ---

#[uniffi::export]
pub fn init_core(db_path: String) {
    let mut db_lock = DB.lock().unwrap();
    if db_lock.is_none() {
        let db = database::Database::open(&db_path).expect("Failed to open permanent database");
        *db_lock = Some(db);
    }
}

#[uniffi::export]
pub fn create_task(title: String) -> Task {
    let id = uuid::Uuid::new_v4().to_string();
    let timestamp = chrono::Utc::now().timestamp();
    let task = Task {
        id: id.clone(),
        title: title.clone(),
        is_completed: false,
    };

    let db_lock = DB.lock().unwrap();
    if let Some(db) = db_lock.as_ref() {
        db.create_task(&id, &title, timestamp)
            .expect("Failed to create task in database");
    } else {
        panic!("Core not initialized. Call init_core() first.");
    }
    task
}

#[uniffi::export]
pub fn get_tasks() -> Vec<Task> {
    let db_lock = DB.lock().unwrap();
    if let Some(db) = db_lock.as_ref() {
        db.get_tasks().expect("Failed to fetch tasks from database")
    } else {
        panic!("Core not initialized. Call init_core() first.");
    }
}

#[uniffi::export]
pub fn update_task_status(id: String, completed: bool) {
    let timestamp = chrono::Utc::now().timestamp();
    let db_lock = DB.lock().unwrap();
    if let Some(db) = db_lock.as_ref() {
        db.update_task_status(&id, completed, timestamp)
            .expect("Failed to update task status in database");
    } else {
        panic!("Core not initialized. Call init_core() first.");
    }
}

#[uniffi::export]
pub fn delete_task(id: String) {
    let db_lock = DB.lock().unwrap();
    if let Some(db) = db_lock.as_ref() {
        db.delete_task(&id)
            .expect("Failed to delete task from database");
    } else {
        panic!("Core not initialized. Call init_core() first.");
    }
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
