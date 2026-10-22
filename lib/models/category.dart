import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final int color;

  Category({
    String? id,
    required this.userId,
    required this.name,
    this.color = 0xFF3F51B5,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      color: map['color'] as int? ?? 0xFF3F51B5,
    );
  }
}
