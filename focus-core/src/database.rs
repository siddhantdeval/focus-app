#![allow(dead_code)]
use rusqlite::{Connection, Result, params};
use std::path::Path;

pub struct Database {
    conn: Connection,
}

impl Database {
    /// Opens a connection to a permanent SQLite database file.
    pub fn open<P: AsRef<Path>>(path: P) -> Result<Self> {
        let conn = Connection::open(path)?;
        let db = Self { conn };
        db.initialize_schema()?;
        Ok(db)
    }

    /// Opens a connection to an in-memory SQLite database (for testing).
    pub fn open_in_memory() -> Result<Self> {
        let conn = Connection::open_in_memory()?;
        let db = Self { conn };
        db.initialize_schema()?;
        Ok(db)
    }

    fn initialize_schema(&self) -> Result<()> {
        self.conn.execute(
            "CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                parent_id TEXT,
                title TEXT NOT NULL,
                is_completed BOOLEAN DEFAULT 0,
                due_date INTEGER,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                sync_version INTEGER DEFAULT 0,
                FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
            )",
            [],
        )?;

        self.conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_tasks_parent ON tasks(parent_id)",
            [],
        )?;
        Ok(())
    }

    pub fn create_task(&self, id: &str, title: &str, timestamp: i64) -> Result<()> {
        self.conn.execute(
            "INSERT INTO tasks (id, title, created_at, updated_at) VALUES (?1, ?2, ?3, ?4)",
            params![id, title, timestamp, timestamp],
        )?;
        Ok(())
    }

    pub fn get_tasks(&self) -> Result<Vec<crate::Task>> {
        let mut stmt = self
            .conn
            .prepare("SELECT id, title, is_completed FROM tasks ORDER BY created_at DESC")?;
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
    }
}
