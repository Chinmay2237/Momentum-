import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:task_management/core/services/connectivity_service.dart';
import 'package:task_management/data/datasources/local_data_source.dart';
import 'package:task_management/data/datasources/remote_data_source.dart';
import 'package:task_management/data/models/task_model.dart';
import 'package:task_management/data/models/user_model.dart';
import 'package:task_management/data/repositories/task_repository_impl.dart';
import 'package:task_management/domain/repositories/task_repository.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

import 'core/constants/api_constants.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/user_data_repository_impl.dart';
import 'presentation/provider/task_provider.dart';
import 'presentation/provider/user_provider.dart';
import 'presentation/themes/app_themes.dart';
import 'task_management.dart'; // Import the new task management page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... (rest of your main function remains the same)
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    
    final taskBox = await Hive.openBox<TaskModel>(AppConstants.hiveTasksBox);
    final userBox = await Hive.openBox<UserModel>(AppConstants.hiveUsersBox);
    
    final sharedPreferences = await SharedPreferences.getInstance();
    final connectivity = Connectivity();
    
    await NotificationService().init();
    
    runApp(MyApp(
      taskBox: taskBox,
      userBox: userBox,
      sharedPreferences: sharedPreferences,
      connectivity: connectivity,
    ));
    
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization Failed: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final Box<TaskModel> taskBox;
  final Box<UserModel> userBox;
  final SharedPreferences sharedPreferences;
  final Connectivity connectivity;

  const MyApp({
    super.key,
    required this.taskBox,
    required this.userBox,
    required this.sharedPreferences,
    required this.connectivity,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityServiceImpl(connectivity: connectivity);
    final localDataSource = LocalDataSourceImpl(taskBox: taskBox, userBox: userBox);
    final remoteDataSource = RemoteDataSourceImpl(client: http.Client());

    final TaskRepository taskRepository = TaskRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivityService: connectivityService,
    );
    
    final UserRepository userRepository = UserRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivityService: connectivityService,
      sharedPreferences: sharedPreferences,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            userRepository: userRepository,
            sharedPreferences: sharedPreferences,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskRepository: taskRepository),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: TaskManagementPage( // Set as home
          taskRepository: taskRepository,
          userRepository: userRepository,
        ),
      ),
    );
  }
}
