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

  static const _starSize = 40.0; // 星サイズ
  static const _labelFontSize = 11.0;
  static const _horizontalPadding = 1.0; // 左右余白のみ

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
        final usableWidth = constraints.maxWidth - _horizontalPadding * 2;
        final slotWidth =
            _options.isNotEmpty ? usableWidth / _options.length : 0.0;

        return SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 破線（点線）
              // Positioned.fill(
              //   child: CustomPaint(
              //     painter: _PickerBackgroundPainter(
              //       centers: positions,
              //       gap: gap.toDouble(),
              //       y: lineY,
              //       color: Colors.grey.withOpacity(0.45),
              //     ),
              //   ),
              // ),
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
                        const SizedBox(height: 4),
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: _labelFontSize,
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

  @override
  Widget build(BuildContext context) {
    const size = _PriorityPickerState._starSize;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(Icons.star_rounded, size: size, color: option.color),
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
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: option.color,
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
