import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_tracker_notifier.dart';

/// Riverpod provider for real-time GPS tracking (distance + speed).
final locationTrackerProvider =
    ChangeNotifierProvider<LocationTrackerNotifier>((ref) {
  return LocationTrackerNotifier();
});
