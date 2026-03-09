#![allow(dead_code)]
use rusqlite::{Connection, Result, params};
use std::path::Path;
use std::sync::mpsc;
use std::thread;

enum DbCommand {
    CreateTask(String, String, i64, mpsc::Sender<Result<()>>),
    GetTasks(mpsc::Sender<Result<Vec<crate::Task>>>),
    UpdateTaskStatus(String, bool, i64, mpsc::Sender<Result<()>>),
    DeleteTask(String, mpsc::Sender<Result<()>>),
    SearchTasks(String, mpsc::Sender<Result<Vec<crate::Task>>>),
    GenerateRecurringTasks(mpsc::Sender<Result<()>>),
}

pub struct Database {
    tx: mpsc::Sender<DbCommand>,
}

impl Database {
    /// Opens a connection to a permanent SQLite database file.
    pub fn open<P: AsRef<Path>>(path: P) -> Result<Self> {
        let conn = Connection::open(path)?;
        Self::start_worker(conn)
    }

    /// Opens a connection to an in-memory SQLite database (for testing).
    pub fn open_in_memory() -> Result<Self> {
        let conn = Connection::open_in_memory()?;
        Self::start_worker(conn)
    }

    fn start_worker(conn: Connection) -> Result<Self> {
        Self::initialize_schema(&conn)?;

        let (tx, rx) = mpsc::channel::<DbCommand>();
        
        thread::spawn(move || {
            for cmd in rx {
                match cmd {
                    DbCommand::CreateTask(id, title, timestamp, resp) => {
                        let res = conn.execute(
                            "INSERT INTO tasks (id, title, created_at, updated_at) VALUES (?1, ?2, ?3, ?4)",
                            params![id, title, timestamp, timestamp],
                        ).map(|_| ());
                        let _ = resp.send(res);
                    }
                    DbCommand::GetTasks(resp) => {
                        let res = (|| -> Result<Vec<crate::Task>> {
                            let mut stmt = conn.prepare("SELECT id, title, is_completed FROM tasks ORDER BY created_at DESC")?;
                            let task_iter = stmt.query_map([], |row| {
                                Ok(crate::Task {
                                    id: row.get(0)?,
                                    title: row.get(1)?,
                                    is_completed: row.get(2)?,
                                })
                            })?;
                            let mut tasks = Vec::new();
                            for task in task_iter {
                                tasks.push(task?);
                            }
                            Ok(tasks)
                        })();
                        let _ = resp.send(res);
                    }
                    DbCommand::UpdateTaskStatus(id, completed, timestamp, resp) => {
                        let res = conn.execute(
                            "UPDATE tasks SET is_completed = ?1, updated_at = ?2 WHERE id = ?3",
                            params![completed, timestamp, id],
                        ).map(|_| ());
                        let _ = resp.send(res);
                    }
                    DbCommand::DeleteTask(id, resp) => {
                        let res = conn.execute(
                            "DELETE FROM tasks WHERE id = ?1",
                            params![id],
                        ).map(|_| ());
                        let _ = resp.send(res);
                    }
                    DbCommand::SearchTasks(query, resp) => {
                        let res = (|| -> Result<Vec<crate::Task>> {
                            let mut stmt = conn.prepare("SELECT t.id, t.title, t.is_completed FROM tasks t JOIN tasks_fts f ON t.id = f.id WHERE tasks_fts MATCH ?1 ORDER BY rank")?;
                            let task_iter = stmt.query_map(params![query], |row| {
                                Ok(crate::Task {
                                    id: row.get(0)?,
                                    title: row.get(1)?,
                                    is_completed: row.get(2)?,
                                })
                            })?;
                            let mut tasks = Vec::new();
                            for task in task_iter {
                                tasks.push(task?);
                            }
                            Ok(tasks)
                        })();
                        let _ = resp.send(res);
                    }
                    DbCommand::GenerateRecurringTasks(resp) => {
                        let res = (|| -> Result<()> {
                            let mut stmt = conn.prepare("SELECT task_id, rrule_string, last_generated_until FROM recurrence_rules")?;
                            let rules: Vec<(String, String, Option<i64>)> = stmt.query_map([], |r| {
                                Ok((r.get(0)?, r.get(1)?, r.get(2)?))
                            })?.filter_map(Result::ok).collect();
                            
                            let now_utc = chrono::Utc::now();
                            let horizon = now_utc + chrono::Duration::days(30);

                            for _rule in rules {
                                // Real rrule generation logic hooks here up to 30 days
                                // parsing rrule_string, checking against last_generated_until,
                                // formatting new Task instances.
                            }
                            Ok(())
                        })();
                        let _ = resp.send(res);
                    }
                }
            }
        });

        Ok(Self { tx })
    }

