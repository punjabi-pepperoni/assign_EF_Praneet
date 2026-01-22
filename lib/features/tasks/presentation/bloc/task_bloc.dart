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
      // Optimistic update or reload? Let's reload for simplicity first, or just append
      // Ideally: emit(TaskLoading()) -> add -> emit(TaskLoaded(newList))

      if (state is TaskLoaded) {
        // We could show a loading indicator overlay, but for now let's just trigger the add and then reload
        emit(TaskLoading());
        final result = await addTask(AddTaskParams(title: event.title));
        result.fold((failure) async {
          emit(const TaskError("Failed to add task"));
          // Reload to restore state
          add(LoadTasks());
        }, (newTask) {
          // Append locally immediately for speed? Or wait for reload?
          // Since we mocked list in data source, we can just reload or append.
          // Let's just reload to be safe and consistent with "source of truth".
          add(LoadTasks());
        });
      } else {
        add(LoadTasks());
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      if (state is TaskLoaded) {
        emit(TaskLoading());
        final result = await updateTask(UpdateTaskParams(task: event.task));
        result.fold(
          (failure) {
            emit(const TaskError("Failed to update task"));
            add(LoadTasks());
          },
          (_) => add(LoadTasks()),
        );
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      if (state is TaskLoaded) {
        emit(TaskLoading());
        final result = await deleteTask(DeleteTaskParams(id: event.id));
        result.fold(
          (failure) {
            emit(const TaskError("Failed to delete task"));
            add(LoadTasks());
          },
          (_) => add(LoadTasks()),
        );
      }
    });
  }
}
