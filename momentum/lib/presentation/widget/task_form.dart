// lib/presentation/widgets/task_form.dart (Fixed version)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/data/models/task_model.dart';

import '../provider/task_provider.dart';
import '../provider/user_provider.dart';
import 'custom_textfield.dart';

class TaskForm extends StatefulWidget {
  final TaskModel? task;

  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late String _priority;
  late String _status;
  late int _assignedUserId;
  DateTime? _reminderDate;

  final List<String> priorities = ['High', 'Medium', 'Low'];
  final List<String> statuses = ['To-Do', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _dueDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = widget.task?.priority ?? 'Medium';
    _status = widget.task?.status ?? 'To-Do';
    _assignedUserId = widget.task?.assignedUserId ?? 1;
    _reminderDate = widget.task?.reminderDate;

    // Load users if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.users.isEmpty) {
        userProvider.loadUsers();
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _dueDate : _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _reminderDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Due Date: '),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                items: priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items: statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _assignedUserId,
                items: [
                  for (final user in userProvider.users)
                    DropdownMenuItem<int>(
                      value: user.id,
                      child: Text('${user.firstName} ${user.lastName}'),
                    )
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _assignedUserId = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Assigned User',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Set Reminder: '),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                      _reminderDate != null
                          ? '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year}'
                          : 'No reminder',
                    ),
                  ),
                  if (_reminderDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _reminderDate = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final task = TaskModel(
                      id: widget.task?.id ??
                          'local_${DateTime.now().millisecondsSinceEpoch}',
                      title: _titleController.text,
                      description: _descriptionController.text,
                      dueDate: _dueDate,
                      priority: _priority,
                      status: _status,
                      assignedUserId: _assignedUserId,
                      isSynced: widget.task?.isSynced ?? false,
                      reminderDate: _reminderDate,
                      createdAt: widget.task?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    if (widget.task == null) {
                      await taskProvider.createTask(task.toEntity());
                    } else {
                      await taskProvider.updateTask(task.toEntity());
                    }

                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
