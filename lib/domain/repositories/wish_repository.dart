import '../wish.dart';

abstract class WishRepository {
  Future<List<Wish>> fetchAll();
  Future<void> save(Wish wish);
  Future<void> update(Wish wish);
  Future<void> delete(String id);
}
