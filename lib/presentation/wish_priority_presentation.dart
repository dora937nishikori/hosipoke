import 'package:flutter/material.dart';
import '../domain/wish_priority.dart';

extension WishPriorityPresentation on WishPriority {
  String get label {
    switch (this) {
      case WishPriority.now:
        return 'すぐほしい';
      case WishPriority.soon:
        return '次の機会に';
      case WishPriority.later:
        return '考えてから';
      case WishPriority.reward:
        return 'ごほうびに';
      case WishPriority.someday:
        return 'いつかの夢';
      case WishPriority.none:
        return 'なし';
    }
  }

  Color get color {
    switch (this) {
      case WishPriority.now:
        return const Color(0xFFFF5959); // red
      case WishPriority.soon:
        return const Color(0xFFFFB31F); // orange
      case WishPriority.later:
        return const Color(0xFF33BF61); // green
      case WishPriority.reward:
        return const Color(0xFF1FC7F2); // cyan
      case WishPriority.someday:
        return const Color(0xFF9470ED); // purple
      case WishPriority.none:
        return Colors.grey;
    }
  }
}

