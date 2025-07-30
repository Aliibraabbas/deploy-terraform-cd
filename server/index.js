import express from "express";
import cors from "cors";
import { TodoManager } from "./todoManager.js";

const app = express();
app.use(cors());
app.use(express.json());

const todoManager = new TodoManager();

// GET tous les todos
app.get("/todos", async (req, res) => {
  try {
    const todos = await todoManager.getAll();
    res.json(todos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET un todo par ID
app.get("/todos/:id", async (req, res) => {
  try {
    const todo = await todoManager.getById(req.params.id);
    if (!todo) return res.status(404).json({ error: "Todo non trouvé" });
    res.json(todo);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST créer un todo
app.post("/todos", async (req, res) => {
  try {
    const { text } = req.body;
    if (!text || text.trim() === "") {
      return res.status(400).json({ error: "Texte requis" });
    }
    const todo = await todoManager.create(text);
    res.status(201).json(todo);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT modifier un todo
app.put("/todos/:id", async (req, res) => {
  try {
    const updated = await todoManager.update(req.params.id, req.body);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE un todo
app.delete("/todos/:id", async (req, res) => {
  try {
    const deleted = await todoManager.delete(req.params.id);
    res.json(deleted);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lancer le serveur
app.listen(3005, () => {
  console.log("🚀 API Todo en local sur http://localhost:3005");
});
