import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/check_in.dart';
import '../services/check_in_service.dart';

final _supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final checkInServiceProvider = Provider<CheckInService>((ref) {
  return CheckInService(ref.watch(_supabaseProvider));
});

final myCheckInsProvider = FutureProvider<List<CheckIn>>((ref) async {
  final svc = ref.watch(checkInServiceProvider);
  return svc.listMyCheckIns(limit: 60);
});
