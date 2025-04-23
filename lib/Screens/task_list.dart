import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Screens/task_details.dart';
import 'package:to_do_list/Screens/task_edit.dart';
import '../Models/task_model.dart';
import '../Provider/task_provider.dart';
import '../Provider/theme_provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _showCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final allTasks = taskProvider.tasks;

    // Split tasks into pending and completed
    final pendingTasks = allTasks.where((task) => !task.isCompleted).toList();
    final completedTasks = allTasks.where((task) => task.isCompleted).toList();

    // Sort pending tasks by deadline
    pendingTasks.sort((a, b) {
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    // Sort completed tasks by deadline as well
    completedTasks.sort((a, b) {
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    final upcomingTask = pendingTasks.firstWhere(
          (task) => task.deadline != null && task.deadline!.isAfter(DateTime.now()),
      orElse: () => pendingTasks.isNotEmpty ? pendingTasks.first : Task.empty(),
    );

    final remainingPendingTasks = pendingTasks
        .where((task) => task.id != upcomingTask.id || task.id == '')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: allTasks.isEmpty
          ? const Center(child: Text('No tasks yet. Add a new task to get started!'))
          : ListView(
        children: [
          if (upcomingTask.id != '')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                        "Upcoming Task",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ),
                  TaskListItem(task: upcomingTask, isUpcoming: true),
                ],
              ),
            ),


          if (remainingPendingTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  upcomingTask.id != '' ? "Other Pending Tasks" : "Pending Tasks",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),

          ...remainingPendingTasks.map((task) => TaskListItem(task: task)).toList(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                    "Completed Tasks (${completedTasks.length})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showCompletedTasks = !_showCompletedTasks;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _showCompletedTasks ? "Hide" : "Show",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _showCompletedTasks
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Show completed tasks if toggled on
          if (_showCompletedTasks)
            ...completedTasks.map((task) =>
                TaskListItem(task: task, isCompleted: true)).toList(),

          // Add some padding at the bottom for better UX with FAB
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskEditScreen(isNewTask: true)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final bool isUpcoming;
  final bool isCompleted;

  const TaskListItem({
    Key? key,
    required this.task,
    this.isUpcoming = false,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final now = DateTime.now();
    final isToday = task.deadline != null &&
        task.deadline!.year == now.year &&
        task.deadline!.month == now.month &&
        task.deadline!.day == now.day;

    Color? cardColor;
    if (isUpcoming) {
      cardColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    } else if (isCompleted) {
      cardColor = Colors.grey.withOpacity(0.1);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      elevation: isUpcoming ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? BorderSide(color: Colors.grey.withOpacity(0.3))
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.grey[300]
                : (isToday ? Colors.green : Colors.grey[300]),
          ),
          child: Center(
            child: task.deadline != null
                ? Text(
              task.deadline!.day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isToday && !isCompleted ? 18 : 14,
                color: isToday && !isCompleted ? Colors.white : Colors.black,
              ),
            )
                : Icon(
              Icons.event_note,
              color: isCompleted ? Colors.grey : null,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
            if (task.deadline != null)
              Text(
                'Due: ${_formatDateTime(task.deadline!)}',
                style: TextStyle(
                  color: isCompleted
                      ? Colors.grey
                      : (task.deadline!.isBefore(DateTime.now())
                      ? Colors.red
                      : null),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
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
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
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
          },
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${_formatDate(dateTime)} at $hour:$minute';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}