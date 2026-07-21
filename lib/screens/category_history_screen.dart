import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class CategoryHistoryScreen extends StatelessWidget {
  final String tag;
  final List<Task> tasks;

  const CategoryHistoryScreen({
    super.key,
    required this.tag,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    // Only show completed tasks
    final completedTasks = tasks.where((t) => t.progress >= 1.0).toList();
    completedTasks.sort((a, b) => b.deadline.compareTo(a.deadline));

    return Scaffold(
      appBar: AppBar(
        title: Text('$tag History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: completedTasks.isEmpty
          ? const Center(
              child: Text(
                'No completed tasks for this tag yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: completedTasks.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.green),
                  ),
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Completed on ${DateFormat('MMM d, yyyy').format(task.deadline)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                );
              },
            ),
    );
  }
}
