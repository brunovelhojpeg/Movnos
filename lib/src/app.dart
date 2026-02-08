import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movnos/l10n/gen/app_localizations.dart';
import 'package:movnos/src/features/auth/session_gate_page.dart';

import 'features/settings/settings_page.dart';
import 'ui/placeholder_page.dart';
import 'routing/app_router.dart';
import 'routing/app_routes.dart';
import 'theme/app_theme.dart';

class MovnosApp extends StatelessWidget {
  const MovnosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movnos',
      theme: AppTheme.light(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt'), Locale('pt', 'BR')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SessionGatePage(),
      routes: {
        '/settings': (_) => const SettingsPage(),
        '/you/body-metrics': (_) =>
            const PlaceholderPage(title: 'Métricas corporais'),
        '/you/training-stats': (_) =>
            const PlaceholderPage(title: 'Estatísticas de treino'),
      },
    );
  }
}
