import 'dart:convert';

import 'workout_point.dart';

class WorkoutSession {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration elapsed;
  final double distanceKm;
  final double paceSecPerKm;
  final List<WorkoutPoint> points;

  const WorkoutSession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.elapsed,
    required this.distanceKm,
    required this.paceSecPerKm,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'elapsedMs': elapsed.inMilliseconds,
        'distanceKm': distanceKm,
        'paceSecPerKm': paceSecPerKm,
        'points': points.map((p) => p.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  static WorkoutSession fromJson(Map<String, dynamic> j) => WorkoutSession(
        id: j['id'] as String,
        startedAt: DateTime.parse(j['startedAt'] as String),
        endedAt: DateTime.parse(j['endedAt'] as String),
        elapsed: Duration(milliseconds: (j['elapsedMs'] as num).round()),
        distanceKm: (j['distanceKm'] as num).toDouble(),
        paceSecPerKm: (j['paceSecPerKm'] as num).toDouble(),
        points: (j['points'] as List)
            .map((e) => WorkoutPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
