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

  @override
  Widget build(BuildContext context) {
    final items = context.watch<PocketStore>().items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ポケット'),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 16.0;
          const columnSpacing = 16.0;
          const verticalSpacing = 16.0;
          const rightColumnTopOffset = 12.0;
          final cardWidth = (constraints.maxWidth - horizontalPadding * 2 - columnSpacing) / 2;

          final leftItems = <Wish>[];
          final rightItems = <Wish>[];

          for (int i = 0; i < items.length; i++) {
            if (i % 2 == 0) {
              leftItems.add(items[i]);
            } else {
              rightItems.add(items[i]);
            }
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 24,
                    bottom: 120,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: items.isEmpty
                              ? _buildPlaceholderColumn(
                                  [1.2, 1.0, 1.1, 0.9],
                                  cardWidth,
                                  0,
                                  verticalSpacing,
                                )
                              : leftItems
                                  .map((item) => ItemCard(
                                        item: item,
                                        cardWidth: cardWidth,
                                        onTap: () => onSelect(item),
                                      ))
                                  .toList(),
                        ),
                      ),
                      SizedBox(width: columnSpacing),
                      Expanded(
                        child: Column(
                          children: items.isEmpty
                              ? _buildPlaceholderColumn(
                                  [1.0, 1.1, 0.95, 1.05],
                                  cardWidth,
                                  rightColumnTopOffset,
                                  verticalSpacing,
                                )
                              : rightItems.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? rightColumnTopOffset : 0,
                                    ),
                                    child: ItemCard(
                                      item: item,
                                      cardWidth: cardWidth,
                                      onTap: () => onSelect(item),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 24,
                child: _buildAddButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPlaceholderColumn(
    List<double> ratios,
    double cardWidth,
    double topOffset,
    double spacing,
  ) {
    return ratios.asMap().entries.map((entry) {
      final index = entry.key;
      final ratio = entry.value;
      return Padding(
        padding: EdgeInsets.only(
          top: index == 0 ? topOffset : spacing,
        ),
        child: Container(
          width: cardWidth,
          height: cardWidth * ratio,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.yellow,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 22,
              color: Colors.black,
              weight: 700,
            ),
            const SizedBox(height: 4),
            Text(
              'あつめる',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

