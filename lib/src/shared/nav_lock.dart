/// Simple lock to prevent double navigation taps.
mixin NavLock {
  bool _locked = false;
  bool get isLocked => _locked;

  Future<T?> runLocked<T>(Future<T> Function() action) async {
    if (_locked) return null;
    _locked = true;
    try {
      return await action();
    } finally {
      _locked = false;
    }
  }
}
