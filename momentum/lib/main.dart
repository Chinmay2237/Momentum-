
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/services/api_service.dart';
import 'package:task_management/core/services/auth_service.dart';
import 'package:task_management/data/datasources/local_data_source.dart';
import 'package:task_management/data/datasources/remote_data_source.dart';
import 'package:task_management/data/models/task_model.dart';
import 'package:task_management/data/repositories/task_repository_impl.dart';
import 'package:task_management/data/repositories/user_repository_impl.dart';
import 'package:task_management/domain/repositories/task_repository.dart';
import 'package:task_management/domain/repositories/user_repository.dart';
import 'package:task_management/presentation/pages/home_screen.dart';
import 'package:task_management/presentation/provider/task_provider.dart';
import 'package:task_management/presentation/provider/user_provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  final taskBox = await Hive.openBox<TaskModel>('tasks');

  final apiService = ApiService('https://jsonplaceholder.typicode.com');
  final authService = AuthService(apiService);
  final remoteDataSource = RemoteDataSourceImpl(apiService: apiService);
  final localDataSource = LocalDataSourceImpl(taskBox: taskBox);
  final taskRepository = TaskRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
  final userRepository = UserRepositoryImpl(authService);

  runApp(MyApp(
    taskRepository: taskRepository,
    userRepository: userRepository,
  ));
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;
  final UserRepository userRepository;

  const MyApp({
    Key? key,
    required this.taskRepository,
    required this.userRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskRepository: taskRepository,
            userRepository: userRepository,
          )..getTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            userRepository: userRepository,
          )..getCurrentUser(),
        ),
      ],
      child: MaterialApp(
        title: 'Momentum',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
