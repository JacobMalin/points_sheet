import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:points_sheet/history_menu.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'actions_bar.dart';
import 'points_grid.dart';
import 'update_app.dart';
import 'window_position.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ByteData data = await PlatformAssetBundle().load(
    'assets/Sectigo Public Server Authentication CA DV E36.crt',
  );
  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    data.buffer.asUint8List(),
  );

  final window = WindowManager.instance.getCurrent()!;
  window.minimumSize = const Size(440, 545).toNative();
  final database = AppDatabase();
  await WindowPositionTracker(window, database).initialize();

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>(
      create: (_) => database,
      lazy: false,
      dispose: (_, database) => database.close(),
      child: MaterialApp(
        title: 'Points Sheet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: const .fromARGB(255, 18, 75, 99),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(title: 'Points Sheet'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _authorizationToken;
  bool _showHistoryMenu = false;
  bool _clearHistoryMenuScheduled = false;

  final wideLayoutBreakpoint = 720.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useDetailsPanel = constraints.maxWidth >= wideLayoutBreakpoint;
          if (useDetailsPanel &&
              _showHistoryMenu &&
              !_clearHistoryMenuScheduled) {
            _clearHistoryMenuScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _showHistoryMenu = false;
                _clearHistoryMenuScheduled = false;
              });
            });
          }

          return Column(
            children: [
              ActionsBar(
                authorizationToken: _authorizationToken,
                showHistoryButton: !useDetailsPanel,
                onOpenHistory: () =>
                    setState(() => _showHistoryMenu = !_showHistoryMenu),
              ),
              Expanded(
                child: Stack(
                  children: [
                    PointsGrid(useDetailsPanel: useDetailsPanel),
                    if (_showHistoryMenu && !useDetailsPanel)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Theme.of(context).colorScheme.surface,
                          child: HistoryMenu(
                            onClose: () =>
                                setState(() => _showHistoryMenu = false),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const UpdateApp(),
            ],
          );
        },
      ),
    );
  }
}
