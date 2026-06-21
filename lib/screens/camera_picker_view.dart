import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  // UIバーの高さ
  static const double _topBarHeight = 80;
  static const double _bottomBarHeight = 140;

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
        ResolutionPreset.veryHigh,
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
      // プレビュー領域のアスペクト比を計算
      final screenSize = MediaQuery.sizeOf(context);
      final previewWidth = screenSize.width;
      final previewHeight =
          screenSize.height - _topBarHeight - _bottomBarHeight;
      final previewAspectRatio = previewWidth / previewHeight;

      final file = await controller.takePicture();
      if (!mounted) return;

      // 画像をプレビュー領域のアスペクト比に合わせてクロップ
      final croppedFile = await _cropImageToPreviewAspect(
        File(file.path),
        previewAspectRatio,
      );
      if (!mounted) return;

      widget.onImagePicked(croppedFile);
    } catch (e) {
      // 撮影エラーは無視（UIはそのまま）
    }
  }

  /// 画像をプレビュー領域のアスペクト比に合わせてクロップ
  Future<File> _cropImageToPreviewAspect(
    File imageFile,
    double targetAspectRatio,
  ) async {
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      return imageFile; // デコードできない場合は元の画像を返す
    }

    final imgWidth = originalImage.width;
    final imgHeight = originalImage.height;
    final imgAspectRatio = imgWidth / imgHeight;

    int cropWidth, cropHeight, offsetX, offsetY;

    if (imgAspectRatio > targetAspectRatio) {
      // 画像が横長すぎる → 横をクロップ
      cropHeight = imgHeight;
      cropWidth = (imgHeight * targetAspectRatio).round();
      offsetX = ((imgWidth - cropWidth) / 2).round();
      offsetY = 0;
    } else {
      // 画像が縦長すぎる → 縦をクロップ
      cropWidth = imgWidth;
      cropHeight = (imgWidth / targetAspectRatio).round();
      offsetX = 0;
      offsetY = ((imgHeight - cropHeight) / 2).round();
    }

    final croppedImage = img.copyCrop(
      originalImage,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    // 一時ファイルとして保存
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final croppedFile = File('${tempDir.path}/cropped_$timestamp.jpg');
    await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 95));

    return croppedFile;
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        widget.onImagePicked(File(image.path));
      }
    } catch (e) {
      // ギャラリー選択エラーは無視
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラプレビュー（バナーの内側に配置）
          Positioned(
            top: _topBarHeight,
            left: 0,
            right: 0,
            bottom: _bottomBarHeight,
            child: _buildPreview(),
          ),

          // 上部バー
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _topBarHeight,
              color: Colors.yellow.withValues(alpha: 0.85),
            ),
          ),

          // 下部バー
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _bottomBarHeight,
              color: Colors.yellow.withValues(alpha: 0.9),
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
            bottom: 60,
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
            bottom: 60,
            child: _PocketButton(onTap: widget.onCancel),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_errorMessage != null) {
      return Center(
        child:
            Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
      );
    }

    final controller = _controller;
    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      );
    }

    // プレビュー領域を歪みなく中央クロップで埋める（端末標準カメラと同じ挙動）。
    // CameraPreview は端末の向きに合わせて自前で正しいアスペクト比を保つため、
    // ここでは領域を覆うのに必要な拡大率だけを算出し Transform.scale で適用する。
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaAspectRatio = constraints.maxWidth / constraints.maxHeight;
        var scale = areaAspectRatio * controller.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(
              child: CameraPreview(controller),
            ),
          ),
        );
      },
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
        width: 60,
        height: 60,
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
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.yellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.star,
          size: 32,
          color: Colors.yellow,
        ),
      ),
    );
  }
}

class _PocketButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PocketButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _PocketIconPainter(color: Colors.black),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'ポケット',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _PocketIconPainter extends CustomPainter {
  const _PocketIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final width = size.width;
    final height = size.height;

    // ポケット枠
    final rect = Rect.fromLTWH(
      width * 0.2,
      height * 0.45,
      width * 0.6,
      height * 0.55,
    );
    final borderRadius = Radius.circular(width * 0.1);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius,
      topRight: borderRadius,
      bottomLeft: Radius.circular(width * 0.28),
      bottomRight: Radius.circular(width * 0.28),
    );
    canvas.drawRRect(rrect, paint);

    // スマイル
    final smilePath = Path();
    final smileWidth = width * 0.28;
    final smileHeight = height * 0.16;
    final smileLeft = (width - smileWidth) / 2;
    final smileTop = height * 0.7;
    smilePath.moveTo(smileLeft, smileTop);
    smilePath.quadraticBezierTo(
      width / 2,
      smileTop + smileHeight,
      smileLeft + smileWidth,
      smileTop,
    );
    canvas.drawPath(smilePath, paint..strokeWidth = size.width * 0.07);
  }

  @override
  bool shouldRepaint(covariant _PocketIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
