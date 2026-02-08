import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/config/supabase_config.dart';

Future<void> tryDevAutologin() async {
  if (!kDebugMode) return; // avoid in release builds

  const devEmail = String.fromEnvironment('DEV_EMAIL', defaultValue: '');
  const devPass = String.fromEnvironment('DEV_PASS', defaultValue: '');
  if (devEmail.isEmpty || devPass.isEmpty) return;

  final supabase = Supabase.instance.client;
  if (supabase.auth.currentSession != null) return;

  try {
    await supabase.auth.signInWithPassword(
      email: devEmail,
      password: devPass,
    );
  } on AuthException catch (e) {
    debugPrint('Dev autologin falhou: ${e.message}');
  } catch (e) {
    debugPrint('Dev autologin falhou: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await tryDevAutologin();

  runApp(const ProviderScope(child: MovnosApp()));
}
