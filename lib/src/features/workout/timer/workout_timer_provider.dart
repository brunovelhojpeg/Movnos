import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'workout_timer_controller.dart';

/// Exposes workout timer state via [ChangeNotifier].
class WorkoutTimerProvider extends ChangeNotifier {
  WorkoutTimerProvider() {
    _controller = WorkoutTimerController(onTick: _handleTick);
  }

  late final WorkoutTimerController _controller;
  Duration _elapsed = Duration.zero;

  Duration get elapsed => _elapsed;
  bool get isRunning => _controller.isRunning;

  /// Convenience alias matching older call sites.
  void init(TickerProvider vsync) => start(vsync);

  /// Initializes and starts the timer with a [TickerProvider].
  void start(TickerProvider vsync) {
    _controller.start(vsync);
  }

  void pause() {
    _controller.pause();
    _refreshElapsed();
  }

  void resume() {
    _controller.resume();
    _refreshElapsed();
  }

  void reset() {
    _controller.reset();
    _refreshElapsed();
  }

  void stop() {
    _controller.stop();
    _refreshElapsed();
  }

  void _handleTick(Duration duration) {
    _elapsed = duration;
    notifyListeners();
  }

  void _refreshElapsed() {
    _elapsed = _controller.elapsed;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
