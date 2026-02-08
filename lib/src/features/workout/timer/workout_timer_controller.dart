import 'package:flutter/scheduler.dart';

typedef OnTick = void Function(Duration elapsed);

/// Controls a workout timer backed by [Stopwatch] and a [Ticker].
class WorkoutTimerController {
  WorkoutTimerController({required this.onTick});

  final Stopwatch _stopwatch = Stopwatch();
  final OnTick onTick;
  Ticker? _ticker;

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsed => _stopwatch.elapsed;

  /// Starts the timer; safe to call once per lifecycle.
  void start(TickerProvider vsync) {
    _ensureTicker(vsync);
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker!.start();
  }

  void pause() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    _ticker?.stop();
    onTick(_stopwatch.elapsed); // emit final value at pause
  }

  void resume() {
    if (_ticker == null || _stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker!.start();
  }

  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _ticker?.stop();
    onTick(Duration.zero);
  }

  void stop() {
    _stopwatch.stop();
    _ticker?.stop();
  }

  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    _stopwatch.stop();
  }

  void _ensureTicker(TickerProvider vsync) {
    _ticker ??= vsync.createTicker((_) => onTick(_stopwatch.elapsed));
  }
}
