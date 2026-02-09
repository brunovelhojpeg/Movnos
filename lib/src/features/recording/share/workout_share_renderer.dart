import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/workout_session.dart';
import 'mapbox_static.dart';

class WorkoutShareRenderer {
  static String _fmtTime(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _fmtPace(double secPerKm) {
    if (secPerKm <= 0) return '--:--';
    final t = secPerKm.round();
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static Future<File> renderToFile(WorkoutSession session) async {
    final mapPng = await MapboxStatic.snapshotPng(session: session);

    final codec = await ui.instantiateImageCodec(mapPng);
    final frame = await codec.getNextFrame();
    final mapImg = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final w = mapImg.width.toDouble();
    final h = mapImg.height.toDouble();

    // Draw map
    canvas.drawImage(mapImg, Offset.zero, Paint());

    // MOVNOS watermark
    final wm = TextPainter(
      text: const TextSpan(
        text: 'MOVNOS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawRect(
      const Rect.fromLTWH(32, 32, 260, 90),
      Paint()..color = Colors.black.withOpacity(0.35),
    );
    wm.paint(canvas, const Offset(52, 52));

    // Bottom stats panel
    final panelRect = Rect.fromLTWH(48, h - 260, w - 96, 180);
    final rrect = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(rrect, Paint()..color = Colors.white.withOpacity(0.92));

    final time = _fmtTime(session.elapsed);
    final pace = _fmtPace(session.paceSecPerKm);
    final dist = session.distanceKm.toStringAsFixed(2);

    void drawStat(double x, String value, String label) {
      final v = TextPainter(
        text: TextSpan(
          text: value,
          style: const TextStyle(color: Colors.black, fontSize: 56, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final l = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.black54, fontSize: 26, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      v.paint(canvas, Offset(x, h - 235));
      l.paint(canvas, Offset(x, h - 160));
    }

    final col1 = 90.0;
    final col2 = w / 2 - 120;
    final col3 = w - 360;

    drawStat(col1, time, 'Tempo');
    drawStat(col2, pace, 'Ritmo (/km)');
    drawStat(col3, dist, 'Distância (km)');

    final pic = recorder.endRecording();
    final img = await pic.toImage(mapImg.width, mapImg.height);
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/movnos_share_${session.id}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> share(WorkoutSession session) async {
    final file = await renderToFile(session);

    if (kIsWeb) {
      throw Exception(
          'On Web, file share may not work. Use iOS/Android for native share.');
    } else {
      await Share.shareXFiles([XFile(file.path)], text: 'Meu treino no Movnos 🏃');
    }
  }
}
