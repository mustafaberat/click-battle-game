import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
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

/// Preload Bangers / Exo 2 under the family names GoogleFonts registers, plus
/// MaterialIcons, so golden-style screenshots are not Ahem rectangles.
Future<void> _loadTestFonts() async {
  const bangers = '/workspace/google_fonts/Bangers-Regular.ttf';
  const exo8 = '/workspace/google_fonts/Exo2-ExtraBold.ttf';
  const exo6 = '/workspace/google_fonts/Exo2-SemiBold.ttf';
  const icons =
      '/home/ubuntu/sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

  await _loadFamily('Bangers_regular', bangers);
  await _loadFamily('Bangers', bangers);
  await _loadFamily('Exo2_800', exo8);
  await _loadFamily('Exo2_600', exo6);
  await _loadFamily('Exo2_regular', exo6);
  await _loadFamily('Exo2', exo8);
  await _loadFamily('MaterialIcons', icons);
}
