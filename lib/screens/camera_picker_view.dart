import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CameraPickerViewState extends State<CameraPickerView>
    with WidgetsBindingObserver {
  final _picker = ImagePicker();
  CameraController? _controller;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'カメラが見つかりません';
          _isInitializing = false;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted) {
        controller.dispose();
        return;
      }

      _controller?.dispose();
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'カメラ初期化に失敗しました';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      widget.onImagePicked(File(file.path));
    } catch (e) {
      debugPrint('撮影エラー: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        widget.onImagePicked(File(image.path));
      }
    } catch (e) {
      debugPrint('ギャラリー選択エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラプレビュー
          Positioned.fill(child: _buildPreview()),

          // 上部バー
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              color: Colors.yellow.withOpacity(0.85),
            ),
          ),

          // 下部バー
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              color: Colors.yellow.withOpacity(0.9),
            ),
          ),

          // 日付表示
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              DateFormat('yyyy.M.dd', 'ja_JP').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA15D26),
              ),
            ),
          ),

          // ギャラリーボタン
          Positioned(
            left: 28,
            bottom: 55,
            child: _CircleButton(
              onTap: _pickFromGallery,
              icon: Icons.photo_library,
            ),
          ),

          // シャッターボタン
          Positioned(
            bottom: 55,
            left: 0,
            right: 0,
            child: Center(
              child: _ShutterButton(onTap: _takePicture),
            ),
          ),

          // ポケットボタン
          Positioned(
            right: 28,
            bottom: 65,
            child: GestureDetector(
              onTap: widget.onCancel,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag, size: 20, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    'ポケット',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
      );
    }

    if (_isInitializing || _controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      );
    }

    final previewSize = _controller!.value.previewSize;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize?.height ?? MediaQuery.of(context).size.width,
        height: previewSize?.width ?? MediaQuery.of(context).size.height,
        child: CameraPreview(_controller!),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _CircleButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShutterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: const Icon(Icons.star, size: 26, color: Colors.black),
      ),
    );
  }
}
