import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:provider/provider.dart';

import 'actions_bar.dart';
import 'points_grid.dart';
import 'sling.dart';

void main() {
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

class Reward {
  const Reward(this.name, this.pointsRequired, this.color);

  final String name;
  final int pointsRequired;
  final Color color;
}

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _authorizationToken;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final rewards = <Reward>[
    const Reward('Mocktail', 250, Color.fromARGB(255, 107, 170, 199)),
    const Reward('Hot Food', 500, Color.fromARGB(255, 195, 173, 75)),
    const Reward('Any Concessions', 1000, Color.fromARGB(255, 200, 32, 77)),
    const Reward('I dont remember 2', 1500, Color(0xFFFFC107)),
    const Reward('I dont remember 3', 2000, Color(0xFFFF5722)),
    const Reward('I dont remember 4', 2500, Color(0xFF9C27B0)),
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
      body: Column(
        children: [
          ActionsBar(),
          Expanded(child: PointsGrid()),
        ],
      ),
    );
  }
}
