import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Load the real app fonts so widget tests measure the same text widths as
/// the device (the default test font is much wider than Barlow Condensed).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync())));
    }
    await loader.load();
  }

  await load('BarlowCondensed', [
    'BarlowCondensed-Regular.ttf',
    'BarlowCondensed-Medium.ttf',
    'BarlowCondensed-SemiBold.ttf',
    'BarlowCondensed-Bold.ttf',
  ]);
  await load('Oswald', ['Oswald-Variable.ttf']);
  await testMain();
}
