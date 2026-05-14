import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/task.dart';
import 'login_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> todo = [];
  List<Task> doing = [];
  List<Task> done = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    final data = await ApiService.getTasks();

    setState(() {
      todo = data.where((t) => t.status == 'A Fazer').toList();
      doing = data.where((t) => t.status == 'Em Progresso').toList();
      done = data.where((t) => t.status == 'Concluído').toList();
    });
  }

  void addTask() async {
    if (titleController.text.isEmpty) return;

    await ApiService.addTask(
      titleController.text,
      descController.text,
    );

    titleController.clear();
    descController.clear();
    loadTasks();
  }

  void deleteTask(int id) async {
    await ApiService.deleteTask(id);
    loadTasks();
  }

  void editTask(Task task) {
    final titleEdit = TextEditingController(text: task.title);
    final descEdit = TextEditingController(text: task.description ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar tarefa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleEdit),
              const SizedBox(height: 10),
              TextField(controller: descEdit),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.editTask(task.id, titleEdit.text);
                Navigator.pop(context);
                loadTasks();
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void toggleTask(Task task) async {
    String newStatus;

    if (task.status == "A Fazer") {
      newStatus = "Em Progresso";
    } else if (task.status == "Em Progresso") {
      newStatus = "Concluído";
    } else {
      newStatus = "A Fazer";
    }

    await ApiService.updateTask(task.id, newStatus);
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.65;

    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do Kanban"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Título",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "Descrição",
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTask,
              child: const Text("Adicionar"),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 280,
                      height: height,
                      child: buildColumn("A Fazer", todo, Colors.blue),
                    ),
                    SizedBox(
                      width: 280,
                      height: height,
                      child: buildColumn("Em Progresso", doing, Colors.orange),
                    ),
                    SizedBox(
                      width: 280,
                      height: height,
                      child: buildColumn("Concluído", done, Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColumn(String title, List<Task> tasks, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "$title (${tasks.length})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("Sem tarefas"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: task.status == "Concluído"
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                task.description ?? "Sem descrição",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  decoration: task.status == "Concluído"
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => toggleTask(task),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: task.status == "Concluído"
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        task.status,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () => editTask(task),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18),
                                        onPressed: () => deleteTask(task.id),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}