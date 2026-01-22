import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask(String title);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  TaskRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) throw ServerFailure();
    return user.uid;
  }

  CollectionReference get _tasksCollection =>
      firestore.collection('users').doc(_userId).collection('tasks');

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _tasksCollection.get();
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<TaskModel> addTask(String title) async {
    try {
      final docRef = _tasksCollection.doc();
      final newTask = TaskModel(
        id: docRef.id,
        title: title,
        isCompleted: false,
        userId: _userId,
      );
      await docRef.set(newTask.toJson());
      return newTask;
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toJson());
      return task;
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
