import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/wish.dart';
import '../domain/wish_priority.dart';
import '../widgets/priority_picker.dart';

class ItemDetailView extends StatefulWidget {
  final Wish item;
  final Function(String, WishPriority) onSave;
  final VoidCallback onClose;

  const ItemDetailView({
    super.key,
    required this.item,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  late String _memo;
  late WishPriority _priority;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memo = widget.item.note;
    _priority = widget.item.priority;
    _memoController = TextEditingController(text: _memo);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年M月d日 HH:mm', 'ja_JP');
    final formattedDate = dateFormat.format(widget.item.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('アイテム詳細'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onClose();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  color: Colors.grey[300],
                  child: widget.item.imagePath.isNotEmpty
                      ? Image.file(
                          File(widget.item.imagePath),
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                      : const Icon(
                          Icons.photo,
                          size: 100,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'いつほしい？',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PriorityPicker(
                        selected: _priority,
                        onChanged: (priority) {
                          setState(() {
                            _priority = priority;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'メモ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'アイテムに関するメモを入力',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        maxLines: null,
                        controller: _memoController,
                        onChanged: (value) {
                          setState(() {
                            _memo = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_memo, _priority);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '更新する',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

