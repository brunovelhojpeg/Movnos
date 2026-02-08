import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Global-ish ticker-backed timer that notifies listeners every tick.
class WorkoutTimerNotifier extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Ticker? _ticker;

  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  bool get isRunning => _stopwatch.isRunning;

  void start(TickerProvider vsync) {
    if (_ticker == null) {
      _stopwatch.start();
      _ticker = vsync.createTicker((_) {
        _elapsed = _stopwatch.elapsed;
        notifyListeners();
      })..start();
    } else {
      resume();
    }
  }

  void pause() {
    _stopwatch.stop();
    _ticker?.stop();
    notifyListeners();
  }

  void resume() {
    if (_ticker == null) return;
    _stopwatch.start();
    _ticker?.start();
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void disposeTicker() {
    _ticker?.dispose();
    _ticker = null;
  }

  @override
  void dispose() {
    disposeTicker();
    super.dispose();
  }
}
