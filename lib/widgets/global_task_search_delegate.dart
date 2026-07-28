import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';

class GlobalTaskSearchDelegate extends SearchDelegate<Task?> {
  final WidgetRef ref;

  GlobalTaskSearchDelegate(this.ref) : super(searchFieldLabel: 'Search tasks...');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final tasksAsync = ref.watch(taskProvider);

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (tasks) {
        if (query.isEmpty) {
          return const Center(child: Text('Type to search...'));
        }

        final filteredTasks = tasks.where((task) {
          final titleLower = task.title.toLowerCase();
          final descLower = task.description.toLowerCase();
          final queryLower = query.toLowerCase();
          return titleLower.contains(queryLower) || descLower.contains(queryLower);
        }).toList();

        if (filteredTasks.isEmpty) {
          return const Center(child: Text('No matching tasks found.'));
        }

        // Group by category
        final groupedTasks = <TaskCategory, List<Task>>{};
        for (final task in filteredTasks) {
          groupedTasks.putIfAbsent(task.category, () => []).add(task);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: groupedTasks.keys.length,
          itemBuilder: (context, index) {
            final category = groupedTasks.keys.elementAt(index);
            final categoryTasks = groupedTasks[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                ...categoryTasks.map((task) {
                  return TaskCard(
                    task: task,
                    accentColor: const Color(0xFF9C27B0), // Generic accent color for search
                    onProgressTapped: (photoPath) {
                      final newProgress = task.progress >= 1.0 ? 0.0 : 1.0;
                      if (photoPath != null) {
                        final updatedTask = task.copyWith(
                          progress: newProgress,
                          photoProofPath: photoPath,
                          completedAt: newProgress == 1.0 ? DateTime.now() : null,
                          clearCompletedAt: newProgress < 1.0,
                        );
                        ref.read(taskProvider.notifier).updateTask(updatedTask);
                      } else {
                        ref.read(taskProvider.notifier).updateProgress(task.id, newProgress);
                      }
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}
