import 'package:flutter_test/flutter_test.dart';
import 'package:peace_hosipoke/domain/wish.dart';
import 'package:peace_hosipoke/domain/wish_priority.dart';

void main() {
  group('Wish', () {
    test('converts to and from map', () {
      final wish = Wish(
        id: 'wish-1',
        note: '新しいスニーカー',
        createdAt: DateTime(2026, 1, 2, 3, 4, 5),
        imagePath: '/tmp/wish.jpg',
        priority: WishPriority.soon,
        aspectRatio: 1.25,
      );

      final restored = Wish.fromMap(wish.toMap());

      expect(restored.id, wish.id);
      expect(restored.note, wish.note);
      expect(restored.createdAt, wish.createdAt);
      expect(restored.imagePath, wish.imagePath);
      expect(restored.priority, wish.priority);
      expect(restored.aspectRatio, wish.aspectRatio);
    });

    test('copyWith updates only specified fields', () {
      final wish = Wish(
        id: 'wish-1',
        note: 'before',
        createdAt: DateTime(2026),
        imagePath: '/tmp/wish.jpg',
        priority: WishPriority.later,
        aspectRatio: 1.1,
      );

      final updated = wish.copyWith(
        note: 'after',
        priority: WishPriority.reward,
      );

      expect(updated.id, wish.id);
      expect(updated.note, 'after');
      expect(updated.createdAt, wish.createdAt);
      expect(updated.imagePath, wish.imagePath);
      expect(updated.priority, WishPriority.reward);
      expect(updated.aspectRatio, wish.aspectRatio);
    });
  });
}
