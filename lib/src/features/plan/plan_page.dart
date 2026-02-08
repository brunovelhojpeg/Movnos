import 'package:flutter/material.dart';

import 'plan_service.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final PlanService _service = PlanService();
  late Future<List<TrainingPlan>> _plans;

  @override
  void initState() {
    super.initState();
    _plans = _service.fetchMyPlans();
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _plans = _service.fetchMyPlans()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Meu Plano',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<TrainingPlan>>(
            future: _plans,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data ?? const [];
              if (list.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Você ainda não tem planos ativos.'),
                  ),
                );
              }
              return Column(
                children: list
                    .map(
                      (p) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.assignment),
                          title: Text('Plano ${p.id.substring(0, 8)}'),
                          subtitle: Text(
                            'Status: ${p.status} • Criado em ${_formatDate(p.createdAt)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
