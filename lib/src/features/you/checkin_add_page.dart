import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/l10n.dart';
import 'providers/check_in_providers.dart';

class CheckInAddPage extends ConsumerStatefulWidget {
  const CheckInAddPage({super.key});

  @override
  ConsumerState<CheckInAddPage> createState() => _CheckInAddPageState();
}

class _CheckInAddPageState extends ConsumerState<CheckInAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _hip = TextEditingController();
  bool _saving = false;

  double _parse(String v) => double.parse(v.replaceAll(',', '.'));

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _hip.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref
          .read(checkInServiceProvider)
          .addCheckIn(
            weightKg: _parse(_weight.text),
            waistCm: _parse(_waist.text),
            hipCm: _parse(_hip.text),
          );

      // força atualizar lista
      ref.invalidate(myCheckInsProvider);

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          SnackBar(content: Text(context.l10n.errorSavingCheckin('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _reqNum(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final t = v.replaceAll(',', '.');
    final n = double.tryParse(t);
    if (n == null) return context.l10n.fieldNumberInvalid;
    if (n <= 0) return context.l10n.fieldValueInvalid;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addCheckinTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _weight,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: context.l10n.weightKgLabel),
                validator: _reqNum,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _waist,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: context.l10n.waistCmLabel),
                validator: _reqNum,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hip,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: context.l10n.hipCmLabel),
                validator: _reqNum,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child:
                      Text(_saving ? context.l10n.saving : context.l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
