import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Models/task_model.dart';
import '../Provider/task_provider.dart';

class TaskEditScreen extends StatefulWidget {
final bool isNewTask;
final Task? task;

const TaskEditScreen({
Key? key,
required this.isNewTask,
this.task,
}) : super(key: key);

@override
TaskEditScreenState createState() => TaskEditScreenState();
}

class TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (!widget.isNewTask && widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _deadline = widget.task!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        DateTime focusedDay = _deadline ?? DateTime.now();
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(_deadline, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _deadline = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                      _deadline?.hour ?? 0,
                      _deadline?.minute ?? 0,
                    );
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDateTime = _deadline ?? now;

    final isToday = _deadline != null &&
        _deadline!.year == now.year &&
        _deadline!.month == now.month &&
        _deadline!.day == now.day;

    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDateTime);
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final selectedDateTime = DateTime(
        _deadline?.year ?? now.year,
        _deadline?.month ?? now.month,
        _deadline?.day ?? now.day,
        picked.hour,
        picked.minute,
      );

      if (isToday && selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a future time')),
        );
        return;
      }

      setState(() {
        _deadline = selectedDateTime;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (widget.isNewTask) {
        final newTask = Task(
          id: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          deadline: _deadline,
        );
        taskProvider.addTask(newTask);
      } else if (widget.task != null) {
        final updatedTask = Task(
          id: widget.task!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          isCompleted: widget.task!.isCompleted,
          deadline: _deadline,
        );
        taskProvider.updateTask(updatedTask);
      }

      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewTask ? 'Add Task' : 'Edit Task'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deadline (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _deadline == null
                                  ? 'No deadline set'
                                  : 'Date: ${_formatDate(_deadline!)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _openCalendar(context),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      if (_deadline != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Time: ${_formatTime(_deadline!)}',
                              ),
                            ),
                            TextButton(
                              onPressed: () => _selectTime(context),
                              child: const Text('Select Time'),
                            ),
                          ],
                        ),
                      if (_deadline != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _deadline = null;
                            });
                          },
                          child: const Text('Clear Deadline'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.isNewTask ? 'Add Task' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}