    fn initialize_schema(conn: &Connection) -> Result<()> {
        conn.execute_batch(
            "
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                parent_id TEXT,
                title TEXT NOT NULL,
                is_completed BOOLEAN DEFAULT 0,
                due_date INTEGER,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                sync_version INTEGER DEFAULT 0,
                FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
            );
            
            CREATE INDEX IF NOT EXISTS idx_tasks_parent ON tasks(parent_id);

            CREATE VIRTUAL TABLE IF NOT EXISTS tasks_fts USING fts5(
                id UNINDEXED,
                title,
                content='tasks',
                content_rowid='rowid'
            );

            CREATE TRIGGER IF NOT EXISTS tasks_ai AFTER INSERT ON tasks BEGIN
                INSERT INTO tasks_fts(rowid, id, title) VALUES (new.rowid, new.id, new.title);
            END;
            
            CREATE TRIGGER IF NOT EXISTS tasks_ad AFTER DELETE ON tasks BEGIN
                INSERT INTO tasks_fts(tasks_fts, rowid, id, title) VALUES('delete', old.rowid, old.id, old.title);
            END;
            
            CREATE TRIGGER IF NOT EXISTS tasks_au AFTER UPDATE ON tasks BEGIN
                INSERT INTO tasks_fts(tasks_fts, rowid, id, title) VALUES('delete', old.rowid, old.id, old.title);
                INSERT INTO tasks_fts(rowid, id, title) VALUES (new.rowid, new.id, new.title);
            END;

            CREATE TABLE IF NOT EXISTS app_settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS recurrence_rules (
                task_id TEXT PRIMARY KEY,
                rrule_string TEXT NOT NULL,
                last_generated_until INTEGER,
                FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
            );
            "
        )?;
        Ok(())
    }

    pub fn create_task(&self, id: &str, title: &str, timestamp: i64) -> Result<()> {
        let (tx, rx) = mpsc::channel();
        self.tx.send(DbCommand::CreateTask(id.to_string(), title.to_string(), timestamp, tx)).unwrap();
        rx.recv().unwrap()
    }

    pub fn get_tasks(&self) -> Result<Vec<crate::Task>> {
        let (tx, rx) = mpsc::channel();
        self.tx.send(DbCommand::GetTasks(tx)).unwrap();
        rx.recv().unwrap()
    }

    pub fn update_task_status(&self, id: &str, is_completed: bool, timestamp: i64) -> Result<()> {
        let (tx, rx) = mpsc::channel();
        self.tx.send(DbCommand::UpdateTaskStatus(id.to_string(), is_completed, timestamp, tx)).unwrap();
        rx.recv().unwrap()
    }

    pub fn delete_task(&self, id: &str) -> Result<()> {
        let (tx, rx) = mpsc::channel();
        self.tx.send(DbCommand::DeleteTask(id.to_string(), tx)).unwrap();
        rx.recv().unwrap()
    }
    
    pub fn search_tasks(&self, query: &str) -> Result<Vec<crate::Task>> {
        let (tx, rx) = mpsc::channel();
        self.tx.send(DbCommand::SearchTasks(query.to_string(), tx)).unwrap();
        rx.recv().unwrap()
    }

    pub fn generate_recurring_tasks(&self) -> Result<()> {
        let (tx, rx) = mpsc::channel();
        self.tx.send(DbCommand::GenerateRecurringTasks(tx)).unwrap();
        rx.recv().unwrap()
    }
}
