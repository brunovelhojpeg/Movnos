import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/workout_session.dart';
import 'polyline6.dart';

class MapboxStatic {
  static String get token => const String.fromEnvironment('MAPBOX_TOKEN');

  // Strava-like style: change if desired
  static const style = 'mapbox/outdoors-v12';

  static Future<Uint8List> snapshotPng({
    required WorkoutSession session,
    int width = 1080,
    int height = 1920,
  }) async {
    if (token.isEmpty) {
      throw Exception(
          'MAPBOX_TOKEN is missing. Run with --dart-define=MAPBOX_TOKEN=...');
    }

    final pts = session.points;
    if (pts.length < 2) {
      throw Exception('Not enough points to render route.');
    }

    final coords = pts.map((p) => [p.lat, p.lon]).toList();
    final encoded = Polyline6.encode(coords);

    final mid = pts[pts.length ~/ 2];
    final center = '${mid.lon},${mid.lat},15,0';

    final overlay = 'path-6+ff5a1f-6(${Uri.encodeComponent(encoded)})';

    final url =
        'https://api.mapbox.com/styles/v1/$style/static/$overlay/$center/${width}x$height@2x?access_token=$token&logo=false&attribution=false';

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception(
          'Mapbox static failed (${res.statusCode}): ${utf8.decode(res.bodyBytes)}');
    }
    return res.bodyBytes;
  }
}
