import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/repositories/in_memory_wish_repository.dart';
import 'domain/repositories/wish_repository.dart';
import 'providers/pocket_store.dart';
import 'screens/pocket_view.dart';
import 'screens/save_item_view.dart';
import 'screens/item_detail_view.dart';
import 'screens/camera_picker_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WishRepository>(
          create: (_) => InMemoryWishRepository(),
        ),
        ChangeNotifierProvider<PocketStore>(
          create: (context) =>
              PocketStore(repository: context.read<WishRepository>()),
        ),
      ],
      child: MaterialApp(
            title: 'peace_hosipoke',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
              useMaterial3: true,
            ),
            home: const ContentView(),
          ),
    );
  }
}

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  bool _showCamera = false;
  bool _cameraOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = context.read<PocketStore>();
      await store.loadInitial();
      if (!mounted) return;
      if (store.items.isEmpty) {
        _openCamera();
      }
    });
  }

  void _openCamera() {
    if (_cameraOpened) return;
    _cameraOpened = true;
    setState(() {
      _showCamera = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraPickerView(
            onImagePicked: _handleImagePicked,
            onCancel: () {
              setState(() {
                _showCamera = false;
                _cameraOpened = false;
              });
              Navigator.of(context).pop();
            },
          ),
          fullscreenDialog: true,
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _showCamera = false;
            _cameraOpened = false;
          });
        }
      });
    });
  }

  void _handleImagePicked(File imageFile) {
    setState(() {
      _showCamera = false;
      _cameraOpened = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SaveItemView(
          photo: imageFile,
          onSave: (memo, priority) {
            context.read<PocketStore>().add(
                  imageFile: imageFile,
                  note: memo,
                  priority: priority,
                );
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          onClose: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          onRetake: () {
            Navigator.of(context).pop();
            _openCamera();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => PocketView(
              onSelect: (item) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemDetailView(
                      item: item,
                      onSave: (updatedNote, updatedPriority) async {
                        await context.read<PocketStore>().update(
                              id: item.id,
                              note: updatedNote,
                              priority: updatedPriority,
                            );
                      },
                      onClose: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
              onAdd: () {
                _openCamera();
              },
            ),
          );
        },
      ),
    );
  }

}

