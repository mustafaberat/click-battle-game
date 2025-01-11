import 'package:flutter/material.dart';
import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/settings/settings_screen.dart';
import 'package:clickbattle/screens/mode_selection/mode_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Click Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/mode_selection': (context) => const ModeSelectionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => GameScreen(gameArgs: args),
          );
        }
        return null;
      },
    );
  }
}
