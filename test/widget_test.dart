import 'package:flutter_test/flutter_test.dart';
import 'package:peace_hosipoke/domain/repositories/wish_repository.dart';
import 'package:peace_hosipoke/domain/wish.dart';
import 'package:peace_hosipoke/domain/wish_priority.dart';
import 'package:peace_hosipoke/main.dart';
import 'package:peace_hosipoke/widgets/item_card.dart';

void main() {
  testWidgets('empty pocket message is shown', (tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: _FakeWishRepository(),
        openCameraOnEmpty: false,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('まだアイテムがありません'), findsOneWidget);
    expect(find.text('カメラで欲しいものを撮影しましょう'), findsOneWidget);
  });

  testWidgets('saved items are shown in the pocket list', (tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: _FakeWishRepository(
          initialItems: [
            Wish(
              id: 'wish-1',
              note: 'テストメモ',
              createdAt: DateTime(2026, 1, 2, 3, 4),
              imagePath: '',
              priority: WishPriority.now,
              aspectRatio: 1.2,
            ),
          ],
        ),
        openCameraOnEmpty: false,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ItemCard), findsOneWidget);
    expect(find.text('すぐほしい'), findsOneWidget);
  });
}

class _FakeWishRepository implements WishRepository {
  _FakeWishRepository({List<Wish> initialItems = const []})
      : _items = List.of(initialItems);

  final List<Wish> _items;

  @override
  Future<List<Wish>> fetchAll() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> save(Wish wish) async {
    _items.add(wish);
  }

  @override
  Future<void> update(Wish wish) async {
    final index = _items.indexWhere((item) => item.id == wish.id);
    if (index == -1) return;
    _items[index] = wish;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
