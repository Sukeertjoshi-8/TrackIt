import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_provider.dart';

class TagNotifier extends Notifier<List<String>> {
  final List<String> _defaultTags = ["Coding", "University", "PPL Workout", "Football", "Productivity"];

  @override
  List<String> build() {
    final asyncTasks = ref.watch(taskProvider);
    
    return asyncTasks.maybeWhen(
      data: (tasks) {
        final dbTags = tasks
            .map((t) => t.tag)
            .where((t) => t.isNotEmpty && t != 'Uncategorized')
            .toSet();
        return {..._defaultTags, ...dbTags}.toList()..sort();
      },
      orElse: () => _defaultTags,
    );
  }
}

final tagProvider = NotifierProvider<TagNotifier, List<String>>(() {
  return TagNotifier();
});
