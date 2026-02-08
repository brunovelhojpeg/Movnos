import 'package:flutter/material.dart';

import '../app/navigation/safe_navigator.dart';

class AppRoutes {
  // Tabs (Shell)
  static const home = '/';
  static const maps = '/maps';
  static const record = '/record';
  static const groups = '/groups';
  static const you = '/you';
  static const login = '/login';
  static const settings = '/settings';

  // Home extras
  static const workoutPicks = '/workouts/picks';
  static const workoutPickDetails = '/workouts/pick';
  static const predictions = '/predictions';
  static const activityDetails = '/activity';

  // Misc
  static const search = '/search';
  static const inbox = '/inbox';
  static const notifications = '/notifications';
  static const profile = '/profile';
}

/// Helper: navigate safely without stacking or duplicating the same route.
extension NavX on BuildContext {
  Future<void> go(String route, {Object? args}) => SafeNavigator.goNamedOnce(
        this,
        routeName: route,
        arguments: args,
        currentRouteName: ModalRoute.of(this)?.settings.name,
      );
}
