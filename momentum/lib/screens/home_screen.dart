
import 'package:flutter/material.dart';
import 'package:momentum/services/habit_service.dart';
import 'package:momentum/widgets/habit_card.dart';
import 'package:momentum/models/habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitService _habitService = HabitService();
  late List<Habit> _habits;

  @override
  void initState() {
    super.initState();
    _habits = _habitService.getHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura'),
      ),
      body: ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          return HabitCard(habit: _habits[index]);
        },
      ),
    );
  }
}
