
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/core/errors/exception.dart';
import 'package:task_management/domain/entities/task_entity.dart';
import 'package:task_management/domain/entities/user_entity.dart';
import 'package:task_management/domain/repositories/task_repository.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

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
  late Future<void> _dataLoadingFuture;
  List<TaskEntity> _tasks = [];
  Map<int, UserEntity> _userMap = {};

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final results = await Future.wait([
      widget.taskRepository.getTasks(),
      widget.userRepository.getUsers(),
    ]);

    if (!mounted) return;

    final tasksEither = results[0] as Either<Failure, List<TaskEntity>>;
    final usersEither = results[1] as Either<Failure, List<UserEntity>>;

    tasksEither.fold(
      (failure) => _showError('Failed to load tasks: ${failure.message}'),
      (tasks) => setState(() => _tasks = tasks),
    );

    usersEither.fold(
      (failure) => _showError('Failed to load users: ${failure.message}'),
      (users) => setState(() => _userMap = {for (var user in users) user.id: user}),
    );
  }

  void _refreshData() {
    setState(() {
      _dataLoadingFuture = _loadData();
    });
  }

  void _createTask() async {
    final task = await _showTaskDialog();
    if (task != null && mounted) {
      final result = await widget.taskRepository.createTask(task);
      if (mounted) {
        result.fold(
          (failure) => _showError('Failed to create task: ${failure.message}'),
          (_) => _refreshData(),
        );
      }
    }
  }

  void _editTask(TaskEntity task) async {
    final updatedTask = await _showTaskDialog(task: task);
    if (updatedTask != null && mounted) {
      final result = await widget.taskRepository.updateTask(updatedTask);
      if (mounted) {
        result.fold(
          (failure) => _showError('Failed to update task: ${failure.message}'),
          (_) => _refreshData(),
        );
      }
    }
  }

  void _deleteTask(String taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await widget.taskRepository.deleteTask(taskId);
      if (mounted) {
        result.fold(
          (failure) => _showError('Failed to delete task: ${failure.message}'),
          (_) => _refreshData(),
        );
      }
    }
  }

  void _assignTask(TaskEntity task) async {
    if (_userMap.isEmpty) {
      _showError("No users available to assign.");
      return;
    }
    final users = _userMap.values.toList();

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
                  title: Text(user.fullName),
                  subtitle: Text(user.email),
                  onTap: () => Navigator.of(context).pop(user),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedUser != null && mounted) {
      final updatedTask = task.copyWith(assignedUserId: selectedUser.id);
      final result = await widget.taskRepository.updateTask(updatedTask);
      if (mounted) {
        result.fold(
          (failure) => _showError('Failed to assign task: ${failure.message}'),
          (_) => _refreshData(),
        );
      }
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
                  onChanged: (value) => priority = value ?? priority,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(builder: (context, setState) {
                   return ListTile(
                    title: Text('Due: ${DateFormat.yMd().format(dueDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (selectedDate != null) {
                        setState(() => dueDate = selectedDate);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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
                  assignedUserId: task?.assignedUserId ?? 0,
                  createdAt: task?.createdAt ?? DateTime.now(),
                  updatedAt: task != null ? DateTime.now() : null,
                  isSynced: task?.isSynced ?? false,
                  reminderDate: task?.reminderDate,
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Momentum'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<void>(
          future: _dataLoadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('An unexpected error occurred: ${snapshot.error}'));
            }
            if (_tasks.isEmpty) {
              return const Center(
                  child: Text('No tasks found. Pull down to refresh or create one!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final assignedUser = _userMap[task.assignedUserId];

                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: _buildPriorityIcon(task.priority),
                    title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty) ...[
                          Text(task.description),
                          const SizedBox(height: 4.0),
                        ],
                        Text('Due: ${DateFormat.yMd().format(task.dueDate)}',
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                        if (assignedUser != null) ...[
                           const SizedBox(height: 4.0),
                           Text('Assigned to: ${assignedUser.fullName}',
                               style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic)),
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        tooltip: 'Create Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPriorityIcon(String priority) {
    Color color;
    switch (priority) {
      case 'High': color = Colors.red; break;
      case 'Medium': color = Colors.orange; break;
      case 'Low': default: color = Colors.green; break;
    }
    return Icon(Icons.flag, color: color);
  }
}
