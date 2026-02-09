import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/workout_repository.dart';
import '../model/workout_point.dart';
import '../model/workout_session.dart';
import 'constants.dart';

enum RecorderStatus { idle, running, paused }

class RecorderState {
  final RecorderStatus status;
  final Duration elapsed;
  final double distanceKm;
  final double paceSecPerKm;
  final List<WorkoutPoint> points;

  const RecorderState({
    required this.status,
    required this.elapsed,
    required this.distanceKm,
    required this.paceSecPerKm,
    required this.points,
  });

  static const idle = RecorderState(
    status: RecorderStatus.idle,
    elapsed: Duration.zero,
    distanceKm: 0,
    paceSecPerKm: 0,
    points: [],
  );

  RecorderState copyWith({
    RecorderStatus? status,
    Duration? elapsed,
    double? distanceKm,
    double? paceSecPerKm,
    List<WorkoutPoint>? points,
  }) {
    return RecorderState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      distanceKm: distanceKm ?? this.distanceKm,
      paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
      points: points ?? this.points,
    );
  }
}

class WorkoutRecorder extends ChangeNotifier {
  WorkoutRecorder(this._repo);

  final WorkoutRepository _repo;

  RecorderState _state = RecorderState.idle;
  RecorderState get state => _state;

  Stopwatch? _sw;
  Timer? _ticker;
  StreamSubscription<Position>? _posSub;

  DateTime? _startedAt;
  DateTime? _endedAt;

  double _distanceMeters = 0;
  double _paceEma = 0; // exponential moving avg sec/km

  Future<void> start() async {
    if (_state.status != RecorderStatus.idle) return;

    await _ensureLocationReady();

    _startedAt = DateTime.now();
    _distanceMeters = 0;
    _paceEma = 0;

    _sw = Stopwatch()..start();

    _state = const RecorderState(
      status: RecorderStatus.running,
      elapsed: Duration.zero,
      distanceKm: 0,
      paceSecPerKm: 0,
      points: [],
    );
    notifyListeners();

    _startTicker();
    _startLocationStream();
  }

  void pause() {
    if (_state.status != RecorderStatus.running) return;
    _sw?.stop();
    _state = _state.copyWith(status: RecorderStatus.paused);
    notifyListeners();
  }

  void resume() {
    if (_state.status != RecorderStatus.paused) return;
    _sw?.start();
    _state = _state.copyWith(status: RecorderStatus.running);
    notifyListeners();
  }

  Future<WorkoutSession> stopAndBuildSession() async {
    if (_state.status == RecorderStatus.idle) {
      throw Exception('Recorder is idle.');
    }

    _endedAt = DateTime.now();
    _sw?.stop();
    _ticker?.cancel();
    _ticker = null;

    await _posSub?.cancel();
    _posSub = null;

    final elapsed = _sw?.elapsed ?? _state.elapsed;
    final distanceKm = _distanceMeters / 1000.0;
    final pace = _computePace(elapsed, distanceKm);

    final session = WorkoutSession(
      id: _makeId(_startedAt ?? DateTime.now()),
      startedAt: _startedAt ?? DateTime.now(),
      endedAt: _endedAt ?? DateTime.now(),
      elapsed: elapsed,
      distanceKm: distanceKm,
      paceSecPerKm: pace,
      points: List.unmodifiable(_state.points),
    );

    _state = _state.copyWith(
      status: RecorderStatus.idle,
      elapsed: elapsed,
      distanceKm: distanceKm,
      paceSecPerKm: pace,
    );
    notifyListeners();

    return session;
  }

  Future<void> saveSession(WorkoutSession session) async {
    await _repo.save(session);
  }

  void reset() {
    _sw = null;
    _ticker?.cancel();
    _ticker = null;
    _posSub?.cancel();
    _posSub = null;
    _startedAt = null;
    _endedAt = null;
    _distanceMeters = 0;
    _paceEma = 0;
    _state = RecorderState.idle;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_state.status == RecorderStatus.running ||
          _state.status == RecorderStatus.paused) {
        final elapsed = _sw?.elapsed ?? Duration.zero;
        _state = _state.copyWith(elapsed: elapsed);
        notifyListeners();
      }
    });
  }

  void _startLocationStream() {
    _posSub?.cancel();

    if (kIsDevWebTracking) {
      Timer.periodic(const Duration(seconds: 1), (_) {
        if (_state.status != RecorderStatus.running) return;

        _distanceMeters += 2.5; // simulate 2.5 m/s
        final elapsed = _sw!.elapsed;
        final distanceKm = _distanceMeters / 1000;

        _state = _state.copyWith(
          distanceKm: distanceKm,
          paceSecPerKm: _computePace(elapsed, distanceKm),
        );

        notifyListeners();
      });
      return;
    }

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        if (_state.status != RecorderStatus.running) return;

        if (pos.accuracy > 35) return;

        final p = WorkoutPoint(
          lat: pos.latitude,
          lon: pos.longitude,
          accuracy: pos.accuracy,
          ts: DateTime.now(),
        );

        final pts = List<WorkoutPoint>.from(_state.points)..add(p);

        if (pts.length >= 2) {
          final a = pts[pts.length - 2];
          final b = pts[pts.length - 1];

          final d = Geolocator.distanceBetween(
            a.lat,
            a.lon,
            b.lat,
            b.lon,
          );

          // critical filters: min 2m, max 50m per segment
          if (d > 2 && d < 50) {
            _distanceMeters += d;
          }
        }

        final elapsed = _sw?.elapsed ?? Duration.zero;
        final distanceKm = _distanceMeters / 1000.0;
        final paceNow = _computePace(elapsed, distanceKm);
        _paceEma = _ema(_paceEma == 0 ? paceNow : _paceEma, paceNow, 0.12);

        _state = _state.copyWith(
          points: pts,
          distanceKm: distanceKm,
          paceSecPerKm: _paceEma,
        );
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Location stream error: $e');
      },
    );
  }

  double _computePace(Duration elapsed, double distanceKm) {
    // Don’t compute pace before 100m to avoid noisy values
    if (distanceKm < 0.1) return 0;
    return elapsed.inSeconds / max(distanceKm, 0.001);
  }

  double _ema(double prev, double next, double alpha) =>
      (alpha * next) + ((1 - alpha) * prev);

  Future<void> _ensureLocationReady() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }

  String _makeId(DateTime dt) {
    final r = Random().nextInt(1 << 32).toRadixString(16);
    return '${dt.millisecondsSinceEpoch}_$r';
  }
}
