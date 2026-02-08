import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../workout/timer/workout_timer_controller.dart';
import '../data/workout_repository.dart';
import '../domain/workout_session.dart';

/// Manages the lifecycle of a workout recording and persists to Supabase.
class WorkoutSessionController extends ChangeNotifier {
  WorkoutSessionController({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client,
        _repo = WorkoutRepository(client ?? Supabase.instance.client) {
    _timer = WorkoutTimerController(onTick: _handleTick);
  }

  final SupabaseClient _db;
  final WorkoutRepository _repo;
  late final WorkoutTimerController _timer;

  WorkoutSession _session = const WorkoutSession.idle();
  bool _saving = false;

  WorkoutSession get session => _session;
  bool get isSaving => _saving;
  Duration get elapsed => _timer.elapsed;

  /// Starts a new workout; ignores if already recording/paused/finishing.
  Future<void> start(TickerProvider vsync, {String sportType = 'run'}) async {
    if (_session.status == WorkoutStatus.recording ||
        _session.status == WorkoutStatus.paused ||
        _session.status == WorkoutStatus.finishing) {
      return;
    }

    final user = _db.auth.currentUser;
    if (user == null) {
      throw const AuthException('Não autenticado');
    }

    final startedAt = DateTime.now().toUtc();

    final workoutId = await _repo.createDraftWorkout(
      userId: user.id,
      sportType: sportType,
    );

    _session = WorkoutSession(
      workoutId: workoutId,
      status: WorkoutStatus.recording,
      startedAt: startedAt,
      elapsed: Duration.zero,
      sportType: sportType,
    );

    _timer.reset();
    _timer.start(vsync);
    notifyListeners();
  }

  void pause() {
    if (_session.status != WorkoutStatus.recording) return;
    _timer.pause();
    _session = _session.copyWith(
      status: WorkoutStatus.paused,
      elapsed: _timer.elapsed,
    );
    notifyListeners();
  }

  void resume() {
    if (_session.status != WorkoutStatus.paused) return;
    _timer.resume();
    _session = _session.copyWith(status: WorkoutStatus.recording);
    notifyListeners();
  }

  /// Finalizes workout, writes duration/ended_at/status=finished.
  Future<void> finish() async {
    if (_session.status != WorkoutStatus.recording &&
        _session.status != WorkoutStatus.paused) {
      return;
    }
    if (_saving) return;
    _saving = true;
    _session = _session.copyWith(status: WorkoutStatus.finishing);
    notifyListeners();

    try {
      _timer.pause();
      final duration = _timer.elapsed;
      final endedAt = DateTime.now().toUtc();

      await _repo.finishWorkout(
        workoutId: _session.workoutId!,
        durationMs: duration.inMilliseconds,
        endedAt: endedAt,
      );
    } finally {
      _saving = false;
      _timer.reset();
      _session = const WorkoutSession.idle();
      notifyListeners();
    }
  }

  /// Marks workout as discarded and resets local state.
  Future<void> discard() async {
    if (_session.workoutId == null) return;
    if (_saving) return;
    _saving = true;
    notifyListeners();
    try {
      await _repo.discardWorkout(workoutId: _session.workoutId!);
    } finally {
      _saving = false;
      _timer.reset();
      _session = const WorkoutSession.idle();
      notifyListeners();
    }
  }

  void _handleTick(Duration duration) {
    if (_session.status == WorkoutStatus.recording ||
        _session.status == WorkoutStatus.paused) {
      _session = _session.copyWith(elapsed: duration);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }
}
