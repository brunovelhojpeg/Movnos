import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workout_metrics_notifier.dart';

final workoutMetricsProvider =
    ChangeNotifierProvider<WorkoutMetricsNotifier>((ref) {
  return WorkoutMetricsNotifier();
});
