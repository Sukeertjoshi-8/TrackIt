import 'dart:io';
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
    final int totalTasks = tasks.length;
    final int completedTasksCount = tasks.where((t) => t.progress >= 1.0).length;
    final double percentage = totalTasks == 0 ? 0.0 : (completedTasksCount / totalTasks);

    // Only show completed tasks
    final completedTasks = tasks.where((t) => t.progress >= 1.0).toList();
    completedTasks.sort((a, b) => b.deadline.compareTo(a.deadline));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$tag History'),
            const SizedBox(height: 2),
            Text(
              '${(percentage * 100).toInt()}% completed',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 6,
          ),
        ),
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
                bool hasPhoto = task.photoProofPath != null && task.photoProofPath!.isNotEmpty;

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
                    task.completedAt != null
                        ? 'Completed on ${DateFormat('MMM d, yyyy • h:mm a').format(task.completedAt!)}'
                        : 'Completed on ${DateFormat('MMM d, yyyy').format(task.deadline)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing: hasPhoto ? const Icon(Icons.photo_camera, color: Colors.green) : null,
                  onTap: () {
                    if (hasPhoto) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Proof of Work', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(task.photoProofPath!)),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
