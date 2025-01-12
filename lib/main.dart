import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/settings/settings_screen.dart';
import 'package:clickbattle/screens/mode_selection/mode_selection_screen.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:clickbattle/styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsService(prefs),
        ),
      ],
      child: const ClickBattleApp(),
    ),
  );
}

class ClickBattleApp extends StatelessWidget {
  const ClickBattleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkMode = context.watch<SettingsService>().darkMode;
    
    return MaterialApp(
      title: 'Click Battle',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        scaffoldBackgroundColor: AppColors.background,
        brightness: darkMode ? Brightness.dark : Brightness.light,
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
