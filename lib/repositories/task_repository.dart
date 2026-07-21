import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../src/core/local_storage/database_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dbService = DatabaseService();
  return TaskRepository(dbService);
});

class TaskRepository {
  final DatabaseService _databaseService;

  TaskRepository(this._databaseService);

  Future<void> insertTask(Task task) async {
    await _databaseService.insertTask(task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final maps = await _databaseService.getAllTasks();
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> updateTask(Task task) async {
    await _databaseService.updateTask(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _databaseService.deleteTask(id);
  }
}
