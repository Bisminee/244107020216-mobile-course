import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Memuat font asli + font ikon Material agar screenshot golden
// terlihat seperti aplikasi sungguhan (bukan kotak).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const textFontCandidates = [
    r'C:\Windows\Fonts\segoeui.ttf',
    r'C:\Windows\Fonts\arial.ttf',
  ];
  for (final path in textFontCandidates) {
    final file = File(path);
    if (file.existsSync()) {
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      await loader.load();
      break;
    }
  }

  const iconFontCandidates = [
    r'D:\flutter\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
  ];
  for (final path in iconFontCandidates) {
    final file = File(path);
    if (file.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      await loader.load();
      break;
    }
  }

  await testMain();
}
