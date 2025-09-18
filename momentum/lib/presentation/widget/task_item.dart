// lib/presentation/widgets/task_item.dart
import 'package:flutter/material.dart';
import 'package:task_management/domain/entities/task_entity.dart';

import '../themes/app_colors.dart';
import 'priority_indicator.dart';

class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onToggleStatus,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'To-Do':
        return AppColors.statusTodo;
      case 'In Progress':
        return AppColors.statusInProgress;
      case 'Done':
        return AppColors.statusDone;
      default:
        return AppColors.statusTodo;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'To-Do':
        return Icons.radio_button_unchecked;
      case 'In Progress':
        return Icons.adjust;
      case 'Done':
        return Icons.check_circle;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          icon: Icon(_getStatusIcon(task.status)),
          color: _getStatusColor(task.status),
          onPressed: onToggleStatus,
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: task.status == 'Done' 
                    ? TextDecoration.lineThrough 
                    : TextDecoration.none,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                PriorityIndicator(priority: task.priority),
                const SizedBox(width: 8),
                Text(
                  'Due: ${_formatDate(task.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Theme.of(context).colorScheme.error,
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays < 0) {
      return '${difference.inDays.abs()} days ago';
    } else {
      return 'In ${difference.inDays} days';
    }
  }
}