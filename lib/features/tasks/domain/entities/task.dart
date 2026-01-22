import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.userId,
  });

  final String userId;

  @override
  List<Object> get props => [id, title, isCompleted, userId];
}
