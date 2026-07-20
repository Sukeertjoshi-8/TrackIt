import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'month_task_card.dart';

class MonthView extends ConsumerWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final monthTasks = tasks.where((t) => t.category == TaskCategory.month).toList();
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
                    return MonthTaskCard(task: monthTasks[index]);
                  },
                ),
        ),
      ],
    );
  }
}
