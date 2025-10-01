
import 'package:momentum/models/habit.dart';
import 'package:momentum/services/database_helper.dart';

class HabitService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Habit>> getHabits() async {
    return await _db.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await _db.insertHabit(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
  }

  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(id);
  }
}
