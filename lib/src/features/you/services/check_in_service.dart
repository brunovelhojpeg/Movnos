import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/check_in.dart';

class CheckInService {
  final SupabaseClient _db;
  CheckInService(this._db);

  Future<List<CheckIn>> listMyCheckIns({int limit = 50}) async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Sem sessão.');

    final rows = await _db
        .from('checkins')
        .select('id, created_at, weight_kg, waist_cm, hip_cm')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .map((e) => CheckIn.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCheckIn({
    required double weightKg,
    required double waistCm,
    required double hipCm,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Sem sessão.');

    await _db.from('checkins').insert({
      'user_id': user.id,
      'weight_kg': weightKg,
      'waist_cm': waistCm,
      'hip_cm': hipCm,
    });
  }
}
