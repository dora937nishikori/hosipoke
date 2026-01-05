import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../domain/wish.dart';
import '../domain/wish_priority.dart';
import '../presentation/wish_priority_presentation.dart';

class ItemCard extends StatefulWidget {
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
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _aspectRatio = widget.item.aspectRatio;
  }

  @override
  void didUpdateWidget(covariant ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.imagePath != widget.item.imagePath) {
      _aspectRatio = widget.item.aspectRatio;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _aspectRatio ?? 1.2;
    final clampedAspectRatio = aspectRatio.clamp(0.7, 1.8);

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: widget.cardWidth,
              height: widget.cardWidth * clampedAspectRatio,
              color: Colors.grey[300],
              child: widget.item.imagePath.isNotEmpty
                  ? Image.file(
                      File(widget.item.imagePath),
                      width: widget.cardWidth,
                      height: widget.cardWidth * clampedAspectRatio,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.photo,
                      size: 48,
                      color: Colors.grey,
                    ),
            ),
          ),
          if (widget.item.priority != WishPriority.none)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.item.priority.color.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.item.priority.label,
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

