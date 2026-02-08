import 'package:flutter/material.dart';

import '../../ui/strava_widgets.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: StravaTopBar(),
      body: Center(
        child: Text('Mapas (heatmap, rotas, segmentos) — próximo passo'),
      ),
    );
  }
}
