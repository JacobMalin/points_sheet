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

  // final employees = <Employee>[
  //   Employee('Addie', 'G', points: 1320),
  //   Employee('Adam', 'J', points: 475),
  //   Employee('Alex', 'R', points: 60),
  //   Employee('Alexis', 'R', points: 860),
  //   Employee('Andy', 'G', points: 530),
  //   Employee('Anton', 'A', points: 345),
  //   Employee('Asher', 'G', points: 235),
  //   Employee('Ben', 'L', points: 600),
  //   Employee('Cameron', 'N', points: 15405),
  //   Employee('Charlotte', 'C', points: 480),
  //   Employee('Connor', 'F', points: 245),
  //   Employee('Connor', 'T', points: 925),
  //   Employee('Daniel', 'M', points: 940),
  //   Employee('Dante', 'P', points: 1900),
  //   Employee('DeWayne', 'C', points: 585),
  //   Employee('Daria', 'K', points: 135),
  //   Employee('Dylan', 'S', points: 195),
  //   Employee('Emre', 'G', points: 5920),
  //   Employee('Evan', 'B', points: 2590),
  //   Employee('Grady', 'C', points: 185),
  //   Employee('Grant', 'D', points: 890),
  //   Employee('James', 'C', points: 1025),
  //   Employee('Janiyah', 'I', points: 580),
  //   Employee('Joel', 'S', points: 1170),
  //   Employee('Johnny', 'K', points: 495),
  //   Employee('Johanna', 'K', points: 30),
  //   Employee('Karrie', 'N', points: 655),
  //   Employee('Katherine', 'V', points: 390),
  //   Employee('Katy', 'W', points: 340),
  //   Employee('Kevin', 'K', points: 490),
  //   Employee('Kinley', 'F', points: 55),
  //   Employee('Landen', 'K', points: 605),
  //   Employee('Leiland', 'Q', points: 815),
  //   Employee('Matt', 'K', points: 1185),
  //   Employee('Maverick', 'M', points: 60),
  //   Employee('Mimi', 'D', points: 550),
  //   Employee('Oliver', 'B', points: 30),
  //   Employee('Oscar', 'B', points: 2510),
  //   Employee('Peyton', 'H', points: 1045),
  //   Employee('Quinn', 'F', points: 0),
  //   Employee('Reese', 'K', points: 835),
  //   Employee('Sarah', 'J', points: 1590),
  //   Employee('Saad', 'H', points: 1100),
  //   Employee('Shay', 'K', points: 1415),
  //   Employee('Sophia', 'V', points: 485),
  //   Employee('Sophie', 'S', points: 515),
  //   Employee('Timmy', 'C', points: 3030),
  //   Employee('Tristan', 'D', points: 195),
  //   Employee('Tristan', 'K', points: 580),
  //   Employee('Tsimur', 'K', points: 60),
  //   Employee('William', 'R', points: 2245),
  //   Employee('Zen', 'O', points: 255),
  // ];

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
