import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Color accentColor;
  final VoidCallback onProgressTapped;

  const TaskCard({
    super.key,
    required this.task,
    required this.accentColor,
    required this.onProgressTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, task.description.isEmpty ? 'No context provided' : task.description),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.calendar_today_outlined, DateFormat('MMMM d, yyyy').format(task.deadline)),
          const SizedBox(height: 6),
          // We assume a 1 hour duration for mockup purposes if no end time exists
          _buildInfoRow(Icons.access_time, '${DateFormat('hh:mm').format(task.deadline)} - ${DateFormat('hh:mm a').format(task.deadline.add(const Duration(hours: 1)))}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
