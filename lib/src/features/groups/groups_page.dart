import 'package:flutter/material.dart';

import '../../ui/strava_widgets.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: StravaTopBar(),
      body: Center(child: Text('Grupos (comunidade) — próximo passo')),
    );
  }
}
