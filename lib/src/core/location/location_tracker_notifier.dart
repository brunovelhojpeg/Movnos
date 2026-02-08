import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Tracks distance and speed using Geolocator with simple spike filtering.
class LocationTrackerNotifier extends ChangeNotifier {
  StreamSubscription<Position>? _sub;

  Position? _last;
  double _distanceMeters = 0;
  double get distanceMeters => _distanceMeters;

  double _currentSpeedMps = 0;
  double get currentSpeedMps => _currentSpeedMps;

  bool _tracking = false;
  bool get tracking => _tracking;

  String? _error;
  String? get error => _error;

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _error = 'Serviço de localização desativado';
      notifyListeners();
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      _error = 'Permissão de localização negada';
      notifyListeners();
      return false;
    }
    if (perm == LocationPermission.deniedForever) {
      _error = 'Permissão de localização bloqueada (Ajustes)';
      notifyListeners();
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> start() async {
    if (_tracking) return;

    final ok = await _ensurePermission();
    if (!ok) return;

    _tracking = true;
    _error = null;
    notifyListeners();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // only emit if moved ~5m
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        _currentSpeedMps =
            (pos.speed.isFinite && pos.speed > 0) ? pos.speed : 0;

        if (_last != null) {
          final d = _haversineMeters(
            _last!.latitude,
            _last!.longitude,
            pos.latitude,
            pos.longitude,
          );

          // Filter out GPS spikes
          if (d >= 1 && d <= 50) {
            _distanceMeters += d;
          }
        }

        _last = pos;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Erro de GPS: $e';
        notifyListeners();
      },
    );
  }

  Future<void> stop() async {
    _tracking = false;
    await _sub?.cancel();
    _sub = null;
    notifyListeners();
  }

  void reset() {
    _last = null;
    _distanceMeters = 0;
    _currentSpeedMps = 0;
    _error = null;
    notifyListeners();
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // earth radius meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * pi / 180.0;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
