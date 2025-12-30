import 'wish_priority.dart';

class Wish {
  final String id;
  final String note;
  final DateTime createdAt;
  final String imagePath;
  final WishPriority priority;

  const Wish({
    required this.id,
    required this.note,
    required this.createdAt,
    required this.imagePath,
    required this.priority,
  });

  Wish copyWith({
    String? id,
    String? note,
    DateTime? createdAt,
    String? imagePath,
    WishPriority? priority,
  }) {
    return Wish(
      id: id ?? this.id,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      priority: priority ?? this.priority,
    );
  }
}

