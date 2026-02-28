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
  final VoidCallback onDelete;

  const ItemDetailView({
    super.key,
    required this.item,
    required this.onSave,
    required this.onClose,
    required this.onDelete,
  });

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  late final TextEditingController _memoController;
  late WishPriority _priority;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.item.note);
    _priority = widget.item.priority;
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(_memoController.text, _priority);
    Navigator.of(context).pop();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除しますか？'),
        content: const Text('このアイテムを削除すると元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
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
          onPressed: widget.onClose,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 写真プレビュー（写真全体を表示）
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: widget.item.imagePath.isNotEmpty
                  ? Image.file(
                      File(widget.item.imagePath),
                      fit: BoxFit.contain,
                      width: double.infinity,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.photo, size: 100, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // 優先度選択
            const SizedBox(height: 12),
            PriorityPicker(
              selected: _priority,
              onChanged: (priority) => setState(() => _priority = priority),
            ),
            const SizedBox(height: 16),

            // メモ入力（保存画面と同じスタイル）
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _memoController,
                decoration: const InputDecoration(
                  hintText: 'メモ',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 12),

            // 更新ボタン
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
                  '更新する',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 削除ボタン
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _confirmDelete(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('削除する'),
              ),
            ),
            const SizedBox(height: 8),

            // 作成日時
            Center(
              child: Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
