import 'dart:async';

import 'package:flutter/foundation.dart';

/// Simple stopwatch-based timer that notifies listeners at ~5 Hz.
class RunTimer extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  bool get isRunning => _stopwatch.isRunning;

  void start() {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();

    _ticker ??= Timer.periodic(
      const Duration(milliseconds: 200),
      (_) {
        _elapsed = _stopwatch.elapsed;
        notifyListeners();
      },
    );
  }

  void pause() {
    if (!_stopwatch.isRunning) return;

    _stopwatch.stop();
    notifyListeners();
  }

  void stop() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
