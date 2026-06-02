import 'package:flutter/foundation.dart';
import 'package:lore_grading_app/models/task.dart';
import 'package:lore_grading_app/services/database_helper.dart';
import 'package:lore_grading_app/services/sync_manager.dart';

enum TaskFilter { all, pending, completed }

class TodoProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  TaskFilter _currentFilter = TaskFilter.all;

  List<Task> get allTasks => List.unmodifiable(_tasks);
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;

  // Load all tasks from local SQLite database
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await DatabaseHelper.instance.getTasks();
    } catch (e) {
      if (kDebugMode) print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  int get pendingCount => _tasks.where((task) => !task.isCompleted).length;

  // Add a task to SQLite, then sync in background
  Future<void> addTask(Task task, bool isOnline) async {
    // 1. Write locally (marked unsynced)
    await DatabaseHelper.instance.insertTask(task, isSynced: 0);
    await loadTasks();

    // 2. Sync in background
    SyncManager.instance.syncTasks(isOnline).then((_) => loadTasks());
  }

  // Toggle completion status in SQLite, then sync in background
  Future<void> toggleTaskStatus(String id, bool isOnline) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      task.isCompleted = !task.isCompleted;
      task.isSynced = false;

      // 1. Write update locally
      await DatabaseHelper.instance.updateTask(task, isSynced: 0);
      await loadTasks();

      // 2. Sync in background
      SyncManager.instance.syncTasks(isOnline).then((_) => loadTasks());
    }
  }

  // Soft delete in SQLite (so coordinator can sync delete to server), then sync in background
  Future<void> deleteTask(String id, bool isOnline) async {
    // 1. Mark as soft-deleted locally
    await DatabaseHelper.instance.deleteTaskSoft(id);
    await loadTasks();

    // 2. Sync in background
    SyncManager.instance.syncTasks(isOnline).then((_) => loadTasks());
  }

  // Update details in SQLite, then sync in background
  Future<void> updateTask(String id, String newTitle, String newDescription, DateTime newDueDate, bool isOnline) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final updatedTask = Task(
        id: id,
        title: newTitle,
        description: newDescription,
        dueDate: newDueDate,
        isCompleted: _tasks[index].isCompleted,
        isSynced: false,
      );

      // 1. Write locally
      await DatabaseHelper.instance.updateTask(updatedTask, isSynced: 0);
      await loadTasks();

      // 2. Sync in background
      SyncManager.instance.syncTasks(isOnline).then((_) => loadTasks());
    }
  }
}
