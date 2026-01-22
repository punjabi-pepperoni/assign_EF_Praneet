import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      final result = await getTasks(NoParams());
      result.fold(
        (failure) => emit(const TaskError("Failed to load tasks")),
        (tasks) => emit(TaskLoaded(tasks)),
      );
    });

    on<AddTaskEvent>((event, emit) async {
      // Avoid full-screen loading if we already have tasks
      final currentState = state;
      if (currentState is TaskLoaded) {
        final result = await addTask(AddTaskParams(title: event.title));
        result.fold(
          (failure) => emit(const TaskError("Failed to add task")),
          (newTask) => add(LoadTasks()),
        );
      } else {
        emit(TaskLoading());
        final result = await addTask(AddTaskParams(title: event.title));
        result.fold(
          (failure) => emit(const TaskError("Failed to add task")),
          (newTask) => add(LoadTasks()),
        );
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final result = await updateTask(UpdateTaskParams(task: event.task));
        result.fold(
          (failure) => emit(const TaskError("Failed to update task")),
          (_) => add(LoadTasks()),
        );
      } else {
        emit(TaskLoading());
        add(LoadTasks());
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final result = await deleteTask(DeleteTaskParams(id: event.id));
        result.fold(
          (failure) => emit(const TaskError("Failed to delete task")),
          (_) => add(LoadTasks()),
        );
      } else {
        emit(TaskLoading());
        add(LoadTasks());
      }
    });
  }
}
