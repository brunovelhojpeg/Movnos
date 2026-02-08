import 'package:flutter/material.dart';

import '../../routing/routes.dart';
import '../../theme/app_theme.dart';
import '../../ui/strava_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movnos'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.go(AppRoutes.profile),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.go(AppRoutes.inbox),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Seção 1: seleção de treinos (carrossel)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StravaSectionHeader(
              title: 'Seleção de treinos',
              chip: 'NOVIDADE',
              action: 'Ver todos',
              onAction: () => context.go(AppRoutes.workoutPicks),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.92,
                child: _WorkoutPickCard(
                  title: 'Easy Conversational Run',
                  subtitle: 'Mantenha consistência com um treino leve...',
                  duration: '1h 20m',
                  onTap: () => context.go(
                    AppRoutes.workoutPickDetails,
                    args: {'title': 'Easy Conversational Run'},
                  ),
                ),
              ),
            ),
          ),

          // Seção 2: previsões / tempos (painel verde)
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go(AppRoutes.predictions),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2E2B),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _BadgeTime(km: '5', time: '24:57'),
                    _BadgeTime(km: '10', time: '51:52'),
                    _BadgeTime(km: '21', time: '1:55:41'),
                    _BadgeTime(km: '42', time: '3:58:09'),
                  ],
                ),
              ),
            ),
          ),

          // Seção 3: upsell assinante (card)
          StravaCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.stravaOrange,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suas previsões estão aqui',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Assine para ver seus tempos estimados com previsões de desempenho.',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Seção 4: Feed (atividade da comunidade) — placeholder
          StravaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFE5E7EB),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BRUNA MONTEIRO',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '4 de fevereiro de 2026 • Amazfit • Lajeado, RS',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'VAMO PRO CORRE',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Metric(label: 'Distância', value: '3,77 km'),
                    _Metric(label: 'Ritmo', value: '7:45 /km'),
                    _Metric(label: 'Tempo', value: '29min 16s'),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Mapa/Trajeto (placeholder)',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _WorkoutPickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final VoidCallback onTap;
  const _WorkoutPickCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.stravaOrange, Color(0xFFFF7A45)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeTime extends StatelessWidget {
  final String km;
  final String time;
  const _BadgeTime({required this.km, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$km km',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
