
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/domain/entities/task_entity.dart';
import 'package:task_management/domain/repositories/task_repository.dart';

class TaskManagementPage extends StatefulWidget {
  final TaskRepository taskRepository;

  const TaskManagementPage({Key? key, required this.taskRepository}) : super(key: key);

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

  Future<List<TaskEntity>> _loadTasks() async {
    final result = await widget.taskRepository.getTasks();
    return result.fold(
      (failure) => [], // Return an empty list on failure
      (tasks) => tasks,
    );
  }

  void _createTask() async {
    final task = await _showTaskDialog();
    if (task != null) {
      final result = await widget.taskRepository.createTask(task);
      result.fold(
        (failure) => _showError('Failed to create task'),
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
        (failure) => _showError('Failed to update task'),
        (task) => setState(() {
          _tasksFuture = _loadTasks();
        }),
      );
    }
  }

  void _deleteTask(String taskId) async {
    final result = await widget.taskRepository.deleteTask(taskId);
    result.fold(
      (failure) => _showError('Failed to delete task'),
      (_) => setState(() {
        _tasksFuture = _loadTasks();
      }),
    );
  }

  void _assignTask(TaskEntity task) async {
    // In a real app, you would show a user selection dialog here.
    // For simplicity, we'll just assign it to a dummy user.
    final updatedTask = task.copyWith(assignedTo: 'user1');
    final result = await widget.taskRepository.updateTask(updatedTask);
    result.fold(
      (failure) => _showError('Failed to assign task'),
      (task) => setState(() {
        _tasksFuture = _loadTasks();
      }),
    );
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
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['Low', 'Medium', 'High']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      priority = value;
                    }
                  },
                ),
                ListTile(
                  title: Text('Due Date: ${DateFormat.yMd().format(dueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        dueDate = selectedDate;
                      });
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
            TextButton(
              onPressed: () {
                final newTask = TaskEntity(
                  id: task?.id ?? DateTime.now().toString(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<TaskEntity>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found.'));
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
                        Text(task.description),
                        const SizedBox(height: 4.0),
                        Text(
                          'Due: ${DateFormat.yMd().format(task.dueDate)}',
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTask(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add, color: Colors.green),
                          onPressed: () => _assignTask(task),
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
