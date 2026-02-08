import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'workout_timer_provider.dart';

class WorkoutTimerWidget extends StatefulWidget {
  const WorkoutTimerWidget({super.key});

  @override
  State<WorkoutTimerWidget> createState() => _WorkoutTimerWidgetState();
}

class _WorkoutTimerWidgetState extends State<WorkoutTimerWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkoutTimerProvider>().start(this);
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$millis';
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<WorkoutTimerProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _format(timer.elapsed),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                timer.isRunning ? Icons.pause : Icons.play_arrow,
              ),
              iconSize: 36,
              onPressed: () {
                timer.isRunning ? timer.pause() : timer.resume();
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.stop),
              iconSize: 36,
              onPressed: timer.reset,
            ),
          ],
        ),
      ],
    );
  }
}
