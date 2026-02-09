import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/workout_session.dart';

abstract class WorkoutRepository {
  Future<void> save(WorkoutSession session);
}

class HybridWorkoutRepository implements WorkoutRepository {
  static const _key = 'movnos_workouts';

  @override
  Future<void> save(WorkoutSession session) async {
    if (kIsWeb) return _saveWeb(session);
    return _saveMobile(session);
  }

  Future<void> _saveWeb(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    list.insert(0, session.toJsonString());
    await prefs.setStringList(_key, list);
  }

  Future<void> _saveMobile(WorkoutSession session) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/workouts');
    if (!await folder.exists()) await folder.create(recursive: true);
    final file = File('${folder.path}/${session.id}.json');
    await file.writeAsString(session.toJsonString(), flush: true);
  }
}
