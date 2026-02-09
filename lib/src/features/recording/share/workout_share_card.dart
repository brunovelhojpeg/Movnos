import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/workout_session.dart';

class WorkoutShareCard extends StatefulWidget {
  const WorkoutShareCard({super.key, required this.session});

  final WorkoutSession session;

  @override
  State<WorkoutShareCard> createState() => _WorkoutShareCardState();
}

class _WorkoutShareCardState extends State<WorkoutShareCard> {
  final _key = GlobalKey();
  bool _sharing = false;

  List<LatLng> get _line =>
      widget.session.points.map((p) => LatLng(p.lat, p.lon)).toList();

  LatLng get _center {
    if (_line.isEmpty) return const LatLng(-30.0, -51.0);
    final mid = _line[_line.length ~/ 2];
    return mid;
  }

  String _fmtTime(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _fmtPace(double secPerKm) {
    if (secPerKm <= 0) return '--:--';
    final t = secPerKm.round();
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      final boundary =
          _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Save temp file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/movnos_${widget.session.id}.png');
      await file.writeAsBytes(bytes, flush: true);

      // Share (mobile). Web fallback: share of files is limited.
      if (kIsWeb) {
        throw Exception('Share is not fully supported on Web for image files.');
      } else {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Meu treino no Movnos 🏃',
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;

    return Column(
      children: [
        RepaintBoundary(
          key: _key,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 15,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.movnos.app',
                    ),
                    if (_line.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _line,
                            strokeWidth: 6,
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                  ],
                ),

                // MOVNOS watermark on the map (Strava-like brand)
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MOVNOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                // Stats panel
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stat('Tempo', _fmtTime(s.elapsed)),
                        _stat('Ritmo (/km)', _fmtPace(s.paceSecPerKm)),
                        _stat('Distância (km)', s.distanceKm.toStringAsFixed(2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sharing ? null : share,
            child: Text(_sharing ? 'Gerando imagem...' : 'Compartilhar'),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
