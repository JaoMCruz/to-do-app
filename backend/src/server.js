const express = require('express');
const cors = require('cors');

const app = express();


app.use(cors());
app.use(express.json());

let tasks = [];
let idCounter = 1;


app.get("/tasks", (req, res) => {
  const userId = req.query.userId;

  const userTasks = tasks.filter(task => task.userId === userId);

  res.json(userTasks);
});

app.post("/tasks", (req, res) => {
  const newTask = {
    id: idCounter++,
    title: req.body.title,
    description: req.body.description || "",
    status: req.body.status || "A Fazer",
    userId: req.body.userId,
    createdAt: new Date()
  };

  tasks.push(newTask);
  res.json(newTask);
});

app.delete("/tasks/:id",(req, res)=>{
  const id = parseInt(req.params.id);
  tasks = tasks.filter(task => task.id !== id);
  res.json({ message: "Task deletada" });
})

app.put("/tasks/:id", (req, res) => {
  const id = parseInt(req.params.id);

  const task = tasks.find(t => t.id === id);

  if (!task) {
    return res.status(404).json({ message: "Task não encontrada" });
  }

  if (req.body.title){
    task.title = req.body.title;
  }
  
  if (req.body.status){
    task.status = req.body.status;
  }
  
  res.json(task);
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});