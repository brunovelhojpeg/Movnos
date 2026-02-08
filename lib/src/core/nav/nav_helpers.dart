import 'package:flutter/material.dart';

extension NavHelpers on BuildContext {
  Future<T?> pushOnce<T>(Route<T> route) {
    final nav = Navigator.of(this);
    final current = ModalRoute.of(this);
    if (current?.settings.name == route.settings.name && route.settings.name != null) {
      return Future.value(null);
    }
    return nav.push<T>(route);
  }

  Future<T?> pushReplacementSafe<T, TO>(Route<T> route) {
    return Navigator.of(this).pushReplacement<T, TO>(route);
  }
}
