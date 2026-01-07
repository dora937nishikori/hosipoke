import 'package:flutter/material.dart';
import '../domain/wish_priority.dart';
import '../presentation/wish_priority_presentation.dart';

class PriorityPicker extends StatefulWidget {
  final WishPriority selected;
  final ValueChanged<WishPriority> onChanged;

  const PriorityPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<PriorityPicker> createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<PriorityPicker> {
  WishPriority? _sparklingOption;

  static const _options = [
    WishPriority.now,
    WishPriority.soon,
    WishPriority.later,
    WishPriority.reward,
    WishPriority.someday,
  ];

  static const _starSize = 28.0;

  void _onSelect(WishPriority option) {
    widget.onChanged(option);
    setState(() => _sparklingOption = option);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _sparklingOption = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = (constraints.maxWidth - 32) / _options.length;

        return SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 接続線
              Positioned(
                top: _starSize / 2 - 2,
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
              // オプション
              Row(
                children: _options.map((option) {
                  return SizedBox(
                    width: slotWidth,
                    child: Column(
                      children: [
                        _StarButton(
                          option: option,
                          isSelected: widget.selected == option,
                          isSparkling: _sparklingOption == option,
                          onTap: () => _onSelect(option),
                        ),
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
        );
      },
    );
  }
}

class _StarButton extends StatelessWidget {
  final WishPriority option;
  final bool isSelected;
  final bool isSparkling;
  final VoidCallback onTap;

  const _StarButton({
    required this.option,
    required this.isSelected,
    required this.isSparkling,
    required this.onTap,
  });

  static const _size = 28.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(Icons.star, size: _size, color: option.color),
            ),
            if (isSparkling)
              AnimatedOpacity(
                opacity: 0.9,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: 1.2,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Icon(Icons.auto_awesome, size: 20, color: option.color),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
