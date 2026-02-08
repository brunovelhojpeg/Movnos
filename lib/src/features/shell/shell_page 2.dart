import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../record/record_page.dart';
import '../you/you_page.dart';
import '../plan/plan_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _tabs = <Widget>[
    _Placeholder(title: 'Home'),
    _Placeholder(title: 'Training'),
    RecordPage(),
    PlanPage(),
    YouPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movnos'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () async => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.fiber_manual_record_outlined),
            label: 'Gravar',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Plano',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Você',
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }
}
