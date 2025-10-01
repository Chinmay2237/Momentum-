
import 'package:momentum/models/habit.dart';

class HabitService {
  // Singleton pattern
  static final HabitService _instance = HabitService._internal();
  factory HabitService() {
    return _instance;
  }
  HabitService._internal();

  final List<Habit> _habits = [
    Habit(
      id: '1',
      name: 'Morning Meditation',
      description: 'Meditate for 10 minutes every morning.',
      plantType: 'assets/images/plant1.png',
      goal: 30,
      progress: 10,
      createdAt: DateTime.now(),
    ),
    Habit(
      id: '2',
      name: 'Read a Book',
      description: 'Read 20 pages of a book every day.',
      plantType: 'assets/images/plant2.png',
      goal: 30,
      progress: 5,
      createdAt: DateTime.now(),
    ),
  ];

  List<Habit> getHabits() {
    return _habits;
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
  }

  void updateHabit(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
  }
}
