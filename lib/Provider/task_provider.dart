import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    _tasks = tasksJson.map((taskJson) => Task.fromJson(jsonDecode(taskJson))).toList();
    notifyListeners();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void addTask(Task task) {
    _tasks.add(task);
    saveTasks();
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      saveTasks();
      notifyListeners();
    }
  }
}
