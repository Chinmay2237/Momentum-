
import 'package:flutter/material.dart';
import 'package:task_management/data/repositories/task_repository_impl.dart';
import 'package:task_management/data/repositories/user_repository_impl.dart';
import 'package:task_management/task_management.dart'; // Updated import

void main() {
  // Instantiate the concrete repository implementations
  final taskRepository = TaskRepositoryImpl();
  final userRepository = UserRepositoryImpl();

  runApp(MyApp(taskRepository: taskRepository, userRepository: userRepository));
}

class MyApp extends StatelessWidget {
  final TaskRepositoryImpl taskRepository;
  final UserRepositoryImpl userRepository;

  const MyApp({
    Key? key,
    required this.taskRepository,
    required this.userRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskManagementPage(
        taskRepository: taskRepository,
        userRepository: userRepository,
      ),
    );
  }
}
