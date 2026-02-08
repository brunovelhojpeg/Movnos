enum WorkoutStatus { idle, recording, paused, finishing }

class WorkoutSession {
  final String? workoutId;
  final WorkoutStatus status;
  final DateTime? startedAt;
  final Duration elapsed;
  final String sportType;

  const WorkoutSession({
    required this.workoutId,
    required this.status,
    required this.startedAt,
    required this.elapsed,
    required this.sportType,
  });

  const WorkoutSession.idle()
      : workoutId = null,
        status = WorkoutStatus.idle,
        startedAt = null,
        elapsed = Duration.zero,
        sportType = 'run';

  WorkoutSession copyWith({
    String? workoutId,
    WorkoutStatus? status,
    DateTime? startedAt,
    Duration? elapsed,
    String? sportType,
  }) {
    return WorkoutSession(
      workoutId: workoutId ?? this.workoutId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      elapsed: elapsed ?? this.elapsed,
      sportType: sportType ?? this.sportType,
    );
  }
}
