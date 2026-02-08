import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../features/auth/auth_gate.dart';
import '../features/auth/login_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/shell_page.dart';
import '../ui/placeholder_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? AppRoutes.home;

    switch (name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthGate(
            child: LoginPage(),
          ),
        );
      // Shell + tabs (protected)
      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: const ShellPage(initialIndex: 0),
          ),
        );
      case AppRoutes.maps:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: const ShellPage(initialIndex: 1),
          ),
        );
      case AppRoutes.record:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: const ShellPage(
              initialIndex: 2,
            ),
          ),
        );
      case AppRoutes.groups:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: const ShellPage(initialIndex: 3),
          ),
        );
      case AppRoutes.you:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: const ShellPage(initialIndex: 4),
          ),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AuthGate(
            child: const SettingsPage(),
          ),
        );

      // Destinos do Home
      case AppRoutes.workoutPicks:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(
            title: 'Seleção de treinos',
            subtitle: 'Lista completa (placeholder).',
          ),
        );

      case AppRoutes.workoutPickDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final title = (args?['title'] as String?) ?? 'Treino';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PlaceholderPage(
            title: title,
            subtitle: 'Detalhe do treino (placeholder).',
          ),
        );

      case AppRoutes.predictions:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(
            title: 'Previsões',
            subtitle: 'Paywall/Assinatura entra aqui depois.',
          ),
        );

      case AppRoutes.activityDetails:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(
            title: 'Atividade',
            subtitle: 'Detalhe do post / treino (placeholder).',
          ),
        );

      // Top bar
      case AppRoutes.search:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(title: 'Buscar'),
        );
      case AppRoutes.inbox:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(title: 'Mensagens'),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(title: 'Notificações'),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlaceholderPage(title: 'Perfil'),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PlaceholderPage(
            title: 'Rota não encontrada',
            subtitle: 'Rota: $name',
          ),
        );
    }
  }
}
