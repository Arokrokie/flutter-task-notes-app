import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'helpers/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(initialDarkMode: isDark));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  const MyApp({super.key, this.initialDarkMode = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDarkMode;
    // print DB contents for verification
    _printDbContentsOnStartup();
  }

  void _setDark(bool v) {
    setState(() {
      _isDark = v;
    });
  }

  // DEBUG: print database contents on startup (useful to verify persistence)
  // This runs after the app is initialized.
  void _printDbContentsOnStartup() async {
    try {
      final db = DatabaseHelper();
      final tasks = await db.getTasks();
      // Use print so Flutter run shows it in the terminal.
      debugPrint('DEBUG: Stored tasks (${tasks.length}):');
      for (final t in tasks) {
        debugPrint(
          ' - id=${t.id} title=${t.title} priority=${t.priority} completed=${t.isCompleted}',
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Could not read tasks from DB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = Colors.indigo;
    return MaterialApp(
      title: 'Task Notes Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(isDarkMode: _isDark, onThemeChanged: _setDark),
    );
  }
}
