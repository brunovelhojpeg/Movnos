import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

enum RecorderStatus { idle, running, paused, finished }

class RecorderState {
  final RecorderStatus status;
  final Duration elapsed;
  final double distanceKm;
  final double paceSecPerKm; // seconds per km

  const RecorderState({
    required this.status,
    required this.elapsed,
    required this.distanceKm,
    required this.paceSecPerKm,
  });

  const RecorderState.initial()
      : status = RecorderStatus.idle,
        elapsed = Duration.zero,
        distanceKm = 0,
        paceSecPerKm = 0;

  RecorderState copyWith({
    RecorderStatus? status,
    Duration? elapsed,
    double? distanceKm,
    double? paceSecPerKm,
  }) {
    return RecorderState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      distanceKm: distanceKm ?? this.distanceKm,
      paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
    );
  }
}

/// Lightweight simulated recorder for dev/web preview; not tied to GPS.
class RecorderEngine extends ChangeNotifier {
  RecorderState _state = const RecorderState.initial();
  RecorderState get state => _state;

  Timer? _tick;
  final Stopwatch _sw = Stopwatch();

  // Web dev simulation config
  double _speedMps = 2.6; // ~9.3 km/h running
  double _distanceMeters = 0;

  bool _busy = false; // prevents double taps / loops

  void setDevSpeedMps(double v) {
    _speedMps = v.clamp(0.8, 6.0);
  }

  void start() {
    if (_busy) return;
    _busy = true;

    if (_state.status == RecorderStatus.running) {
      _busy = false;
      return;
    }

    if (_state.status == RecorderStatus.idle ||
        _state.status == RecorderStatus.finished) {
      _distanceMeters = 0;
      _sw.reset();
      _state = _state.copyWith(
        status: RecorderStatus.running,
        elapsed: Duration.zero,
        distanceKm: 0,
        paceSecPerKm: 0,
      );
    } else {
      _state = _state.copyWith(status: RecorderStatus.running);
    }

    _sw.start();
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_state.status != RecorderStatus.running) return;

      final elapsed = _sw.elapsed;

      // distance (simulated smooth)
      const deltaSeconds = 0.25;
      _distanceMeters += (_speedMps * deltaSeconds);

      final distanceKm = _distanceMeters / 1000.0;

      // pace (only after 100m)
      final pace = _computePace(elapsed, distanceKm);

      _state = _state.copyWith(
        elapsed: elapsed,
        distanceKm: distanceKm,
        paceSecPerKm: pace,
      );

      notifyListeners();
    });

    Future.microtask(() => _busy = false);
    notifyListeners();
  }

  void pause() {
    if (_busy) return;
    _busy = true;

    if (_state.status != RecorderStatus.running) {
      _busy = false;
      return;
    }

    _sw.stop();
    _state = _state.copyWith(status: RecorderStatus.paused);
    notifyListeners();

    Future.microtask(() => _busy = false);
  }

  void stop() {
    if (_busy) return;
    _busy = true;

    _sw.stop();
    _tick?.cancel();
    _tick = null;

    _state = _state.copyWith(status: RecorderStatus.finished);
    notifyListeners();

    Future.microtask(() => _busy = false);
  }

  void reset() {
    _sw.stop();
    _sw.reset();
    _tick?.cancel();
    _tick = null;
    _distanceMeters = 0;
    _state = const RecorderState.initial();
    notifyListeners();
  }

  double _computePace(Duration elapsed, double distanceKm) {
    if (distanceKm < 0.1) return 0; // avoid crazy pace at 0km
    final sec = elapsed.inSeconds.toDouble();
    final pace = sec / distanceKm;
    if (pace.isInfinite || pace.isNaN) return 0;
    return pace;
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}
