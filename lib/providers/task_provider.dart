import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    await _generateDailyHabitTasks();
    return ref.read(taskRepositoryProvider).getAllTasks();
  }

  Future<void> _generateDailyHabitTasks() async {
    final repo = ref.read(taskRepositoryProvider);
    final allTasks = await repo.getAllTasks();
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    for (final task in allTasks) {
      if (task.isParent && task.frequencyDays != null) {
        final days = task.frequencyDays!.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
        if (days.contains(currentWeekday)) {
          final hasChildToday = allTasks.any((t) =>
            t.parentId == task.id &&
            t.deadline.year == now.year &&
            t.deadline.month == now.month &&
            t.deadline.day == now.day
          );

          if (!hasChildToday) {
            final childTask = Task(
              id: const Uuid().v4(),
              title: task.title,
              description: task.description,
              category: TaskCategory.day,
              progress: 0.0,
              deadline: DateTime(now.year, now.month, now.day, 23, 59),
              requiresPhotoProof: task.requiresPhotoProof,
              tag: task.tag,
              isParent: false,
              parentId: task.id,
            );
            await repo.insertTask(childTask);
          }
        }
      }
    }
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
      if (task.parentId != null) {
        await _syncParentProgress(task.parentId!);
      }
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> removeTask(String id) async {
    final previousState = state;
    Task? deletedTask;
    
    if (state.value != null) {
      try {
        deletedTask = state.value!.firstWhere((task) => task.id == id);
        state = AsyncData([...state.value!.where((task) => task.id != id)]);
      } catch (_) {}
    }
    
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(id);
      
      // Skip Economy Check
      if (deletedTask != null && deletedTask.parentId != null) {
        final allTasks = await repo.getAllTasks();
        try {
          final parentTask = allTasks.firstWhere((t) => t.id == deletedTask!.parentId);
          final updatedParent = parentTask.copyWith(skippedSessions: parentTask.skippedSessions + 1);
          await repo.updateTask(updatedParent);
          state = AsyncData(await repo.getAllTasks());
        } catch (_) {}
      }
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
        if (updatedTask.parentId != null) {
          await _syncParentProgress(updatedTask.parentId!);
        }
      } catch (e) {
        state = previousState;
      }
    }
  }

  Future<void> _syncParentProgress(String parentId) async {
    final repo = ref.read(taskRepositoryProvider);
    final allTasks = await repo.getAllTasks();
    
    try {
      final parentTask = allTasks.firstWhere((t) => t.id == parentId);
      final children = allTasks.where((t) => t.parentId == parentId).toList();
      
      if (children.isEmpty) return;
      
      final completedChildren = children.where((t) => t.progress >= 1.0).length;
      final newProgress = completedChildren / children.length;
      
      final updatedParent = parentTask.copyWith(progress: newProgress);
      await repo.updateTask(updatedParent);
      
      state = AsyncData(await repo.getAllTasks());
    } catch (e) {
      // Parent not found, ignore
    }
  }
}

final taskProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});
