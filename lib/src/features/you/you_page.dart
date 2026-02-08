import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/l10n/l10n.dart';
import '../../routing/app_routes.dart';
import '../auth/login_page.dart';

class YouPage extends StatefulWidget {
  const YouPage({super.key});

  @override
  State<YouPage> createState() => _YouPageState();
}

class _YouPageState extends State<YouPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  bool _saving = false;
  bool _checkedInToday = false;

  int _xpToday = 0;
  int _xpTotal = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  SupabaseClient get _db => Supabase.instance.client;

  DateTime get _today => DateTime.now();
  String get _todayIsoDate => DateFormat('yyyy-MM-dd').format(_today);

  Future<void> _loadTodayState() async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    try {
      final checkins = await _db
          .from('body_checkins')
          .select('id')
          .eq('user_id', user.id)
          .eq('checkin_date', _todayIsoDate)
          .limit(1);

      final start = DateTime(_today.year, _today.month, _today.day);
      final startIso = start.toIso8601String();
      final endIso = start.add(const Duration(days: 1)).toIso8601String();

      final xpTodayRows = await _db
          .from('xp_ledger')
          .select('xp, created_at')
          .eq('user_id', user.id)
          .gte('created_at', startIso)
          .lt('created_at', endIso);

      final xpTotalRows =
          await _db.from('xp_ledger').select('xp').eq('user_id', user.id);

      final todaySum =
          xpTodayRows.fold<int>(0, (sum, r) => sum + (r['xp'] as int));
      final totalSum =
          xpTotalRows.fold<int>(0, (sum, r) => sum + (r['xp'] as int));

      if (!mounted) return;
      setState(() {
        _checkedInToday = checkins.isNotEmpty;
        _xpToday = todaySum;
        _xpTotal = totalSum;
      });
    } catch (_) {
      // mantém UI funcionando
    }
  }

  double _calcBmi(double weightKg, double heightCm) {
    final h = heightCm / 100.0;
    if (h <= 0) return 0;
    return weightKg / (h * h);
  }

  Future<void> _saveCheckIn() async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.fillWeightHeight)),
      );
      return;
    }

    final bmi = _calcBmi(weight, height);
    setState(() => _saving = true);

    try {
      await _db.from('body_checkins').upsert({
        'user_id': user.id,
        'checkin_date': _todayIsoDate,
        'weight_kg': weight,
        'height_cm': height,
        'bmi': bmi,
      }, onConflict: 'user_id,checkin_date');

      if (!_checkedInToday) {
        await _db.from('xp_ledger').insert({
          'user_id': user.id,
          'xp': 25,
          'source': 'daily_checkin',
        });
      }

      if (!mounted) return;
      setState(() {
        _checkedInToday = true;
      });

      await _loadTodayState();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.unexpectedError('$e'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _db.auth.currentUser;

    if (user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: Text(context.l10n.signIn),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.youTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.todoCreateFlow)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.progressTab),
            Tab(text: context.l10n.activitiesTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProgressTab(
            email: user.email ?? '',
            xpToday: _xpToday,
            xpTotal: _xpTotal,
            checkedInToday: _checkedInToday,
            saving: _saving,
            weightCtrl: _weightCtrl,
            heightCtrl: _heightCtrl,
            onSaveCheckIn: _saveCheckIn,
          ),
          const _ActivitiesTab(),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({
    required this.email,
    required this.xpToday,
    required this.xpTotal,
    required this.checkedInToday,
    required this.saving,
    required this.weightCtrl,
    required this.heightCtrl,
    required this.onSaveCheckIn,
  });

  final String email;
  final int xpToday;
  final int xpTotal;
  final bool checkedInToday;
  final bool saving;

  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;

  final VoidCallback onSaveCheckIn;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _Card(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Icon(Icons.directions_run),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(context.l10n.trainingSelection,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        _Badge(text: context.l10n.newBadge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.easyRunTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.easyRunSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: Text(context.l10n.seeAll),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: Text(context.l10n.run),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: Text(context.l10n.walk),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(context.l10n.thisWeek,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBlock(label: context.l10n.distance, value: '0,00 km'),
              _StatBlock(label: context.l10n.time, value: '0min'),
              _StatBlock(label: context.l10n.elevationGain, value: '0 m'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(context.l10n.dailyCheckIn,
                          style: Theme.of(context).textTheme.titleMedium)),
                  _XPChip(xpToday: xpToday, xpTotal: xpTotal),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.weightKg,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.heightCm,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : onSaveCheckIn,
                  child: Text(
                    saving
                        ? context.l10n.saving
                        : (checkedInToday
                            ? context.l10n.checkedInToday
                            : context.l10n.checkInToday),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _Card(
          child: Column(
            children: [
              ListTile(
                title: Text(context.l10n.bodyMetricsCard),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).pushNamed('/you/body-metrics'),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(context.l10n.trainingStatsCard),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).pushNamed('/you/training-stats'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.ios_share),
            label: Text(context.l10n.share),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          context.l10n.signedInAs(email),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  const _ActivitiesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.activitiesListTodo),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(.3)),
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.primary.withOpacity(.12),
      ),
      child: Text(text,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _XPChip extends StatelessWidget {
  const _XPChip({required this.xpToday, required this.xpTotal});
  final int xpToday;
  final int xpTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
          '${context.l10n.xp}: $xpTotal • ${context.l10n.xpTodayEarned}: $xpToday',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
