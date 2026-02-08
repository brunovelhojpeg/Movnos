import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/profile_service.dart';

class OnboardingHeightPage extends StatefulWidget {
  const OnboardingHeightPage({super.key});

  @override
  State<OnboardingHeightPage> createState() => _OnboardingHeightPageState();
}

class _OnboardingHeightPageState extends State<OnboardingHeightPage> {
  final _heightCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _heightCtrl.text.trim();
    final height = int.tryParse(raw);
    if (height == null || height < 90 || height > 250) {
      _toast('Digite uma altura válida em cm (90–250).');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ProfileService().setHeightCm(height);
      // AuthGate will re-check profile on rebuild.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const _DoneRedirect()),
          (_) => false,
        );
      }
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Falha ao salvar a altura.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração rápida'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () async => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Sua altura',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Usamos isso para calcular o IMC. Você poderá alterar depois.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continuar'),
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

/// Forces a clean rebuild of AuthGate after onboarding.
class _DoneRedirect extends StatelessWidget {
  const _DoneRedirect();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
