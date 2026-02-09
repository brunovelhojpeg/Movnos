import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../recorder/recorder_engine.dart';
import '../share/workout_share_web.dart';

final recorderProvider = ChangeNotifierProvider<RecorderEngine>((ref) {
  return RecorderEngine();
});

class RecordPageDev extends ConsumerWidget {
  const RecordPageDev({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(recorderProvider);
    final s = engine.state;

    final timeText = _formatTime(s.elapsed);
    final distText = s.distanceKm.toStringAsFixed(2);
    final paceText = _formatPace(s.paceSecPerKm);

    final isRunning = s.status == RecorderStatus.running;
    final isPaused = s.status == RecorderStatus.paused;
    final isFinished = s.status == RecorderStatus.finished;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravar (DEV simulado)'),
        actions: [
          IconButton(
            tooltip: 'Configurar simulação',
            icon: const Icon(Icons.tune),
            onPressed: () => _openDevSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Mapa (WEB DEV): tracking simulado no Chrome',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _BottomPanel(
            activityLabel: 'Outros',
            timeText: timeText,
            paceText: paceText,
            distanceText: distText,
            primaryButtonIcon: isRunning ? Icons.stop : Icons.play_arrow,
            primaryButtonLabel: isRunning ? 'Parar' : 'Iniciar',
            onPrimary: () {
              if (isRunning) {
                ref.read(recorderProvider).pause();
              } else {
                ref.read(recorderProvider).start();
              }
            },
            showSave: isPaused || isFinished,
            onSave: isPaused ? () => ref.read(recorderProvider).stop() : null,
            onShare: isFinished
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _SummaryPage()),
                    )
                : null,
          ),
        ],
      ),
    );
  }

  static String _formatTime(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _formatPace(double secPerKm) {
    if (secPerKm <= 0) return '--:--';
    final total = secPerKm.round();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static void _openDevSheet(BuildContext context, WidgetRef ref) {
    final engine = ref.read(recorderProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Simulação no Chrome (DEV)',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              _DevSpeedButton(
                label: 'Caminhada',
                mps: 1.4,
                onTap: () => engine.setDevSpeedMps(1.4),
              ),
              _DevSpeedButton(
                label: 'Trote',
                mps: 2.4,
                onTap: () => engine.setDevSpeedMps(2.4),
              ),
              _DevSpeedButton(
                label: 'Corrida',
                mps: 3.2,
                onTap: () => engine.setDevSpeedMps(3.2),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  engine.reset();
                  Navigator.pop(context);
                },
                child: const Text('Resetar sessão'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DevSpeedButton extends StatelessWidget {
  final String label;
  final double mps;
  final VoidCallback onTap;
  const _DevSpeedButton({
    required this.label,
    required this.mps,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text('${(mps * 3.6).toStringAsFixed(1)} km/h'),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final String activityLabel;
  final String timeText;
  final String paceText;
  final String distanceText;
  final IconData primaryButtonIcon;
  final String primaryButtonLabel;
  final VoidCallback onPrimary;
  final bool showSave;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const _BottomPanel({
    required this.activityLabel,
    required this.timeText,
    required this.paceText,
    required this.distanceText,
    required this.primaryButtonIcon,
    required this.primaryButtonLabel,
    required this.onPrimary,
    required this.showSave,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(activityLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(title: 'Tempo', value: timeText),
              _Metric(title: 'Ritmo (/km)', value: paceText),
              _Metric(title: 'Distância (km)', value: distanceText),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrimary,
                  icon: Icon(primaryButtonIcon),
                  label: Text(primaryButtonLabel),
                ),
              ),
              const SizedBox(width: 12),
              if (showSave)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.check),
                    label: const Text('Salvar'),
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (onShare != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share),
                label: const Text('Compartilhar'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  const _Metric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }
}

class _SummaryPage extends StatelessWidget {
  const _SummaryPage();

  @override
  Widget build(BuildContext context) {
    final share = WorkoutShareWeb();

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: const Text('Aqui vai o “card do treino” (imagem).'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await share.downloadPng(
                    context: context,
                    fileName: 'movnos-workout.png',
                    captureWidget: const _ShareCard(),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Baixar imagem (WEB)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MOVNOS',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          const Text('Treino salvo',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Compartilhamento (DEV no Chrome)',
              style: TextStyle(color: Colors.black.withOpacity(0.6))),
          const Spacer(),
          Text('www.movnos.com',
              style: TextStyle(color: Colors.black.withOpacity(0.5))),
        ],
      ),
    );
  }
}
