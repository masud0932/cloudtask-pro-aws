import React, { useEffect, useState } from "react";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:3000";

export default function App() {
  const [dashboard, setDashboard] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [projects, setProjects] = useState([]);
  const [form, setForm] = useState({
    title: "",
    description: "",
    status: "todo",
    priority: "medium",
    project_id: ""
  });

  async function fetchDashboard() {
    const response = await fetch(`${API_BASE_URL}/api/dashboard`);
    const data = await response.json();
    setDashboard(data);
  }

  async function fetchTasks() {
    const response = await fetch(`${API_BASE_URL}/api/tasks`);
    const data = await response.json();
    setTasks(data);
  }

  async function fetchProjects() {
    const response = await fetch(`${API_BASE_URL}/api/projects`);
    const data = await response.json();
    setProjects(data);
  }

  async function createTask(e) {
    e.preventDefault();

    const response = await fetch(`${API_BASE_URL}/api/tasks`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        ...form,
        project_id: form.project_id ? Number(form.project_id) : null
      })
    });

    if (response.ok) {
      setForm({
        title: "",
        description: "",
        status: "todo",
        priority: "medium",
        project_id: ""
      });
      await fetchTasks();
      await fetchDashboard();
    }
  }

  useEffect(() => {
    fetchDashboard();
    fetchTasks();
    fetchProjects();
  }, []);

  return (
    <div className="container">
      <header className="hero">
        <div>
          <h1>CloudTask Pro</h1>
          <p>Production-style AWS task management dashboard</p>
        </div>
      </header>

      {dashboard && (
        <section className="stats">
          <div className="card">
            <h3>Total Tasks</h3>
            <p>{dashboard.tasks.total}</p>
          </div>
          <div className="card">
            <h3>To Do</h3>
            <p>{dashboard.tasks.todo}</p>
          </div>
          <div className="card">
            <h3>In Progress</h3>
            <p>{dashboard.tasks.in_progress}</p>
          </div>
          <div className="card">
            <h3>Done</h3>
            <p>{dashboard.tasks.done}</p>
          </div>
          <div className="card">
            <h3>Projects</h3>
            <p>{dashboard.projects.total}</p>
          </div>
        </section>
      )}

      <section className="grid">
        <div className="panel">
          <h2>Create Task</h2>
          <form onSubmit={createTask} className="form">
            <input
              type="text"
              placeholder="Task title"
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              required
            />

            <textarea
              placeholder="Description"
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
            />

            <select
              value={form.status}
              onChange={(e) => setForm({ ...form, status: e.target.value })}
            >
              <option value="todo">To Do</option>
              <option value="in-progress">In Progress</option>
              <option value="done">Done</option>
            </select>

            <select
              value={form.priority}
              onChange={(e) => setForm({ ...form, priority: e.target.value })}
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>

            <select
              value={form.project_id}
              onChange={(e) => setForm({ ...form, project_id: e.target.value })}
            >
              <option value="">Select project</option>
              {projects.map((project) => (
                <option key={project.id} value={project.id}>
                  {project.name}
                </option>
              ))}
            </select>

            <button type="submit">Create Task</button>
          </form>
        </div>

        <div className="panel">
          <h2>Tasks</h2>
          <div className="task-list">
            {tasks.map((task) => (
              <div className="task-card" key={task.id}>
                <h3>{task.title}</h3>
                <p>{task.description || "No description"}</p>
                <div className="meta">
                  <span>Status: {task.status}</span>
                  <span>Priority: {task.priority}</span>
                </div>
                <div className="meta">
                  <span>Project: {task.project_name || "Unassigned"}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
