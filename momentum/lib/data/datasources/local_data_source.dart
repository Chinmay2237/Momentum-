import 'package:hive/hive.dart';
import '../models/task_model.dart';

abstract class LocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<TaskModel> taskBox;

  LocalDataSourceImpl({required this.taskBox});

  @override
  Future<List<TaskModel>> getTasks() async {
    return taskBox.values.toList();
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    await taskBox.clear();
    for (var task in tasks) {
      await taskBox.put(task.id, task);
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    await taskBox.put(task.id, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await taskBox.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }
}
