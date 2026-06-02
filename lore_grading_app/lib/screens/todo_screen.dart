import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lore_grading_app/provider/todo_provider.dart';
import 'package:lore_grading_app/provider/connection_provider.dart';
import 'package:lore_grading_app/models/task.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const TodoScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onMenuPressed,
              )
            : null,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: TaskFilter.values.map((filter) {
                  final isSelected = todoProvider.currentFilter == filter;
                  String label = '';
                  switch (filter) {
                    case TaskFilter.all:
                      label = 'All';
                      break;
                    case TaskFilter.pending:
                      label = 'Pending';
                      break;
                    case TaskFilter.completed:
                      label = 'Completed';
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        todoProvider.setFilter(filter);
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tasks List
            Expanded(
              child: todoProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : todoProvider.filteredTasks.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: todoProvider.filteredTasks.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final task = todoProvider.filteredTasks[index];
                            return _buildTaskCard(context, task, connectionProvider.isOnline);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskBottomSheet(context, isOnline: connectionProvider.isOnline),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    String message = 'No tasks found';
    IconData icon = Icons.check_circle_outline;

    if (Provider.of<TodoProvider>(context, listen: false).currentFilter == TaskFilter.pending) {
      message = 'All tasks completed! Great job! 🎉';
      icon = Icons.emoji_events_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, bool isOnline) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final theme = Theme.of(context);

    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    String dueText = '';
    Color dueColor = Colors.green;

    if (daysLeft < 0) {
      dueText = 'Overdue';
      dueColor = Colors.red;
    } else if (daysLeft == 0) {
      dueText = 'Due Today';
      dueColor = Colors.orange;
    } else if (daysLeft == 1) {
      dueText = 'Due Tomorrow';
      dueColor = Colors.orange;
    } else {
      dueText = 'Due ${DateFormat('MMM d').format(task.dueDate)}';
      dueColor = theme.colorScheme.primary;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        todoProvider.deleteTask(task.id, isOnline);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                todoProvider.addTask(task, isOnline);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showTaskBottomSheet(context, task: task, isOnline: isOnline),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Custom animated checkbox
                IconButton(
                  icon: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 26,
                  ),
                  onPressed: () {
                    todoProvider.toggleTaskStatus(task.id, isOnline);
                  },
                ),
                const SizedBox(width: 8),

                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                color: task.isCompleted ? theme.colorScheme.onSurface.withOpacity(0.4) : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Synced status cloud icon
                          Icon(
                            task.isSynced ? Icons.cloud_done : Icons.cloud_off,
                            size: 16,
                            color: task.isSynced
                                ? Colors.green.withOpacity(0.7)
                                : Colors.amber.withOpacity(0.7),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Due Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: dueColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dueText,
                    style: TextStyle(
                      color: dueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskBottomSheet(BuildContext context, {Task? task, required bool isOnline}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    DateTime selectedDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.dialogBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    task == null ? 'Create New Task' : 'Edit Task',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title Text Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Text Field
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker Row
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                    title: const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(DateFormat('EEEE, MMMM d, y').format(selectedDate)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a task title')),
                          );
                          return;
                        }

                        final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                        if (task == null) {
                          // Add new task
                          final newTask = Task(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            dueDate: selectedDate,
                          );
                          todoProvider.addTask(newTask, isOnline);
                        } else {
                          // Update existing task
                          todoProvider.updateTask(
                            task.id,
                            titleController.text.trim(),
                            descController.text.trim(),
                            selectedDate,
                            isOnline,
                          );
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        task == null ? 'Create Task' : 'Save Changes',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
