import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_item.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskDashboard extends StatefulWidget {
  const TaskDashboard({super.key});

  @override
  State<TaskDashboard> createState() => _TaskDashboardState();
}

class _TaskDashboardState extends State<TaskDashboard> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
      child: Scaffold(
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
                      color: const Color(0xFFFF0099).withValues(alpha: 0.5),
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
                          child:
                              Text("U", style: TextStyle(color: Colors.white)),
                        ),
                        IconButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const LogoutRequested());
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
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                    const SizedBox(height: 24),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2685), // Slightly lighter blue
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search tasks...",
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.search, color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
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
                            final filteredTasks = state.tasks.where((task) {
                              return task.title
                                  .toLowerCase()
                                  .contains(searchQuery);
                            }).toList();

                            if (filteredTasks.isEmpty) {
                              return Center(
                                child: Text(
                                  searchQuery.isEmpty
                                      ? "No Tasks Yet!"
                                      : "No matching tasks found",
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              );
                            }
                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<TaskBloc>().add(LoadTasks());
                              },
                              child: ListView.builder(
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  return TaskItem(task: filteredTasks[index]);
                                },
                              ),
                            );
                          } else if (state is TaskError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.redAccent, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<TaskBloc>()
                                        .add(LoadTasks()),
                                    child: const Text("Retry"),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const Center(
                            child: Text(
                              "Get started by adding a task!",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
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
          backgroundColor: const Color(0xFF2D2685),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.white10)),
          onPressed: () {
            _showAddTaskDialog(context);
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
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
