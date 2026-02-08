import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de ponto da rota
class RoutePoint {
  final double lat;
  final double lng;
  final DateTime timestamp;

  const RoutePoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory RoutePoint.fromPosition(Position p) {
    return RoutePoint(
      lat: p.latitude,
      lng: p.longitude,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    't': timestamp.toIso8601String(),
  };
}

/// Estado do treino em tempo real
class WorkoutState {
  final bool isRecording;
  final bool isPaused;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final double distanceMeters;
  final double paceSecPerKm;
  final List<RoutePoint> route;
  final Position? currentPosition;

  const WorkoutState({
    this.isRecording = false,
    this.isPaused = false,
    this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.distanceMeters = 0,
    this.paceSecPerKm = 0,
    this.route = const [],
    this.currentPosition,
  });

  WorkoutState copyWith({
    bool? isRecording,
    bool? isPaused,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    double? distanceMeters,
    double? paceSecPerKm,
    List<RoutePoint>? route,
    Position? currentPosition,
  }) {
    return WorkoutState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
      route: route ?? this.route,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

class RecordService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  WorkoutState _state = const WorkoutState();
  WorkoutState get state => _state;

  StreamSubscription<Position>? _gpsSubscription;
  Timer? _timer;
  Position? _lastPosition;

  // ==================== PERMISSÕES ====================

  Future<void> ensurePermissions() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Localização desativada. Ative o GPS.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão negada permanentemente. Ative nas configurações.',
      );
    }
  }

  // ==================== START ====================

  Future<void> start() async {
    if (_state.isRecording) return;

    await ensurePermissions();

    // Posição inicial
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _state = WorkoutState(
      isRecording: true,
      isPaused: false,
      startedAt: DateTime.now().toUtc(),
      route: [RoutePoint.fromPosition(pos)],
      currentPosition: pos,
    );

    _lastPosition = pos;

    // Stream de GPS
    _startGpsTracking();

    // Timer para atualizar cronômetro a cada segundo
    _startTimer();

    notifyListeners();
  }

  void _startGpsTracking() {
    _gpsSubscription?.cancel();
    _gpsSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // atualiza a cada 5m
          ),
        ).listen((position) {
          if (!_state.isRecording || _state.isPaused) return;

          _updatePosition(position);
        });
  }

  void _updatePosition(Position position) {
    double newDistance = _state.distanceMeters;

    // Calcular distância desde último ponto
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Filtro contra saltos de GPS (max 200m entre pontos)
      if (distance > 0 && distance < 200) {
        newDistance += distance;
      }
    }

    _lastPosition = position;

    _state = _state.copyWith(
      distanceMeters: newDistance,
      paceSecPerKm: _calculatePace(newDistance, _state.durationSeconds),
      route: [..._state.route, RoutePoint.fromPosition(position)],
      currentPosition: position,
    );

    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_state.isRecording || _state.isPaused) return;

      final elapsed = DateTime.now().toUtc().difference(_state.startedAt!);

      _state = _state.copyWith(
        durationSeconds: elapsed.inSeconds,
        paceSecPerKm: _calculatePace(_state.distanceMeters, elapsed.inSeconds),
      );

      notifyListeners();
    });
  }

  double _calculatePace(double meters, int seconds) {
    final km = meters / 1000.0;
    if (km <= 0 || seconds <= 0) return 0;
    return seconds / km; // segundos por km
  }

  // ==================== PAUSE / RESUME ====================

  void pause() {
    if (!_state.isRecording || _state.isPaused) return;

    _state = _state.copyWith(isPaused: true);
    _gpsSubscription?.pause();
    notifyListeners();
  }

  void resume() {
    if (!_state.isRecording || !_state.isPaused) return;

    _state = _state.copyWith(isPaused: false);
    _gpsSubscription?.resume();
    notifyListeners();
  }

  // ==================== STOP ====================

  Future<void> stop() async {
    if (!_state.isRecording) return;

    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    _timer?.cancel();
    _timer = null;

    _state = _state.copyWith(
      isRecording: false,
      isPaused: false,
      endedAt: DateTime.now().toUtc(),
    );

    notifyListeners();
  }

  // ==================== SALVAR NO SUPABASE ====================

  Future<String> saveActivity({required String activityTypeId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated');

    if (_state.startedAt == null) {
      throw Exception('Treino não foi iniciado');
    }

    final endTime = _state.endedAt ?? DateTime.now().toUtc();

    // 1. Criar activity
    final inserted = await _supabase
        .from('activities')
        .insert({
          'user_id': user.id,
          'activity_type_id': activityTypeId,
          'started_at': _state.startedAt!.toIso8601String(),
          'ended_at': endTime.toIso8601String(),
          'duration_seconds': _state.durationSeconds,
          'distance_meters': _state.distanceMeters,
          'visibility': 'public',
          'is_manual': false,
        })
        .select('id')
        .single();

    final activityId = inserted['id'] as String;

    // 2. Salvar rota (se tiver pontos)
    if (_state.route.isNotEmpty) {
      final routePoints = _state.route
          .map((p) => {...p.toJson(), 'activity_id': activityId})
          .toList();

      await _supabase.from('route_points').insert(routePoints);
    }

    // 3. Marcar como completo
    await _supabase.rpc(
      'record_activity_complete',
      params: {'p_activity_id': activityId},
    );

    return activityId;
  }

  /// Compat: criação manual usada pelo cronômetro simples.
  Future<String> createActivity({
    required String activityTypeId,
    required DateTime startedAtUtc,
    required DateTime endedAtUtc,
    required int durationSeconds,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated');

    final inserted = await _supabase
        .from('activities')
        .insert({
          'user_id': user.id,
          'activity_type_id': activityTypeId,
          'started_at': startedAtUtc.toIso8601String(),
          'ended_at': endedAtUtc.toIso8601String(),
          'duration_seconds': durationSeconds,
          'visibility': 'public',
          'is_manual': false,
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  Future<void> recordActivityComplete({required String activityId}) async {
    await _supabase.rpc(
      'record_activity_complete',
      params: {'p_activity_id': activityId},
    );
  }

  // ==================== RESET ====================

  void reset() {
    _gpsSubscription?.cancel();
    _timer?.cancel();
    _state = const WorkoutState();
    _lastPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // ==================== FETCH ACTIVITY TYPES ====================

  Future<List<ActivityType>> fetchActivityTypes() async {
    final rows = await _supabase
        .from('activity_types')
        .select('id,display_name')
        .eq('is_enabled', true)
        .order('sort_order', ascending: true);

    return (rows as List)
        .map((e) => ActivityType.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

// ==================== ACTIVITY TYPE ====================

class ActivityType {
  final String id;
  final String displayName;

  const ActivityType({required this.id, required this.displayName});

  static ActivityType fromJson(Map<String, dynamic> json) {
    return ActivityType(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
    );
  }
}
