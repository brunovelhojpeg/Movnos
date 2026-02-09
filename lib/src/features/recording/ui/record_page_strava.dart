import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controller/workout_recorder_scope.dart';
import '../recorder/workout_recorder.dart';
import 'workout_summary_page.dart';

class RecordPageStrava extends StatefulWidget {
  const RecordPageStrava({super.key});

  @override
  State<RecordPageStrava> createState() => _RecordPageStravaState();
}

class _RecordPageStravaState extends State<RecordPageStrava> {
  final MapController _map = MapController();
  bool _busyNav = false;

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

  @override
  Widget build(BuildContext context) {
    final recorder = WorkoutRecorderScope.of(context);

    return AnimatedBuilder(
      animation: recorder,
      builder: (context, _) {
        final st = recorder.state;
        final line = st.points.map((p) => LatLng(p.lat, p.lon)).toList();
        final center =
            line.isNotEmpty ? line.last : const LatLng(-30.0346, -51.2177);

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 16,
                  onMapReady: () {
                    if (line.isNotEmpty) _map.move(center, 16);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.movnos.app',
                  ),
                  if (line.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: line,
                          strokeWidth: 6,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                ],
              ),

              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TopPill(label: 'Outros', onTap: () {}),
                      Row(
                        children: [
                          _TopIconButton(
                            icon: Icons.layers_outlined,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _TopIconButton(
                            icon: Icons.my_location,
                            onTap: () {
                              if (line.isNotEmpty) _map.move(center, 17);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: _BottomPanel(
                  timeText: _fmtTime(st.elapsed),
                  paceText: _fmtPace(st.paceSecPerKm),
                  distText: st.distanceKm.toStringAsFixed(2),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 16),
                      _SideChip(
                        icon: Icons.directions_run,
                        label: 'Outros',
                        onTap: () {},
                      ),
                      _MainControlButton(
                        status: st.status,
                        onStart: () async {
                          await recorder.start();
                        },
                        onPause: () {
                          recorder.pause();
                        },
                        onResume: () {
                          recorder.resume();
                        },
                        onStop: () async {
                          if (_busyNav) return;
                          _busyNav = true;
                          try {
                            final session = await recorder.stop();
                            if (!mounted) return;
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutSummaryPage(session: session)),
                            );
                            recorder.reset();
                          } finally {
                            _busyNav = false;
                          }
                        },
                      ),
                      _SideChip(
                        icon: Icons.check_circle_outline,
                        label: 'Salvar',
                        onTap: () async {
                          if (st.status == RecorderStatus.running ||
                              st.status == RecorderStatus.paused) {
                            if (_busyNav) return;
                            _busyNav = true;
                            try {
                              final session = await recorder.stop();
                              if (!mounted) return;
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        WorkoutSummaryPage(session: session)),
                              );
                              recorder.reset();
                            } finally {
                              _busyNav = false;
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.timeText,
    required this.paceText,
    required this.distText,
  });

  final String timeText;
  final String paceText;
  final String distText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(value: timeText, label: 'Tempo'),
          _Stat(value: paceText, label: 'Ritmo (/km)'),
          _Stat(value: distText, label: 'Distância (km)'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _MainControlButton extends StatelessWidget {
  const _MainControlButton({
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final RecorderStatus status;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Future<void> Function() onStart;
  final Future<void> Function() onStop;

  @override
  Widget build(BuildContext context) {
    final isIdle = status == RecorderStatus.idle;
    final isRunning = status == RecorderStatus.running;
    final isPaused = status == RecorderStatus.paused;

    return GestureDetector(
      onTap: () async {
        if (isIdle) await onStart();
        if (isRunning) onPause();
        if (isPaused) onResume();
      },
      onLongPress: () async {
        if (isRunning || isPaused) await onStop();
      },
      child: Container(
        width: 86,
        height: 86,
        decoration: const BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIdle ? Icons.play_arrow : (isRunning ? Icons.pause : Icons.play_arrow),
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

class _SideChip extends StatelessWidget {
  const _SideChip(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon),
        ),
      ),
    );
  }
}
