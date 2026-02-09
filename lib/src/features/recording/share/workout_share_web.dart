import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

/// Web: create an image and trigger browser download.
/// Mobile: handled elsewhere (share sheet).
class WorkoutShareWeb {
  final ScreenshotController controller = ScreenshotController();

  Future<void> downloadPng({
    required BuildContext context,
    required Widget captureWidget,
    required String fileName,
  }) async {
    if (!kIsWeb) return;

    final bytes = await controller.captureFromWidget(
      Material(
        color: Colors.white,
        child: SizedBox(width: 1080, height: 1920, child: captureWidget),
      ),
      delay: const Duration(milliseconds: 50),
    );

    _download(bytes, fileName);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagem gerada. Download iniciado.')),
    );
  }

  void _download(Uint8List bytes, String fileName) {
    // ignore: avoid_web_libraries_in_flutter
    importDownload(bytes, fileName);
  }
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void importDownload(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final a = html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrlFromBlob(url);
}
