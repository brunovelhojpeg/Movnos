import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workout_timer_notifier.dart';

/// Riverpod provider for the shared workout timer notifier.
final workoutTimerProvider = ChangeNotifierProvider<WorkoutTimerNotifier>(
  (ref) => WorkoutTimerNotifier(),
);
