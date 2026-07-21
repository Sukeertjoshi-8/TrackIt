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
  final String tag;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.progress,
    required this.deadline,
    required this.requiresProof,
    this.proofImagePath,
    this.tag = 'Uncategorized',
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
    String? tag,
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
      tag: tag ?? this.tag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'progress': progress,
      'deadline': deadline.toIso8601String(),
      'requiresProof': requiresProof ? 1 : 0,
      'proofImagePath': proofImagePath,
      'tag': tag,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'] as String,
        orElse: () => TaskCategory.day,
      ),
      progress: (map['progress'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      requiresProof: (map['requiresProof'] as int) == 1,
      proofImagePath: map['proofImagePath'] as String?,
      tag: (map['tag'] as String?) ?? 'Uncategorized',
    );
  }
}
