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
  final bool requiresPhotoProof;
  final String? photoProofPath;
  final String tag;
  final bool isParent;
  final String? parentId;
  final String? frequencyDays;
  final int skippedSessions;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.progress,
    required this.deadline,
    required this.requiresPhotoProof,
    this.photoProofPath,
    this.tag = 'Uncategorized',
    this.isParent = false,
    this.parentId,
    this.frequencyDays,
    this.skippedSessions = 0,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    double? progress,
    DateTime? deadline,
    bool? requiresPhotoProof,
    String? photoProofPath,
    String? tag,
    bool? isParent,
    String? parentId,
    String? frequencyDays,
    int? skippedSessions,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      deadline: deadline ?? this.deadline,
      requiresPhotoProof: requiresPhotoProof ?? this.requiresPhotoProof,
      photoProofPath: photoProofPath ?? this.photoProofPath,
      tag: tag ?? this.tag,
      isParent: isParent ?? this.isParent,
      parentId: parentId ?? this.parentId,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      skippedSessions: skippedSessions ?? this.skippedSessions,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
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
      'requires_photo_proof': requiresPhotoProof ? 1 : 0,
      'photoProofPath': photoProofPath,
      'tag': tag,
      'is_parent': isParent ? 1 : 0,
      'parent_id': parentId,
      'frequency_days': frequencyDays,
      'skipped_sessions': skippedSessions,
      'completed_at': completedAt?.toIso8601String(),
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
      // Fallback for older db records before migration completes if ever accessed
      requiresPhotoProof: ((map['requires_photo_proof'] ?? map['requiresProof']) as int?) == 1,
      photoProofPath: map['photoProofPath'] as String?,
      tag: (map['tag'] as String?) ?? 'Uncategorized',
      isParent: (map['is_parent'] as int?) == 1,
      parentId: map['parent_id'] as String?,
      frequencyDays: map['frequency_days'] as String?,
      skippedSessions: (map['skipped_sessions'] as int?) ?? 0,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
    );
  }
}
