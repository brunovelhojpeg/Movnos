import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/workout_repository.dart';
import '../domain/workout_session.dart';

/// Lightweight controller to manage workout recording state and persistence.
class WorkoutRecordController extends ChangeNotifier {
  WorkoutRecordController(this._db) : _repo = WorkoutRepository(_db);

  final SupabaseClient _db;
  final WorkoutRepository _repo;

  WorkoutSession _session = const WorkoutSession.idle();
  WorkoutSession get session => _session;

  bool _busy = false;
  bool get busy => _busy;

  /// Called by UI layer after timer ticks.
  void onTimerTick(Duration elapsed) => setElapsed(elapsed);

  /// Called by timer ticks to keep elapsed time in sync.
  void setElapsed(Duration elapsed) {
    if (_session.status == WorkoutStatus.recording ||
        _session.status == WorkoutStatus.paused) {
      _session = _session.copyWith(elapsed: elapsed);
      notifyListeners();
    }
  }

  Future<void> start({String sportType = 'run'}) async {
    if (_busy) return;
    if (_session.status == WorkoutStatus.recording ||
        _session.status == WorkoutStatus.paused) return;

    final user = _db.auth.currentUser;
    if (user == null) return;

    _busy = true;
    notifyListeners();

    try {
      final id =
          await _repo.createDraftWorkout(userId: user.id, sportType: sportType);
      _session = WorkoutSession(
        workoutId: id,
        status: WorkoutStatus.recording,
        startedAt: DateTime.now().toUtc(),
        elapsed: Duration.zero,
        sportType: sportType,
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void pause() {
    if (_session.status != WorkoutStatus.recording) return;
    _session = _session.copyWith(status: WorkoutStatus.paused);
    notifyListeners();
  }

  void resume() {
    if (_session.status != WorkoutStatus.paused) return;
    _session = _session.copyWith(status: WorkoutStatus.recording);
    notifyListeners();
  }

  Future<void> finish() async {
    if (_busy) return;
    if (!(_session.status == WorkoutStatus.recording ||
        _session.status == WorkoutStatus.paused)) return;
    final id = _session.workoutId;
    if (id == null) return;

    _busy = true;
    _session = _session.copyWith(status: WorkoutStatus.finishing);
    notifyListeners();

    try {
      await _repo.finishWorkout(
        workoutId: id,
        durationMs: _session.elapsed.inMilliseconds,
        endedAt: DateTime.now().toUtc(),
      );
      _session = const WorkoutSession.idle();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> discard() async {
    if (_busy) return;
    final id = _session.workoutId;
    if (id == null) {
      _session = const WorkoutSession.idle();
      notifyListeners();
      return;
    }

    _busy = true;
    notifyListeners();
    try {
      await _repo.discardWorkout(workoutId: id);
      _session = const WorkoutSession.idle();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
