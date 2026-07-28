import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Color accentColor;
  final void Function(String?) onProgressTapped;

  const TaskCard({
    super.key,
    required this.task,
    required this.accentColor,
    required this.onProgressTapped,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isWaitingForCamera = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final accentColor = widget.accentColor;
    final timeRemaining = task.deadline.difference(DateTime.now());
    final isUrgent = timeRemaining.inMinutes > 0 && timeRemaining.inMinutes <= 60;
    final isCompleted = task.progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      child: GestureDetector(
        onTap: () {
          if (isCompleted && task.photoProofPath != null && task.photoProofPath!.isNotEmpty) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (isCompleted && task.completedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Completed at ${DateFormat('h:mm a').format(task.completedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isUrgent && !isCompleted)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'URGENT: < 1H',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (task.category != TaskCategory.day)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    '[${task.category.name.toUpperCase()}]',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.location_on_outlined, task.description.isEmpty ? 'No context provided' : task.description),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.calendar_today_outlined, DateFormat('MMMM d, yyyy').format(task.deadline)),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.access_time, '${DateFormat('hh:mm a').format(task.deadline)} - ${DateFormat('hh:mm a').format(task.deadline.add(const Duration(hours: 1)))}'),
                  ],
                ),
              ),
              if (task.photoProofPath != null && task.photoProofPath!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.photo_camera, color: Colors.green, size: 24),
                ),
              _isWaitingForCamera
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : GestureDetector(
                      onTap: () async {
                        String? finalPath;
                        if (task.requiresPhotoProof && task.progress < 1.0) {
                          setState(() { _isWaitingForCamera = true; });
                          try {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 30,
                                maxWidth: 800,
                                maxHeight: 800,
                            );
                            if (image == null) return;

                            final directory = await getApplicationDocumentsDirectory();
                            final proofsDir = await Directory('${directory.path}/task_proofs').create(recursive: true);
                            final String fileName = 'proof_${task.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                            finalPath = '${proofsDir.path}/$fileName';
                            await image.saveTo(finalPath);
                          } finally {
                            if (mounted) {
                              setState(() { _isWaitingForCamera = false; });
                            }
                          }
                        }
                        widget.onProgressTapped(finalPath);
                        if (task.progress < 1.0) {
                          await NotificationService().flutterLocalNotificationsPlugin.cancel(id: task.id.hashCode);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? accentColor : Colors.transparent,
                          border: Border.all(
                            color: isCompleted ? accentColor : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 20, color: Colors.white)
                            : null,
                      ),
                    ),
            ],
          ),
        ],
        ),
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
