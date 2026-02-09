import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/l10n.dart';
import '../../core/timer/workout_timer_provider.dart';
import '../recording/controller/workout_recorder_scope.dart';
import '../recording/ui/workout_summary_page.dart';
import 'map_record_page.dart';
import 'record_service.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage>
    with SingleTickerProviderStateMixin {
  final RecordService _service = RecordService();

  List<ActivityType> _types = const [];
  ActivityType? _selectedType;

  DateTime? _startedAtUtc;

  bool _loadingTypes = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start timer ticks for UI
      ref.read(workoutTimerProvider).start(this);
      // Start GPS tracking when entering screen (later we can tie to start button)
      ref.read(locationTrackerProvider).start();
    });
  }

  @override
  void dispose() {
    ref.read(workoutTimerProvider).disposeTicker();
    unawaited(ref.read(locationTrackerProvider).stop());
    super.dispose();
  }

  Future<void> _loadTypes() async {
    setState(() => _loadingTypes = true);
    try {
      final types = await _service.fetchActivityTypes();
      setState(() {
        _types = types;
        _selectedType = types.isNotEmpty ? types.first : null;
      });
    } catch (_) {
      _toast('Falha ao carregar tipos de atividade.');
    } finally {
      if (mounted) setState(() => _loadingTypes = false);
    }
  }

  Future<void> _start() async {
    if (_selectedType == null) {
      _toast('Selecione um tipo de treino primeiro.');
      return;
    }
    _startedAtUtc ??= DateTime.now().toUtc();
    ref.read(workoutTimerProvider).start(this);
    ref.read(locationTrackerProvider).start();
    await WorkoutRecorderScope.of(context).start();
    setState(() {});
  }

  void _pause() {
    ref.read(workoutTimerProvider).pause();
    ref.read(locationTrackerProvider).stop();
    WorkoutRecorderScope.of(context).pause();
    setState(() {});
  }

  void _reset() {
    ref.read(workoutTimerProvider).reset();
    ref.read(locationTrackerProvider).reset();
    WorkoutRecorderScope.of(context).reset();
    _startedAtUtc = null;
    setState(() {});
  }

  Future<void> _stopAndSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    final recorder = WorkoutRecorderScope.of(context);
    try {
      final session = await recorder.stopAndBuildSession();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WorkoutSummaryPage(session: session),
        ),
      );
      recorder.reset();
      _reset();
    } catch (e) {
      _toast('Erro ao finalizar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openMapRecorder() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MapRecordPage()));
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatElapsed(Duration d) {
    final totalSeconds = d.inSeconds;
    final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  bool get _hasStarted => _startedAtUtc != null;

  @override
  Widget build(BuildContext context) {
    if (_loadingTypes) {
      return const Center(child: CircularProgressIndicator());
    }

    final timer = ref.watch(workoutTimerProvider);
    final gps = ref.watch(locationTrackerProvider);
    final recorder = WorkoutRecorderScope.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.appBarRecord,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (gps.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            Theme.of(context).colorScheme.error.withOpacity(.4)),
                  ),
                  child: Text(gps.error!),
                ),
                const SizedBox(height: 12),
              ],
              // Tempo decorrido
              Center(
                child: AnimatedBuilder(
                  animation: timer,
                  builder: (_, __) => Text(
                    _formatElapsed(timer.elapsed),
                    style: const TextStyle(
                        fontSize: 46, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Distância + Ritmo
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Distância',
                      value: '${_formatKm(gps.distanceMeters)} km',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Ritmo',
                      value: _formatPace(timer.elapsed, gps.distanceMeters),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Velocidade',
                      value:
                          '${(gps.currentSpeedMps * 3.6).isFinite ? (gps.currentSpeedMps * 3.6).toStringAsFixed(1).replaceAll(".", ",") : "0,0"} km/h',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'GPS',
                      value: gps.tracking ? 'Ativo' : 'Parado',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(workoutTimerProvider).pause();
                        ref.read(locationTrackerProvider).stop();
                      },
                      child: const Text('Pausar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref.read(workoutTimerProvider).resume();
                        ref.read(locationTrackerProvider).start();
                      },
                      child: const Text('Retomar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  ref.read(workoutTimerProvider).reset();
                  ref.read(locationTrackerProvider).reset();
                },
                child: const Text('Zerar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
