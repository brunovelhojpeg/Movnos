import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Timer notifier that survives tab switches and follows recording state.
class WorkoutTimerNotifier extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Ticker? _ticker;

  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  bool get isRunning => _stopwatch.isRunning;

  /// Call once from a widget that has a [TickerProvider] (e.g., RecordPage).
  void attach(TickerProvider vsync) {
    // Only create ticker once; survives tab switches.
    _ticker ??= vsync.createTicker((_) {
      if (_stopwatch.isRunning) {
        _elapsed = _stopwatch.elapsed;
        notifyListeners();
      }
    });
  }

  void start() {
    if (_ticker == null) return;
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker!.start();
    notifyListeners();
  }

  void pause() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    notifyListeners();
  }

  void resume() {
    if (_ticker == null) return;
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker!.start();
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void detach() {
    // Do NOT dispose ticker; we want timer state to survive navigation.
    _ticker?.stop();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}
