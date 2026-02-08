import 'package:flutter/material.dart';

import '../app/l10n/l10n.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PlaceholderPage({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          subtitle ?? context.l10n.placeholderPage(title),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
