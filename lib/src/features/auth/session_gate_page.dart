import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shell/shell_page.dart';
import 'login_page.dart';

class SessionGatePage extends StatelessWidget {
  const SessionGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (!snapshot.hasData) {
          return session == null ? const LoginPage() : const ShellPage();
        }

        return session == null ? const LoginPage() : const ShellPage();
      },
    );
  }
}
