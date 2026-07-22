import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFilter {
  final String? selectedTag;
  final bool hideCompleted;

  const TaskFilter({
    this.selectedTag,
    this.hideCompleted = false,
  });

  TaskFilter copyWith({
    String? selectedTag,
    bool? hideCompleted,
    bool clearTag = false,
  }) {
    return TaskFilter(
      selectedTag: clearTag ? null : (selectedTag ?? this.selectedTag),
      hideCompleted: hideCompleted ?? this.hideCompleted,
    );
  }
}

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() {
    return const TaskFilter();
  }

  void setTag(String? tag) {
    if (tag == null) {
      state = state.copyWith(clearTag: true);
    } else {
      state = state.copyWith(selectedTag: tag);
    }
  }

  void toggleHideCompleted(bool value) {
    state = state.copyWith(hideCompleted: value);
  }

  void clearFilters() {
    state = const TaskFilter();
  }
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(() {
  return TaskFilterNotifier();
});
