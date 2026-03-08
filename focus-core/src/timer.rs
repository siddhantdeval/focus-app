use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

pub use crate::{TimerObserver, TimerState};

pub struct TimerEngine {
    state: Arc<Mutex<TimerState>>,
    remaining_seconds: Arc<Mutex<u32>>,
    observer: Arc<Mutex<Option<Box<dyn TimerObserver>>>>,
}

impl TimerEngine {
    pub fn new() -> Self {
        Self {
            state: Arc::new(Mutex::new(TimerState::Idle)),
            remaining_seconds: Arc::new(Mutex::new(1500)), // 25 mins default
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
            if let Some(obs) = self.observer.lock().unwrap().as_ref() {
                obs.on_state_changed(TimerState::Paused);
            }
        }
    }

    pub fn resume(&self) {
        let mut state = self.state.lock().unwrap();
        if *state == TimerState::Paused {
            *state = TimerState::Running;
            if let Some(obs) = self.observer.lock().unwrap().as_ref() {
                obs.on_state_changed(TimerState::Running);
            }
        }
    }

    pub fn stop(&self) {
        let mut state = self.state.lock().unwrap();
        *state = TimerState::Idle;
        if let Some(obs) = self.observer.lock().unwrap().as_ref() {
            obs.on_state_changed(TimerState::Idle);
        }
    }

    fn spawn_timer_thread(&self) {
        let state_clone = Arc::clone(&self.state);
        let remaining_clone = Arc::clone(&self.remaining_seconds);
        let observer_clone = Arc::clone(&self.observer);

        thread::spawn(move || {
            loop {
                thread::sleep(Duration::from_secs(1));

                let mut state = state_clone.lock().unwrap();
                if *state == TimerState::Idle {
                    break;
                }

                if *state == TimerState::Running {
                    let mut remaining = remaining_clone.lock().unwrap();
                    if *remaining > 0 {
                        *remaining -= 1;
                        if let Some(obs) = observer_clone.lock().unwrap().as_ref() {
                            obs.on_tick(*remaining);
                        }
                    } else {
                        *state = TimerState::Idle;
                        if let Some(obs) = observer_clone.lock().unwrap().as_ref() {
                            obs.on_state_changed(TimerState::Idle);
                        }
                        break;
                    }
                }
            }
        });
    }
}
