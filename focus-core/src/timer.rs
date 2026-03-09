use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;
use chrono::Utc;

pub use crate::{TimerObserver, TimerState};

pub struct TimerEngine {
    state: Arc<Mutex<TimerState>>,
    remaining_seconds: Arc<Mutex<u32>>,
    expected_end_time: Arc<Mutex<Option<i64>>>,
    observer: Arc<Mutex<Option<Box<dyn TimerObserver>>>>,
}

impl TimerEngine {
    pub fn new() -> Self {
        Self {
            state: Arc::new(Mutex::new(TimerState::Idle)),
            remaining_seconds: Arc::new(Mutex::new(1500)), // 25 mins default
            expected_end_time: Arc::new(Mutex::new(None)),
            observer: Arc::new(Mutex::new(None)),
        }
    }

    pub fn set_observer(&self, observer: Box<dyn TimerObserver>) {
        let mut obs = self.observer.lock().unwrap();
        *obs = Some(observer);
    }

    pub fn start(&self, duration_seconds: u32) {
        let mut state = self.state.lock().unwrap();
        if *state == TimerState::Running {
            return;
        }

        *state = TimerState::Running;
        let mut remaining = self.remaining_seconds.lock().unwrap();
        *remaining = duration_seconds;
        
        let mut expected = self.expected_end_time.lock().unwrap();
        *expected = Some(Utc::now().timestamp() + duration_seconds as i64);

        // Notify observer
        if let Some(obs) = self.observer.lock().unwrap().as_ref() {
            obs.on_state_changed(TimerState::Running);
            obs.on_tick(*remaining);
        }

        self.spawn_timer_thread();
    }

    pub fn pause(&self) {
        let mut state = self.state.lock().unwrap();
        if *state == TimerState::Running {
            *state = TimerState::Paused;
            let mut expected = self.expected_end_time.lock().unwrap();
            *expected = None;
            if let Some(obs) = self.observer.lock().unwrap().as_ref() {
                obs.on_state_changed(TimerState::Paused);
            }
        }
    }

    pub fn resume(&self) {
        let mut state = self.state.lock().unwrap();
        if *state == TimerState::Paused {
            *state = TimerState::Running;
            let mut expected = self.expected_end_time.lock().unwrap();
            let remaining = self.remaining_seconds.lock().unwrap();
            *expected = Some(Utc::now().timestamp() + *remaining as i64);
            if let Some(obs) = self.observer.lock().unwrap().as_ref() {
                obs.on_state_changed(TimerState::Running);
            }
        }
    }

    pub fn stop(&self) {
        let mut state = self.state.lock().unwrap();
        *state = TimerState::Idle;
        let mut expected = self.expected_end_time.lock().unwrap();
        *expected = None;
        if let Some(obs) = self.observer.lock().unwrap().as_ref() {
            obs.on_state_changed(TimerState::Idle);
        }
    }

    fn spawn_timer_thread(&self) {
        let state_clone = Arc::clone(&self.state);
        let remaining_clone = Arc::clone(&self.remaining_seconds);
        let expected_clone = Arc::clone(&self.expected_end_time);
        let observer_clone = Arc::clone(&self.observer);

        thread::spawn(move || {
            loop {
                thread::sleep(Duration::from_secs(1));

                let mut state = state_clone.lock().unwrap();
                if *state == TimerState::Idle {
                    break;
                }

                if *state == TimerState::Running {
                    let expected_opt = *expected_clone.lock().unwrap();
                    if let Some(expected_time) = expected_opt {
                        let now = Utc::now().timestamp();
                        let remaining = expected_time - now;
                        
                        let mut remaining_lock = remaining_clone.lock().unwrap();
                        if remaining > 0 {
                            *remaining_lock = remaining as u32;
                            if let Some(obs) = observer_clone.lock().unwrap().as_ref() {
                                obs.on_tick(*remaining_lock);
                            }
                        } else {
                            *remaining_lock = 0;
                            *state = TimerState::Idle;
                            let mut expected_lock = expected_clone.lock().unwrap();
                            *expected_lock = None;
                            if let Some(obs) = observer_clone.lock().unwrap().as_ref() {
                                obs.on_state_changed(TimerState::Idle);
                            }
                            crate::emit_session_complete();
                            break;
                        }
                    }
                }
            }
        });
    }
}
