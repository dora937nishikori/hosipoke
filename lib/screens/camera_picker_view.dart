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
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  bool _initializing = true;
  String? _errorText;

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
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _initializing = true;
        _errorText = null;
      });
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() {
          _errorText = 'カメラが見つかりません';
          _initializing = false;
        });
        return;
      }
      final CameraDescription camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.max, // 画質優先
        enableAudio: false,
      );
      await controller.initialize();
      // 縦固定（必要に応じて）
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller?.dispose();
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'カメラ初期化に失敗しました: $e';
        _initializing = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      widget.onImagePicked(File(file.path));
    } catch (e) {
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
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.M.dd', 'ja_JP');
    final dateString = dateFormat.format(DateTime.now());

    Widget preview;
    if (_errorText != null) {
      preview = Center(
        child: Text(
          _errorText!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else if (_initializing || _controller == null || !_controller!.value.isInitialized) {
      preview = const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      );
    } else {
      final previewSize = _controller!.value.previewSize;
      preview = FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize?.height ?? MediaQuery.of(context).size.width,
          height: previewSize?.width ?? MediaQuery.of(context).size.height,
          child: CameraPreview(_controller!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: preview),
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
            bottom: 55,
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
            bottom: 55,
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
            bottom: 65,
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

