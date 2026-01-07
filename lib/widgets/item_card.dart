import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/wish.dart';
import '../domain/wish_priority.dart';
import '../presentation/wish_priority_presentation.dart';

class ItemCard extends StatelessWidget {
  final Wish item;
  final double cardWidth;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.cardWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = item.aspectRatio.clamp(0.7, 1.8);
    final cardHeight = cardWidth * aspectRatio;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 画像
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              color: Colors.grey[300],
              child: item.imagePath.isNotEmpty
                  ? Image.file(
                      File(item.imagePath),
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.photo, size: 48, color: Colors.grey),
            ),
          ),

          // 優先度ラベル
          if (item.priority != WishPriority.none)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.priority.color.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.priority.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
