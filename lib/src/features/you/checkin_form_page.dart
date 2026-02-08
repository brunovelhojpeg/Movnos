import 'package:flutter/material.dart';

import 'you_service.dart';

class CheckinFormPage extends StatefulWidget {
  const CheckinFormPage({super.key});

  @override
  State<CheckinFormPage> createState() => _CheckinFormPageState();
}

class _CheckinFormPageState extends State<CheckinFormPage> {
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipCtrl = TextEditingController();

  final YouService _service = YouService();
  bool _saving = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _hipCtrl.dispose();
    super.dispose();
  }

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _save() async {
    if (_saving) return;

    final weight = _parseDouble(_weightCtrl.text);
    final waist = _parseDouble(_waistCtrl.text);
    final hip = _parseDouble(_hipCtrl.text);

    if (weight == null || weight <= 0 || weight > 500) {
      _toast('Digite um peso válido (kg).');
      return;
    }
    if (waist == null || waist <= 0 || waist > 300) {
      _toast('Digite uma cintura válida (cm).');
      return;
    }
    if (hip == null || hip <= 0 || hip > 300) {
      _toast('Digite um quadril válido (cm).');
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.createCheckinAndReward(
        weightKg: weight,
        waistCm: waist,
        hipCm: hip,
      );
      if (!mounted) return;
      _toast('Check-in salvo! XP atualizado.');
      Navigator.of(context).pop(true);
    } catch (_) {
      _toast('Falha ao salvar check-in.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo check-in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Preencha suas métricas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Recomendação: faça isso a cada 15 dias para acompanhar sua evolução.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _waistCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cintura (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _hipCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quadril (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar check-in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
