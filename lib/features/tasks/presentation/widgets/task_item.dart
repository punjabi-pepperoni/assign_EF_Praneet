import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Custom Circular Checkbox
          InkWell(
            onTap: () {
              final updatedTask = Task(
                id: task.id,
                title: task.title,
                isCompleted: !task.isCompleted,
                userId: task.userId,
              );
              context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: task.isCompleted ? Colors.blue : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "20 Jan", // Placeholder date as per mockup, ideally dynamic
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _showEditDialog(context, task);
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }

  void _showEditDialog(BuildContext context, Task task) {
    final TextEditingController controller =
        TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter task title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final updatedTask = Task(
                    id: task.id,
                    title: controller.text,
                    isCompleted: task.isCompleted,
                    userId: task.userId,
                  );
                  context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F0071),
                  foregroundColor: Colors.white),
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
