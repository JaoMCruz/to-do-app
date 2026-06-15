import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = "https://to-do-app-r0z6.onrender.com";


  static Future<List<Task>> getTasks() async {
    final user = FirebaseAuth.instance.currentUser;

    final response = await http.get(
      Uri.parse("$baseUrl/tasks?userId=${user!.uid}"),
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Task.fromJson(e)).toList();
  }


  static Future<void> addTask(String title, String description) async {
    final user = FirebaseAuth.instance.currentUser;

    await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        
        "title": title,
        "description": description,
        "status": "A Fazer",
        "userId": user!.uid,
      }),
    );
  }

  static Future<void> deleteTask(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/tasks/$id"),
    );
  }


  static Future<void> updateTask(int id, String status) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "status": status,
      }),
    );
  }

  static Future<void> editTask(int id, String title) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
      }),
    );
  }
}