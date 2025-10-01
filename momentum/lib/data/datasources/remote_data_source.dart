import '../../core/services/api_service.dart';
import '../models/task_model.dart';

abstract class RemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiService apiService;

  RemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<TaskModel>> getTasks() async {
    final response = await apiService.getTasks();
    return (response as List).map((task) => TaskModel.fromJson(task)).toList();
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final response = await apiService.createTask(task.toJson());
    return TaskModel.fromJson(response);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await apiService.updateTask(task.id, task.toJson());
    return TaskModel.fromJson(response);
  }

  @override
  Future<void> deleteTask(String id) async {
    await apiService.deleteTask(int.parse(id));
  }
}
