import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/repositories/wish_repository.dart';
import '../domain/wish.dart';
import '../domain/wish_priority.dart';

/// UI層（Widget）からの依存を集約する ViewModel。
/// Repository を介してデータを操作し、UI に通知する。
class PocketStore extends ChangeNotifier {
  PocketStore({required this.repository});

  final WishRepository repository;
  List<Wish> _items = [];
  bool _isInitialized = false;

  List<Wish> get items => List.unmodifiable(_items);
  bool get isInitialized => _isInitialized;

  Future<void> loadInitial() async {
    if (_isInitialized) return;
    _items = await repository.fetchAll();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> add({
    required File imageFile,
    required String note,
    required WishPriority priority,
  }) async {
    final trimmed = note.trim();
    final wish = Wish(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      note: trimmed.isEmpty ? '' : trimmed,
      createdAt: DateTime.now(),
      imagePath: imageFile.path,
      priority: priority,
    );
    await repository.save(wish);
    _items = await repository.fetchAll();
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required WishPriority priority,
  }) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final trimmed = note.trim();
    final updated = _items[index].copyWith(
      note: trimmed.isEmpty ? '' : trimmed,
      priority: priority,
    );
    await repository.update(updated);
    _items = await repository.fetchAll();
    notifyListeners();
  }
}

