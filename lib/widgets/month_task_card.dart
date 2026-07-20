import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class MonthTaskCard extends ConsumerWidget {
  final Task task;

  const MonthTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(5, 5),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 15,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM yyyy').format(task.deadline),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple.shade300,
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 20),
          LinearPercentIndicator(
            lineHeight: 12.0,
            percent: task.progress,
            barRadius: const Radius.circular(6),
            progressColor: const Color(0xFF9C27B0),
            backgroundColor: Colors.grey.shade300,
            animation: true,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(task.progress * 100).toInt()}% Completed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newProgress = task.progress == 1.0 ? 0.0 : 1.0;
                  ref.read(taskProvider.notifier).updateProgress(task.id, newProgress);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.progress == 1.0 ? Colors.green : const Color(0xFF9C27B0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  task.progress == 1.0 ? 'Done' : 'Update',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
