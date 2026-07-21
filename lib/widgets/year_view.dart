import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'task_options_modal.dart';

class YearView extends ConsumerWidget {
  const YearView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskProvider);
    
    return asyncTasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading tasks: $err')),
      data: (tasks) {
        final yearTasks = tasks.where((t) => t.category == TaskCategory.year).toList();
        yearTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Yearly Objectives',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Expanded(
              child: yearTasks.isEmpty
                  ? const Center(child: Text('No yearly objectives yet.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: yearTasks.length,
                      itemBuilder: (context, index) {
                        final task = yearTasks[index];
                        return GestureDetector(
                          onLongPress: () => showTaskOptionsModal(context, ref, task),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.flag, color: Colors.orange),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Target: ${DateFormat('yyyy').format(task.deadline)}',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: task.progress == 1.0,
                                  onChanged: (val) {
                                    ref.read(taskProvider.notifier).updateProgress(task.id, val ? 1.0 : 0.0);
                                  },
                                  activeTrackColor: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                                  activeThumbColor: const Color(0xFF9C27B0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
