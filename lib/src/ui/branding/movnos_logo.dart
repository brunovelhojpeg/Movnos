import 'package:flutter/material.dart';

class MovnosLogo extends StatelessWidget {
  final double height;
  final BoxFit fit;

  const MovnosLogo({
    super.key,
    this.height = 64,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/extenso-preto.png',
      height: height,
      fit: fit,
      semanticLabel: 'Movnos',
    );
  }
}
