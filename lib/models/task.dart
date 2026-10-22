import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final String? categoryId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'Moyenne',
    this.categoryId,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? categoryId,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'category_id': categoryId,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      priority: map['priority'] as String? ?? 'Moyenne',
      categoryId: map['category_id'] as String?,
      isCompleted: map['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
