import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CameraPickerView extends StatefulWidget {
  final Function(File) onImagePicked;
  final VoidCallback onCancel;

  const CameraPickerView({
    super.key,
    required this.onImagePicked,
    required this.onCancel,
  });

  @override
  State<CameraPickerView> createState() => _CameraPickerViewState();
}

class _CameraPickerViewState extends State<CameraPickerView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (photo != null) {
        widget.onImagePicked(File(photo.path));
      }
    } catch (e) {
      // エラーハンドリング
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickFromLibrary() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        widget.onImagePicked(File(image.path));
      }
    } catch (e) {
      // エラーハンドリング
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.M.dd', 'ja_JP');
    final dateString = dateFormat.format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラプレビューエリア（実際のカメラプレビューはimage_pickerでは直接サポートされていないため、
          // カメラを開いた後に画像を選択する方式になります）
          Center(
            child: Container(
              color: Colors.black,
              child: const Icon(
                Icons.camera_alt,
                size: 100,
                color: Colors.white54,
              ),
            ),
          ),
          // 上部バー
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 110,
              color: Colors.yellow,
            ),
          ),
          // 下部バー
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 130,
              color: Colors.yellow,
            ),
          ),
          // 日付表示
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              dateString,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA15D26),
              ),
            ),
          ),
          // ライブラリボタン
          Positioned(
            left: 28,
            bottom: 34,
            child: GestureDetector(
              onTap: _pickFromLibrary,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.photo_library,
                  size: 22,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // シャッターボタン
          Positioned(
            bottom: 29,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 26,
                    color: Colors.black,
                    weight: 700,
                  ),
                ),
              ),
            ),
          ),
          // ポケットボタン
          Positioned(
            right: 28,
            bottom: 29,
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag,
                    size: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ポケット',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

