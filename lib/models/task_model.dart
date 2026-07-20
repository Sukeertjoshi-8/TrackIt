enum TaskCategory {
  day,
  month,
  year,
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final double progress; // 0.0 to 1.0
  final DateTime deadline;
  final bool requiresProof;
  final String? proofImagePath;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.progress,
    required this.deadline,
    required this.requiresProof,
    this.proofImagePath,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    double? progress,
    DateTime? deadline,
    bool? requiresProof,
    String? proofImagePath,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      deadline: deadline ?? this.deadline,
      requiresProof: requiresProof ?? this.requiresProof,
      proofImagePath: proofImagePath ?? this.proofImagePath,
    );
  }
}
