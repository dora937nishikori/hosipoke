import 'wish_priority.dart';

class Wish {
  final String id;
  final String note;
  final DateTime createdAt;
  final String imagePath;
  final WishPriority priority;
  final double aspectRatio;

  const Wish({
    required this.id,
    required this.note,
    required this.createdAt,
    required this.imagePath,
    required this.priority,
    required this.aspectRatio,
  });

  Wish copyWith({
    String? id,
    String? note,
    DateTime? createdAt,
    String? imagePath,
    WishPriority? priority,
    double? aspectRatio,
  }) {
    return Wish(
      id: id ?? this.id,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      priority: priority ?? this.priority,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'priority': priority.index,
      'aspectRatio': aspectRatio,
    };
  }

  factory Wish.fromMap(Map<String, dynamic> map) {
    return Wish(
      id: map['id'] as String,
      note: map['note'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      imagePath: map['imagePath'] as String,
      priority: WishPriority.values[map['priority'] as int],
      aspectRatio: (map['aspectRatio'] as num).toDouble(),
    );
  }
}
