
import 'package:flutter/material.dart';
import 'package:momentum/models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            Text(habit.description),
            const SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: habit.progress / habit.goal,
            ),
          ],
        ),
      ),
    );
  }
}
