import 'package:supabase_flutter/supabase_flutter.dart';

class TrainingPlan {
  final String id;
  final String status;
  final DateTime createdAt;

  const TrainingPlan({
    required this.id,
    required this.status,
    required this.createdAt,
  });

  static TrainingPlan fromJson(Map<String, dynamic> j) {
    return TrainingPlan(
      id: j['id'] as String,
      status: j['status'] as String,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }
}

class PlanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TrainingPlan>> fetchMyPlans() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated');

    final rows = await _supabase
        .from('training_plans')
        .select('id, status, created_at')
        .eq('student_user_id', user.id)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => TrainingPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
