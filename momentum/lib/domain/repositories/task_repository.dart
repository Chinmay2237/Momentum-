import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks();
  Future<TaskEntity> createTask(TaskEntity task);
  Future<TaskEntity> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
}
