import 'package:flutter/material.dart';
import '../domain/wish_priority.dart';
import '../presentation/wish_priority_presentation.dart';

class PriorityPicker extends StatefulWidget {
  final WishPriority selected;
  final Function(WishPriority) onChanged;

  const PriorityPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<PriorityPicker> createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<PriorityPicker> {
  WishPriority? _sparkling;

  static const List<WishPriority> _options = [
    WishPriority.now,
    WishPriority.soon,
    WishPriority.later,
    WishPriority.reward,
    WishPriority.someday,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 16.0;
        const starSize = 28.0;
        final totalWidth = constraints.maxWidth - 2 * horizontalPadding;
        final slotWidth = totalWidth / _options.length;

        return SizedBox(
          height: 64,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: starSize / 2 - 2,
                    left: slotWidth / 2,
                    right: slotWidth / 2,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: _options.map((option) {
                      return SizedBox(
                        width: slotWidth,
                        child: Column(
                          children: [
                            _buildStarButton(option, starSize),
                            const SizedBox(height: 6),
                            Text(
                              option.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: option.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStarButton(WishPriority option, double starSize) {
    final isSelected = widget.selected == option;
    final isSparkling = _sparkling == option;

    return GestureDetector(
      onTap: () {
        widget.onChanged(option);
        setState(() {
          _sparkling = option;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _sparkling = null;
            });
          }
        });
      },
      child: SizedBox(
        width: starSize,
        height: starSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                Icons.star,
                size: starSize,
                color: option.color,
                weight: 700,
              ),
            ),
            if (isSparkling)
              AnimatedOpacity(
                opacity: isSparkling ? 0.9 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: isSparkling ? 1.2 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: option.color,
                      weight: 700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

