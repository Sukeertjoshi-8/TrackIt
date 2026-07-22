import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/task_filter_provider.dart';
import 'month_task_card.dart';
import 'task_options_modal.dart';

class MonthView extends ConsumerWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskProvider);
    
    return asyncTasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading tasks: $err')),
      data: (tasks) {
        final filter = ref.watch(taskFilterProvider);
        
        // Apply global filters first
        var filteredTasks = tasks;
        if (filter.hideCompleted) {
          filteredTasks = filteredTasks.where((t) => t.progress < 1.0).toList();
        }
        if (filter.selectedTag != null) {
          filteredTasks = filteredTasks.where((t) => t.tag == filter.selectedTag).toList();
        }

        final monthTasks = filteredTasks.where((t) => t.category == TaskCategory.month).toList();
        monthTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Monthly Goals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Expanded(
              child: monthTasks.isEmpty
                  ? const Center(child: Text('No monthly goals yet.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: monthTasks.length,
                      itemBuilder: (context, index) {
                        final task = monthTasks[index];
                        return GestureDetector(
                          onLongPress: () => showTaskOptionsModal(context, ref, task),
                          child: MonthTaskCard(task: task),
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
