import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/screens/home/home_screen.dart';
import 'package:clickbattle/screens/game/game_screen.dart';
import 'package:clickbattle/screens/settings/settings_screen.dart';
import 'package:clickbattle/screens/mode_selection/mode_selection_screen.dart';
import 'package:clickbattle/screens/how_to_play/how_to_play_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:clickbattle/constants/app_colors.dart';
import 'package:clickbattle/services/app_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AppManager
  final appManager = AppManager();
  await appManager.initialize();
  
  // Modern system UI handling for edge-to-edge display
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Optimize for release
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => appManager.settingsService,
        ),
        ChangeNotifierProvider(
          create: (_) => appManager.localizationService,
        ),
        Provider.value(
          value: appManager,
        ),
      ],
      child: const ClickBattleApp(),
    ),
  );
}

class ClickBattleApp extends StatefulWidget {
  const ClickBattleApp({Key? key}) : super(key: key);

  @override
  State<ClickBattleApp> createState() => _ClickBattleAppState();
}

class _ClickBattleAppState extends State<ClickBattleApp> {
  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context, listen: false);
    
    return MaterialApp(
      title: appManager.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(AppColors.primary.value, {
            50: AppColors.primary.withOpacity(0.1),
            100: AppColors.primary.withOpacity(0.2),
            200: AppColors.primary.withOpacity(0.3),
            300: AppColors.primary.withOpacity(0.4),
            400: AppColors.primary.withOpacity(0.5),
            500: AppColors.primary,
            600: AppColors.primary.withOpacity(0.7),
            700: AppColors.primary.withOpacity(0.8),
            800: AppColors.primary.withOpacity(0.9),
            900: AppColors.primary.withOpacity(1),
          }),
        ).copyWith(
          secondary: AppColors.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/mode_selection': (context) => const ModeSelectionScreen(),
        '/how_to_play': (context) => const HowToPlayScreen(),
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
