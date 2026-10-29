import 'package:clickbattle/services/ad_service.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/services/audio_service.dart';
import 'package:clickbattle/services/localization_service.dart';
import 'package:clickbattle/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _booted = false;

Future<AppManager> bootTestApp() async {
  final app = AppManager();
  if (!_booted) {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    app.prefs = await SharedPreferences.getInstance();
    app.settingsService = SettingsService(app.prefs);
    app.audioService = AudioService();
    app.adService = AdService();
    app.localizationService = LocalizationService();
    _booted = true;
  }
  return app;
}

Widget wrapWithApp(Widget child, AppManager app) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MultiProvider(
      providers: [
        Provider<AppManager>.value(value: app),
        ChangeNotifierProvider<LocalizationService>.value(
          value: app.localizationService,
        ),
        ChangeNotifierProvider<SettingsService>.value(
          value: app.settingsService,
        ),
      ],
      child: child,
    ),
  );
}

Future<AppManager> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(390, 844),
}) async {
  final app = await bootTestApp();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(wrapWithApp(screen, app));
  await tester.pump();
  return app;
}
