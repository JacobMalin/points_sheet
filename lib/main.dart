import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:points_sheet/history_menu.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'actions_bar.dart';
import 'points_grid.dart';
import 'sling.dart';
import 'update_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final window = WindowManager.instance.getCurrent()!;
  window.minimumSize = const Size(440, 500).toNative();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>(
      create: (_) => AppDatabase(),
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

  final rewards = <Reward>[
    const Reward('Mocktail', 250),
    const Reward('Hot Food', 500),
    const Reward('Any Concessions', 1000),
    const Reward('I dont remember 2', 1500),
    const Reward('I dont remember 3', 2000),
    const Reward('I dont remember 4', 2500),
  ];

  final writeups = <Writeup>[
    const Writeup('Behavior Writeup', 100),
    const Writeup('Attendance Writeup', 500),
    const Writeup('Till Writeup', 50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
        actions: [
          SlingButton(authorizationToken: _authorizationToken),
          const SizedBox(width: 8),
        ],
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
                showHistoryButton: !useDetailsPanel,
                onOpenHistory: () => setState(() => _showHistoryMenu = true),
              ),
              Expanded(
                child: Stack(
                  children: [
                    PointsGrid(
                      rewards: rewards,
                      writeups: writeups,
                      useDetailsPanel: useDetailsPanel,
                    ),
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
