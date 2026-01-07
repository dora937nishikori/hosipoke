import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/wish_priority.dart';
import '../widgets/priority_picker.dart';

class SaveItemView extends StatefulWidget {
  final File photo;
  final Function(String, WishPriority) onSave;
  final VoidCallback onClose;
  final VoidCallback onRetake;

  const SaveItemView({
    super.key,
    required this.photo,
    required this.onSave,
    required this.onClose,
    required this.onRetake,
  });

  @override
  State<SaveItemView> createState() => _SaveItemViewState();
}

class _SaveItemViewState extends State<SaveItemView> {
  final _memoController = TextEditingController();
  WishPriority _priority = WishPriority.none;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(_memoController.text, _priority);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アイテムを保存'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
        actions: [
          TextButton(
            onPressed: widget.onRetake,
            child: const Text('撮り直す'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 写真プレビュー
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.grey[300],
                child: Image.file(
                  widget.photo,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 優先度選択
            const Text(
              'いつほしい？',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            PriorityPicker(
              selected: _priority,
              onChanged: (priority) => setState(() => _priority = priority),
            ),
            const SizedBox(height: 12),

            // メモ入力
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                hintText: 'アイテムに関するメモを入力',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 12),

            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'アイテムを保存する',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
