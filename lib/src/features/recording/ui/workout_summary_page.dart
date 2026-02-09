import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/workout_recorder_scope.dart';
import '../model/workout_session.dart';

class WorkoutSummaryPage extends StatefulWidget {
  const WorkoutSummaryPage({super.key, required this.session});
  final WorkoutSession session;

  @override
  State<WorkoutSummaryPage> createState() => _WorkoutSummaryPageState();
}

class _WorkoutSummaryPageState extends State<WorkoutSummaryPage> {
  bool _saving = false;

  String _fmtTime(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _fmtPace(double secPerKm) {
    if (secPerKm <= 0) return '--:--';
    final t = secPerKm.round();
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final recorder = WorkoutRecorderScope.of(context);
      await recorder.saveSession(widget.session);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    try {
      final json = widget.session.toJsonString();
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Chrome, o compartilhamento nativo é limitado. Use iOS/Android.')),
        );
        return;
      }
      final tmp = Directory.systemTemp;
      final file = File('${tmp.path}/movnos_${widget.session.id}.json');
      await file.writeAsString(json, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: 'Treino Movnos');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao compartilhar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
        actions: [
          IconButton(onPressed: _share, icon: const Icon(Icons.ios_share)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Row(label: 'Tempo', value: _fmtTime(s.elapsed)),
            _Row(label: 'Distância', value: '${s.distanceKm.toStringAsFixed(2)} km'),
            _Row(label: 'Ritmo', value: '${_fmtPace(s.paceSecPerKm)} /km'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Salvando...' : 'Salvar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Obs: no Chrome o share é limitado.\nNo iOS/Android vai abrir o share sheet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(value),
        ],
      ),
    );
  }
}
