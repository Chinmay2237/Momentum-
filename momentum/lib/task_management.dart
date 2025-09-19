
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_management/domain/entities/task_entity.dart';
import 'package:task_management/domain/entities/user_entity.dart';
import 'package:task_management/domain/repositories/task_repository.dart';
import 'package:task_management/domain/repositories/user_repository.dart';
import 'package:task_management/presentation/provider/user_provider.dart';

// Note: For a truly production-ready app, consider the following:
// 1. Logging: Integrate a logging framework (like `logger`) and a remote logging service (like Sentry or Firebase Crashlytics) to track errors.
// 2. Environment Configuration: Use a proper system (like .env files or flavors) to manage different environments (dev, staging, production) and their specific configurations (e.g., API URLs).
// 3. Testing: Write comprehensive unit, widget, and integration tests to ensure code quality and prevent regressions.
// 4. Dependency Injection: For larger apps, use a dedicated dependency injection framework (like `get_it`) for better organization.

class TaskManagementPage extends StatefulWidget {
  final TaskRepository taskRepository;
  final UserRepository userRepository;

  const TaskManagementPage({
    Key? key,
    required this.taskRepository,
    required this.userRepository,
  }) : super(key: key);

  @override
  _TaskManagementPageState createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  late Future<List<TaskEntity>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadTasks();
  }

  Future<List<TaskEntity>> _loadTasks() {
    final result = widget.taskRepository.getTasks();
    return result.then((either) => either.fold(
          (failure) {
            _showError('Failed to load tasks: ${failure.message}');
            return []; // Return an empty list on failure
          },
          (tasks) => tasks,
        ));
  }

  void _createTask() async {
    final task = await _showTaskDialog();
    if (task != null) {
      final result = await widget.taskRepository.createTask(task);
      result.fold(
        (failure) => _showError('Failed to create task: ${failure.message}'),
        (task) => setState(() {
          _tasksFuture = _loadTasks();
        }),
      );
    }
  }

  void _editTask(TaskEntity task) async {
    final updatedTask = await _showTaskDialog(task: task);
    if (updatedTask != null) {
      final result = await widget.taskRepository.updateTask(updatedTask);
      result.fold(
        (failure) => _showError('Failed to update task: ${failure.message}'),
        (task) => setState(() {
          _tasksFuture = _loadTasks();
        }),
      );
    }
  }

  void _deleteTask(String taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await widget.taskRepository.deleteTask(taskId);
      result.fold(
        (failure) => _showError('Failed to delete task: ${failure.message}'),
        (_) => setState(() {
          _tasksFuture = _loadTasks();
        }),
      );
    }
  }

  void _assignTask(TaskEntity task) async {
    // In a production app, you would fetch the list of users from your UserRepository.
    // The `UserProvider` is a good place to manage user state.
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final either = await userProvider.getUsers();
    //
    // This is an example of how you would handle the result:
    // List<UserEntity> users = either.fold((failure) => [], (userList) => userList);

    // For demonstration purposes, we'll use a placeholder list of users.
    // Replace this with your actual user fetching logic.
    final users = [
      UserEntity(id: 'user1', name: 'Alice', email: 'alice@example.com'),
      UserEntity(id: 'user2', name: 'Bob', email: 'bob@example.com'),
      UserEntity(id: 'user3', name: 'Charlie', email: 'charlie@example.com'),
    ];

    final selectedUser = await showDialog<UserEntity>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Task To'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () {
                    Navigator.of(context).pop(user);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedUser != null) {
      final updatedTask = task.copyWith(assignedTo: selectedUser.id);
      final result = await widget.taskRepository.updateTask(updatedTask);
      result.fold(
        (failure) => _showError('Failed to assign task: ${failure.message}'),
        (task) => setState(() {
          _tasksFuture = _loadTasks();
        }),
      );
    }
  }

  Future<TaskEntity?> _showTaskDialog({TaskEntity? task}) async {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(text: task?.description);
    String priority = task?.priority ?? 'Medium';
    DateTime dueDate = task?.dueDate ?? DateTime.now();

    return showDialog<TaskEntity>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Create Task' : 'Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: ['Low', 'Medium', 'High']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      priority = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Due Date: ${DateFormat.yMd().format(dueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (selectedDate != null) {
                      // We need to rebuild the dialog state
                      (context as Element).markNeedsBuild();
                      dueDate = selectedDate;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                final newTask = TaskEntity(
                  id: task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: dueDate,
                  priority: priority,
                  status: task?.status ?? 'To-Do',
                  assignedTo: task?.assignedTo,
                );
                Navigator.of(context).pop(newTask);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _tasksFuture = _loadTasks();
          });
        },
        child: FutureBuilder<List<TaskEntity>>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No tasks found. Pull down to refresh or create a new one!'));
            } else {
              final tasks = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: _buildPriorityIcon(task.priority),
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty) ...[
                            Text(task.description),
                            const SizedBox(height: 4.0),
                          ],
                          Text(
                            'Due: ${DateFormat.yMd().format(task.dueDate)}',
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                          if (task.assignedTo != null) ...[
                             const SizedBox(height: 4.0),
                             Text(
                               'Assigned to: ${task.assignedTo}',
                               style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                             ),
                          ]
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.green),
                            onPressed: () => _assignTask(task),
                            tooltip: 'Assign Task',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(task),
                             tooltip: 'Edit Task',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(task.id),
                             tooltip: 'Delete Task',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        child: const Icon(Icons.add),
        tooltip: 'Create Task',
      ),
    );
  }

  Widget _buildPriorityIcon(String priority) {
    Color color;
    switch (priority) {
      case 'High':
        color = Colors.red;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Low':
      default:
        color = Colors.green;
        break;
    }
    return Icon(Icons.flag, color: color);
  }
}
