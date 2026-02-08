import 'package:flutter/widgets.dart';

class SafeNavigator {
  static bool _isNavigating = false;

  static Future<void> goNamedOnce(
    BuildContext context, {
    required String routeName,
    Object? arguments,
    String? currentRouteName,
  }) async {
    if (_isNavigating) return;
    if (currentRouteName != null && currentRouteName == routeName) return;

    _isNavigating = true;
    try {
      await Navigator.of(context).pushReplacementNamed(routeName,
          arguments: arguments);
    } finally {
      _isNavigating = false;
    }
  }
}
