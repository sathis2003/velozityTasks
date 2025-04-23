import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Screens/task_edit.dart';
import '../Models/task_model.dart';
import '../Provider/task_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and action buttons
            _buildHeader(context),

            // Task title
            const SizedBox(height: 16),
            Text(
              task.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Task content
            _buildInfoCard(
              context,
              icon: Icons.description,
              title: 'Description',
              content: task.description.isEmpty
                  ? 'No description provided'
                  : task.description,
            ),
            const SizedBox(height: 16),
            if (task.deadline != null)
              _buildInfoCard(
                context,
                icon: Icons.calendar_today,
                title: 'Deadline',
                content: _formatDateTime(task.deadline!),
                isOverdue: task.deadline!.isBefore(DateTime.now()) && !task.isCompleted,
              ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: 'Task ID',
              content: task.id,
            ),

            const SizedBox(height: 24),

            // Bottom action bar with completion toggle
            _buildCompletionToggle(context, taskProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: task.isCompleted ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              task.isCompleted ? 'Completed' : 'Pending',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Task',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskEditScreen(
                    isNewTask: false,
                    task: task,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Task',
            color: Colors.red,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        taskProvider.deleteTask(task.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
        bool isOverdue = false,
      }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isOverdue ? Colors.red : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isOverdue ? Colors.red : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: isOverdue ? Colors.red : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionToggle(BuildContext context, TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            taskProvider.toggleTaskCompletion(task.id);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            task.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$year-$month-$day at $hour:$minute';
  }
}
