import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileStatus {
  final bool hasHeight;
  const ProfileStatus({required this.hasHeight});
}

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfileStatus> getProfileStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const ProfileStatus(hasHeight: false);

    final row = await _supabase
        .from('profiles')
        .select('height_cm')
        .eq('user_id', user.id)
        .maybeSingle();

    final height = row == null ? null : row['height_cm'] as int?;
    return ProfileStatus(hasHeight: height != null && height > 0);
  }

  Future<void> setHeightCm(int heightCm) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated');

    // UPSERT: cria o profile se não existir, ou atualiza se já existir.
    await _supabase.from('profiles').upsert({
      'user_id': user.id,
      'height_cm': heightCm,
    }, onConflict: 'user_id');
  }

  Future<double?> getMyHeightCm() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final row = await _supabase
        .from('profiles')
        .select('height_cm')
        .eq('user_id', user.id)
        .maybeSingle();

    final h = row == null ? null : row['height_cm'] as num?;
    return h?.toDouble();
  }
}
