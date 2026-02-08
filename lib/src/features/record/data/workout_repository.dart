import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  WorkoutRepository(this._db);
  final SupabaseClient _db;

  Future<String> createDraftWorkout({
    required String userId,
    required String sportType,
  }) async {
    final row = await _db
        .from('workouts')
        .insert({
          'user_id': userId,
          'status': 'draft',
          'sport_type': sportType,
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> finishWorkout({
    required String workoutId,
    required int durationMs,
    required DateTime endedAt,
  }) async {
    await _db.from('workouts').update({
      'status': 'finished',
      'duration_ms': durationMs,
      'ended_at': endedAt.toIso8601String(),
    }).eq('id', workoutId);
  }

  Future<void> discardWorkout({required String workoutId}) async {
    await _db
        .from('workouts')
        .update({'status': 'discarded'})
        .eq('id', workoutId);
  }
}
