import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../domain/repositories/wish_repository.dart';
import '../domain/wish.dart';
import '../domain/wish_priority.dart';

/// UI層からの依存を集約するViewModel。
/// Repositoryを介してデータを操作し、UIに通知する。
class PocketStore extends ChangeNotifier {
  PocketStore({required this.repository});

  final WishRepository repository;
  List<Wish> _items = [];
  bool _isInitialized = false;

  List<Wish> get items => List.unmodifiable(_items);
  bool get isInitialized => _isInitialized;

  /// 初期データを読み込む（一度だけ）
  Future<void> loadInitial() async {
    if (_isInitialized) return;
    _items = await repository.fetchAll();
    _isInitialized = true;
    notifyListeners();
  }

  /// 新しいアイテムを追加
  Future<void> add({
    required File imageFile,
    required String note,
    required WishPriority priority,
  }) async {
    final aspectRatio = await _computeAspectRatio(imageFile);
    final wish = Wish(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      note: note.trim(),
      createdAt: DateTime.now(),
      imagePath: imageFile.path,
      priority: priority,
      aspectRatio: aspectRatio,
    );

    await repository.save(wish);
    _items = await repository.fetchAll();
    notifyListeners();
  }

  /// 既存アイテムを更新
  Future<void> update({
    required String id,
    required String note,
    required WishPriority priority,
  }) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final updated = _items[index].copyWith(
      note: note.trim(),
      priority: priority,
    );

    await repository.update(updated);
    _items = await repository.fetchAll();
    notifyListeners();
  }

  /// 画像のアスペクト比を計算
  Future<double> _computeAspectRatio(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final ratio = image.height / image.width;
      return ratio.isFinite && ratio > 0 ? ratio : 1.2;
    } catch (_) {
      return 1.2;
    }
  }
}
