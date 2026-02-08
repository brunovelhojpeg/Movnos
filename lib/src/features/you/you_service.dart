import 'package:supabase_flutter/supabase_flutter.dart';

class GamificationSummary {
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;

  const GamificationSummary({
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
  });

  static GamificationSummary empty() {
    return const GamificationSummary(
      totalXp: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  static GamificationSummary fromJson(Map<String, dynamic> j) {
    return GamificationSummary(
      totalXp: (j['total_xp'] as num?)?.toInt() ?? 0,
      level: (j['level'] as num?)?.toInt() ?? 1,
      currentStreak: (j['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (j['longest_streak'] as num?)?.toInt() ?? 0,
    );
  }
}

class BodyCheckinWithBmi {
  final String id;
  final DateTime measuredAt;
  final double weightKg;
  final double waistCm;
  final double hipCm;
  final double? bmi;

  const BodyCheckinWithBmi({
    required this.id,
    required this.measuredAt,
    required this.weightKg,
    required this.waistCm,
    required this.hipCm,
    required this.bmi,
  });

  static BodyCheckinWithBmi fromJson(Map<String, dynamic> j) {
    return BodyCheckinWithBmi(
      id: j['id'] as String,
      measuredAt: DateTime.parse(j['measured_at'] as String),
      weightKg: (j['weight_kg'] as num).toDouble(),
      waistCm: (j['waist_cm'] as num).toDouble(),
      hipCm: (j['hip_cm'] as num).toDouble(),
      bmi: j['bmi'] == null ? null : (j['bmi'] as num).toDouble(),
    );
  }
}

class YouService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _requireUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated');
    return user.id;
  }

  Future<GamificationSummary> fetchGamification() async {
    final userId = _requireUserId();

    final row = await _supabase
        .from('user_gamification')
        .select('total_xp, level, current_streak, longest_streak')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return GamificationSummary.empty();
    return GamificationSummary.fromJson(row);
  }

  Future<List<BodyCheckinWithBmi>> fetchCheckinsWithBmi() async {
    final userId = _requireUserId();

    final rows = await _supabase
        .from('v_body_checkins_with_bmi')
        .select('id, measured_at, weight_kg, waist_cm, hip_cm, bmi')
        .eq('user_id', userId)
        .order('measured_at', ascending: false);

    return (rows as List)
        .map((e) => BodyCheckinWithBmi.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> createCheckinAndReward({
    required double weightKg,
    required double waistCm,
    required double hipCm,
    DateTime? measuredAt,
  }) async {
    final userId = _requireUserId();
    final date = (measuredAt ?? DateTime.now()).toUtc();

    final inserted = await _supabase
        .from('body_checkins')
        .insert({
          'user_id': userId,
          'measured_at': date.toIso8601String().split('T').first,
          'weight_kg': weightKg,
          'waist_cm': waistCm,
          'hip_cm': hipCm,
        })
        .select('id')
        .single();

    final checkinId = inserted['id'] as String;

    await _supabase.rpc(
      'record_checkin_complete',
      params: {'p_checkin_id': checkinId},
    );
  }
}
