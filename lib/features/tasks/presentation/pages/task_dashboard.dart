import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_item.dart';

class TaskDashboard extends StatefulWidget {
  const TaskDashboard({super.key});

  @override
  State<TaskDashboard> createState() => _TaskDashboardState();
}

class _TaskDashboardState extends State<TaskDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D143E), // Darker Blue Background
      body: Stack(
        children: [
          // Blurred Color Effect
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0099).withOpacity(0.5),
                    blurRadius: 200,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue,
                        child: Text("U", style: TextStyle(color: Colors.white)),
                      ),
                      IconButton(
                          onPressed: () {
                            // Logout logic placeholder
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: const Icon(Icons.exit_to_app,
                              color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Date
                  const Text(
                    "Today, 21 January",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  const Text(
                    "My tasks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2685), // Slightly lighter blue
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search tasks...",
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Task List
                  Expanded(
                    child: BlocConsumer<TaskBloc, TaskState>(
                      listener: (context, state) {
                        if (state is TaskError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is TaskLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is TaskLoaded) {
                          if (state.tasks.isEmpty) {
                            return const Center(
                              child: Text(
                                "No Tasks Yet!",
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<TaskBloc>().add(LoadTasks());
                            },
                            child: ListView.builder(
                              itemCount: state.tasks.length,
                              itemBuilder: (context, index) {
                                return TaskItem(task: state.tasks[index]);
                              },
                            ),
                          );
                        }
                        return const Center(
                            child: Text("Welcome!",
                                style: TextStyle(color: Colors.white)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        // Actually mockup has a glowy blue button. Let's stick to theme but distinct.
        // Maybe purple from before: Color(0xFF3F0071)? Or simple blue.
        // Using the deep blue but maybe we customize it later.
        // Let's use a distinct color for visibility.
        backgroundColor: const Color(0xFF2D2685),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.white10)),
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add New Task"),
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
                  // Use the context from the parent widget (Dashboard) not the dialog
                  context.read<TaskBloc>().add(AddTaskEvent(controller.text));
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F0071),
                  foregroundColor: Colors.white),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
