'''// lib/main.dart (updated with comprehensive error handling)
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
import 'package:task_management/presentation/routes/app_routes.dart';

import 'core/constants/api_constants.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/user_data_repository_impl.dart';
import 'presentation/provider/task_provider.dart';
import 'presentation/provider/user_provider.dart';
import 'presentation/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 Flutter initialized');
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
    print('✅ Hive initialized');
    
    // Register adapters
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    print('✅ Adapters registered');
    
    // Open Hive boxes with error handling
    Box<TaskModel> taskBox;
    Box<UserModel> userBox;
    
    try {
      taskBox = await Hive.openBox<TaskModel>(AppConstants.hiveTasksBox);
      userBox = await Hive.openBox<UserModel>(AppConstants.hiveUsersBox);
      print('✅ Hive boxes opened');
    } catch (e) {
      print('⚠️ Hive box error: $e');
      // Delete and recreate boxes if they're corrupted
      await Hive.deleteBoxFromDisk(AppConstants.hiveTasksBox);
      await Hive.deleteBoxFromDisk(AppConstants.hiveUsersBox);
      taskBox = await Hive.openBox<TaskModel>(AppConstants.hiveTasksBox);
      userBox = await Hive.openBox<UserModel>(AppConstants.hiveUsersBox);
      print('✅ Hive boxes recreated');
    }
    
    // Initialize services
    final sharedPreferences = await SharedPreferences.getInstance();
    final connectivity = Connectivity();
    print('✅ Services initialized');
    
    // Initialize notifications (optional, can fail silently)
    try {
      await NotificationService().init();
      print('✅ Notifications initialized');
    } catch (e) {
      print('⚠️ Notifications failed: $e');
    }
    
    runApp(MyApp(
      taskBox: taskBox,
      userBox: userBox,
      sharedPreferences: sharedPreferences,
      connectivity: connectivity,
    ));
    print('✅ App started successfully');
    
  } catch (e, stackTrace) {
    print('❌ Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    
    // Fallback to a simple error app
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'App Initialization Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('Error: $e'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Restart App'),
              ),
            ],
          ),
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
    try {
      // Create services
      final connectivityService = ConnectivityServiceImpl(connectivity: connectivity);
      final localDataSource = LocalDataSourceImpl(taskBox: taskBox, userBox: userBox);
      
      // Create repositories
      final TaskRepository taskRepository = TaskRepositoryImpl(
        remoteDataSource: RemoteDataSourceImpl(client: http.Client()),
        localDataSource: localDataSource,
        connectivityService: connectivityService,
      );
      
      final UserRepository userRepository = UserRepositoryImpl(
        remoteDataSource: RemoteDataSourceImpl(client: http.Client()),
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
              authService: AuthService(),
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
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: sharedPreferences.getString('token') != null ? '/home' : '/',
          // Add a fallback home in case routing fails
          home: const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error building MyApp: $e');
      print('Stack trace: $stackTrace');
      
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error building app: $e'),
          ),
        ),
      );
    }
  }
}
''