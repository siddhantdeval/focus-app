mod database;
#[cfg(test)]
mod tests;
mod timer;

use once_cell::sync::Lazy;
use std::sync::Mutex;

uniffi::setup_scaffolding!();

// --- DATA TYPES ---

#[derive(uniffi::Record)]
pub struct FocusTask {
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

#[derive(Clone, Debug, PartialEq, uniffi::Enum)]
pub enum CoreEvent {
    TasksUpdated,
}

#[uniffi::export(callback_interface)]
pub trait EventObserver: Send + Sync {
    fn on_event(&self, event: CoreEvent);
}

// --- SINGLETONS ---

static DB: Lazy<Mutex<Option<database::Database>>> = Lazy::new(|| {
    Mutex::new(None)
});

static TIMER: Lazy<timer::TimerEngine> = Lazy::new(timer::TimerEngine::new);

static EVENT_OBSERVER: Lazy<Mutex<Option<Box<dyn EventObserver>>>> = Lazy::new(|| Mutex::new(None));

fn emit_tasks_updated() {
    if let Some(obs) = EVENT_OBSERVER.lock().unwrap().as_ref() {
        obs.on_event(CoreEvent::TasksUpdated);
    }
}

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
pub fn set_event_observer(observer: Box<dyn EventObserver>) {
    let mut obs = EVENT_OBSERVER.lock().unwrap();
    *obs = Some(observer);
}

#[uniffi::export]
pub fn create_task(title: String) -> FocusTask {
    let id = uuid::Uuid::new_v4().to_string();
    let timestamp = chrono::Utc::now().timestamp();
    let task = FocusTask {
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
    emit_tasks_updated();
    task
}

#[uniffi::export]
pub fn get_tasks() -> Vec<FocusTask> {
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
    emit_tasks_updated();
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
    emit_tasks_updated();
}

#[uniffi::export]
pub fn search_tasks(query: String) -> Vec<FocusTask> {
    let db_lock = DB.lock().unwrap();
    if let Some(db) = db_lock.as_ref() {
        db.search_tasks(&query).expect("Failed to search tasks")
    } else {
        panic!("Core not initialized. Call init_core() first.");
    }
}


#[uniffi::export]
pub fn generate_recurring_tasks() {
    let db_lock = DB.lock().unwrap();
    if let Some(db) = db_lock.as_ref() {
        db.generate_recurring_tasks().expect("Failed to generate recurring tasks");
    } else {
        panic!("Core not initialized. Call init_core() first.");
    }
    emit_tasks_updated();
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
