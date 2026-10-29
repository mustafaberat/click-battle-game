import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({'selected_language': 'en'});
  await _loadTestFonts();
  await testMain();
}

Future<ByteData> _bytes(String path) async {
  final data = File(path).readAsBytesSync();
  return ByteData.sublistView(Uint8List.fromList(data));
}

Future<void> _loadFamily(String family, String path) async {
  if (!File(path).existsSync()) return;
  final loader = FontLoader(family)..addFont(_bytes(path));
  await loader.load();
}

/// Preload the bundled Bangers / Exo 2 fonts (repo `fonts/`) plus
/// MaterialIcons, so golden-style screenshots are not Ahem rectangles.
Future<void> _loadTestFonts() async {
  const bangers = 'fonts/Bangers-Regular.ttf';
  const exo = 'fonts/Exo2-ExtraBold.ttf';
  await _loadFamily('Bangers', bangers);
  await _loadFamily('Exo2', exo);

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await _loadFamily(
      'MaterialIcons',
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
  }
}
