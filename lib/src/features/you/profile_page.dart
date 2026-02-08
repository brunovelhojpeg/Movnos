import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/profile_service.dart';
import 'checkin_add_page.dart';
import 'models/checkin.dart';
import 'providers/you_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _goAddCheckIn(BuildContext context, WidgetRef ref) async {
    final ok = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CheckInAddPage()));
    if (ok == true) {
      ref.invalidate(myCheckInsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinsAsync = ref.watch(myCheckInsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartilhar (placeholder)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscar (placeholder)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações (placeholder)')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _HeaderCard(
            name: 'Bruno Azevedo',
            location: 'Rio Grande do Sul, Brasil',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR Code (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Compartilhar meu QR code'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Editar perfil (placeholder)'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SportChip(
                icon: Icons.directions_run,
                label: 'Corrida',
                selected: true,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _SportChip(
                icon: Icons.directions_walk,
                label: 'Caminhada',
                selected: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          checkinsAsync.when(
            data: (list) => FutureBuilder<double?>(
              future: ProfileService().getMyHeightCm(),
              builder: (context, snap) {
                final heightCm = snap.data;
                return _ThisWeekCard(
                  checkins: list,
                  heightCm: heightCm,
                  onAddCheckIn: () => _goAddCheckIn(context, ref),
                );
              },
            ),
            loading: () => const _CardSkeleton(title: 'Carregando dados...'),
            error: (e, _) => _CardError(
              title: 'Erro ao carregar dados',
              subtitle: '$e',
              onRetry: () => ref.invalidate(myCheckInsProvider),
            ),
          ),
          const SizedBox(height: 12),
          _NavRow(
            icon: Icons.show_chart,
            title: 'Atividades',
            subtitle: 'Ver atividades e detalhes',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Atividades (placeholder)')),
              );
            },
          ),
          const Divider(height: 1),
          _NavRow(
            icon: Icons.bar_chart,
            title: 'Estatísticas',
            subtitle: 'Este ano: (placeholder)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estatísticas (placeholder)')),
              );
            },
          ),
          const Divider(height: 1),
          _NavRow(
            icon: Icons.alt_route,
            title: 'Rotas',
            subtitle: '—',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rotas (placeholder)')),
              );
            },
          ),
          const Divider(height: 1),
          _NavRow(
            icon: Icons.place_outlined,
            title: 'Segmentos',
            subtitle: '—',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Segmentos (placeholder)')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String location;

  const _HeaderCard({required this.name, required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 28, child: Icon(Icons.person)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  _MiniStat(label: 'Seguindo', value: '2'),
                  SizedBox(width: 18),
                  _MiniStat(label: 'Seguidores', value: '2'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
      ],
    );
  }
}

class _SportChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SportChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.deepOrange : Colors.grey.shade400;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThisWeekCard extends StatelessWidget {
  final List<CheckIn> checkins;
  final double? heightCm;
  final VoidCallback onAddCheckIn;

  const _ThisWeekCard({
    required this.checkins,
    required this.heightCm,
    required this.onAddCheckIn,
  });

  double? _imcFromLast() {
    if (heightCm == null) return null;
    if (checkins.isEmpty) return null;
    final h = heightCm! / 100.0;
    return checkins.first.weightKg / (h * h);
  }

  @override
  Widget build(BuildContext context) {
    final last = checkins.isNotEmpty ? checkins.first : null;
    final imc = _imcFromLast();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta semana',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _WeekStat(
                  title: 'Peso',
                  value: last != null
                      ? '${last.weightKg.toStringAsFixed(1)} kg'
                      : '—',
                ),
                const SizedBox(width: 18),
                _WeekStat(
                  title: 'Cintura',
                  value: last != null
                      ? '${last.waistCm.toStringAsFixed(1)} cm'
                      : '—',
                ),
                const SizedBox(width: 18),
                _WeekStat(
                  title: 'IMC',
                  value: imc != null ? imc.toStringAsFixed(1) : '—',
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(height: 120, child: _SimpleLineChart(checkins: checkins)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddCheckIn,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar check-in (peso/cintura/quadril)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String title;
  final String value;
  const _WeekStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<CheckIn> checkins;
  const _SimpleLineChart({required this.checkins});

  @override
  Widget build(BuildContext context) {
    final points = checkins.take(12).toList().reversed.toList();
    if (points.length < 2) {
      return Center(
        child: Text(
          'Sem dados suficientes',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].weightKg));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final String title;
  const _CardSkeleton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
    );
  }
}

class _CardError extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _CardError({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
