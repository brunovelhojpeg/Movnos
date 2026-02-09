class WorkoutPoint {
  final double lat;
  final double lon;
  final double accuracy;
  final DateTime ts;

  const WorkoutPoint({
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'accuracy': accuracy,
        'ts': ts.toIso8601String(),
      };

  static WorkoutPoint fromJson(Map<String, dynamic> j) => WorkoutPoint(
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
        accuracy: (j['accuracy'] as num).toDouble(),
        ts: DateTime.parse(j['ts'] as String),
      );
}
