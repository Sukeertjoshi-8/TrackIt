import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';

class TaskNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return [];
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void updateProgress(String id, double progress) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(progress: progress) else t,
    ];
  }
}

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(() {
  return TaskNotifier();
});
