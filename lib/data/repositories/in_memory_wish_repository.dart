import 'package:collection/collection.dart';
import '../../domain/repositories/wish_repository.dart';
import '../../domain/wish.dart';

/// シンプルなインメモリ実装。
/// 今後、永続化（ローカルDBやクラウド）に差し替える場合でも
/// UI や ViewModel を変更せずに済むようリポジトリで抽象化。
class InMemoryWishRepository implements WishRepository {
  final List<Wish> _items = [];

  @override
  Future<List<Wish>> fetchAll() async {
    // 新しい順で返す
    return _items.sorted((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> save(Wish wish) async {
    _items.insert(0, wish);
  }

  @override
  Future<void> update(Wish wish) async {
    final index = _items.indexWhere((w) => w.id == wish.id);
    if (index == -1) return;
    _items[index] = wish;
  }
}

