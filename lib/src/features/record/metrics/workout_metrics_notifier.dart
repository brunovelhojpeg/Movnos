import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class WorkoutMetricsState {
  final Duration elapsed;
  final double distanceMeters;
  final double paceSecPerKm; // stable pace
  final bool isRunning;

  const WorkoutMetricsState({
    required this.elapsed,
    required this.distanceMeters,
    required this.paceSecPerKm,
    required this.isRunning,
  });

  double get distanceKm => distanceMeters / 1000.0;
}

class WorkoutMetricsNotifier extends ChangeNotifier {
  final Stopwatch _sw = Stopwatch();
  StreamSubscription<Position>? _sub;

  WorkoutMetricsState _state = const WorkoutMetricsState(
    elapsed: Duration.zero,
    distanceMeters: 0,
    paceSecPerKm: 0,
    isRunning: false,
  );

  WorkoutMetricsState get state => _state;

  Position? _lastGood;
  double _distanceMeters = 0;

  // Pace smoothing (EMA)
  double _paceEma = 0; // sec/km
  static const double _emaAlpha = 0.20;

  Timer? _uiTick;

  Future<void> start() async {
    await _ensureLocationReady();

    _distanceMeters = 0;
    _paceEma = 0;
    _lastGood = null;

    _sw.reset();
    _sw.start();

    _state = WorkoutMetricsState(
      elapsed: _sw.elapsed,
      distanceMeters: 0,
      paceSecPerKm: 0,
      isRunning: true,
    );
    notifyListeners();

    _uiTick?.cancel();
    _uiTick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_sw.isRunning) {
        _state = WorkoutMetricsState(
          elapsed: _sw.elapsed,
          distanceMeters: _distanceMeters,
          paceSecPerKm: _paceEma,
          isRunning: true,
        );
        notifyListeners();
      }
    });

    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2, // meters between updates
      ),
    ).listen(_onPosition);
  }

  void pause() {
    _sw.stop();
    _state = WorkoutMetricsState(
      elapsed: _sw.elapsed,
      distanceMeters: _distanceMeters,
      paceSecPerKm: _paceEma,
      isRunning: false,
    );
    notifyListeners();
  }

  void resume() {
    if (_sw.isRunning) return;
    _sw.start();
    _state = WorkoutMetricsState(
      elapsed: _sw.elapsed,
      distanceMeters: _distanceMeters,
      paceSecPerKm: _paceEma,
      isRunning: true,
    );
    notifyListeners();
  }

  Future<void> stop() async {
    _sw.stop();
    await _sub?.cancel();
    _sub = null;
    _uiTick?.cancel();
    _uiTick = null;

    _state = WorkoutMetricsState(
      elapsed: _sw.elapsed,
      distanceMeters: _distanceMeters,
      paceSecPerKm: _paceEma,
      isRunning: false,
    );
    notifyListeners();
  }

  void reset() {
    _sw.reset();
    _distanceMeters = 0;
    _paceEma = 0;
    _lastGood = null;

    _state = const WorkoutMetricsState(
      elapsed: Duration.zero,
      distanceMeters: 0,
      paceSecPerKm: 0,
      isRunning: false,
    );
    notifyListeners();
  }

  // ----------------- internals -----------------

  Future<void> _ensureLocationReady() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted.');
    }
  }

  void _onPosition(Position p) {
    // Filter: ignore bad accuracy (common cause of wrong distance/pace)
    if (p.accuracy.isNaN || p.accuracy > 25) return;

    // Filter: ignore insane jumps (gps glitch)
    if (_lastGood != null) {
      final dt = p.timestamp != null && _lastGood!.timestamp != null
          ? p.timestamp!.difference(_lastGood!.timestamp!).inMilliseconds /
              1000.0
          : 1.0;

      final d = _haversineMeters(
        _lastGood!.latitude,
        _lastGood!.longitude,
        p.latitude,
        p.longitude,
      );

      final speed = (dt <= 0) ? 0 : d / dt; // m/s

      // If speed > 8 m/s (~28.8 km/h), ignore as glitch
      if (speed > 8) return;

      // Add distance
      if (d >= 0.5) {
        _distanceMeters += d;
      }

      // Compute stable pace ONLY after minimal distance
      final distanceKm = _distanceMeters / 1000.0;
      if (distanceKm >= 0.05) {
        final sec = _sw.elapsed.inMilliseconds / 1000.0;
        final rawPace = sec / distanceKm; // sec/km

        if (_paceEma == 0) {
          _paceEma = rawPace;
        } else {
          _paceEma = (_emaAlpha * rawPace) + ((1 - _emaAlpha) * _paceEma);
        }
      }
    }

    _lastGood = p;
  }

  double _haversineMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = pow(sin(dLat / 2), 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double d) => d * (pi / 180.0);

  @override
  void dispose() {
    _sub?.cancel();
    _uiTick?.cancel();
    super.dispose();
  }
}
