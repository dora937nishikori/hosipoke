import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/wish.dart';
import '../providers/pocket_store.dart';
import '../widgets/item_card.dart';

class PocketView extends StatelessWidget {
  final Function(Wish) onSelect;
  final VoidCallback onAdd;

  const PocketView({
    super.key,
    required this.onSelect,
    required this.onAdd,
  });

  static const double _horizontalPadding = 16.0;
  static const double _columnSpacing = 16.0;
  static const double _verticalSpacing = 16.0;
  static const double _rightColumnTopOffset = 12.0;

  @override
  Widget build(BuildContext context) {
    final items = context.watch<PocketStore>().items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ポケット'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: _AddButton(onTap: onAdd),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - _horizontalPadding * 2 - _columnSpacing) / 2;

          final leftItems = <Wish>[];
          final rightItems = <Wish>[];
          for (int i = 0; i < items.length; i++) {
            (i.isEven ? leftItems : rightItems).add(items[i]);
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: _horizontalPadding,
                  right: _horizontalPadding,
                  top: 24,
                  bottom: 120,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildColumn(
                        leftItems,
                        cardWidth,
                        topOffset: 0,
                      ),
                    ),
                    const SizedBox(width: _columnSpacing),
                    Expanded(
                      child: _buildColumn(
                        rightItems,
                        cardWidth,
                        topOffset: _rightColumnTopOffset,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumn(List<Wish> items, double cardWidth, {required double topOffset}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? topOffset : 0,
            bottom: isLast ? 0 : _verticalSpacing,
          ),
          child: ItemCard(
            key: ValueKey(item.id),
            item: item,
            cardWidth: cardWidth,
            onTap: () => onSelect(item),
          ),
        );
      }).toList(),
    );
  }

}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
        const SizedBox(height: 6),
        const Text(
          'あつめる',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
