import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return ref.read(taskRepositoryProvider).getAllTasks();
  }

  Future<void> addTask(Task task) async {
    final previousState = state;
    // Explicitly create a new list instance to trigger rebuild
    state = AsyncData([...state.value ?? [], task]);
    
    try {
      await ref.read(taskRepositoryProvider).insertTask(task);
      // Optional: re-fetch to guarantee exact match, but optimistic is fine
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateTask(Task task) async {
    final previousState = state;
    if (state.value != null) {
      state = AsyncData([
        for (final t in state.value!)
          if (t.id == task.id) task else t,
      ]);
    }
    
    try {
      await ref.read(taskRepositoryProvider).updateTask(task);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> removeTask(String id) async {
    final previousState = state;
    if (state.value != null) {
      state = AsyncData([...state.value!.where((task) => task.id != id)]);
    }
    
    try {
      await ref.read(taskRepositoryProvider).deleteTask(id);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> updateProgress(String id, double progress) async {
    final previousState = state;
    Task? updatedTask;
    
    if (state.value != null) {
      state = AsyncData([
        for (final t in state.value!)
          if (t.id == id) 
            (updatedTask = t.copyWith(progress: progress))
          else 
            t,
      ]);
    }
    
    if (updatedTask != null) {
      try {
        await ref.read(taskRepositoryProvider).updateTask(updatedTask);
      } catch (e) {
        state = previousState;
      }
    }
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});
