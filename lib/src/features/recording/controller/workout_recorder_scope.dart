import 'package:flutter/widgets.dart';

import '../data/workout_repository.dart';
import 'workout_recorder.dart';

class WorkoutRecorderScope extends InheritedWidget {
  WorkoutRecorderScope({super.key, required super.child})
      : recorder = WorkoutRecorder(HybridWorkoutRepository());

  final WorkoutRecorder recorder;

  static WorkoutRecorder of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorkoutRecorderScope>()!.recorder;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
