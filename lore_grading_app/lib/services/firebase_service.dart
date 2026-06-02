import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for tasks
  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  // --- Task Operations ---

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    developer.log('FirebaseService: Fetching tasks from cloud Firestore...');
    try {
      final querySnapshot = await _tasksCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure ID is included in case it is missing or stored separately
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return data;
      }).toList();
    } catch (e) {
      developer.log('FirebaseService: Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<void> uploadTask(Map<String, dynamic> taskJson) async {
    final String id = taskJson['id'] as String;
    developer.log('FirebaseService: Uploading task to Firestore... ID: $id');
    try {
      // Use the task's ID as the Firestore document ID to avoid duplicates
      await _tasksCollection.doc(id).set(taskJson);
      developer.log('FirebaseService: Task uploaded successfully.');
    } catch (e) {
      developer.log('FirebaseService: Error uploading task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    developer.log('FirebaseService: Deleting task from Firestore... ID: $id');
    try {
      await _tasksCollection.doc(id).delete();
      developer.log('FirebaseService: Task deleted from cloud.');
    } catch (e) {
      developer.log('FirebaseService: Error deleting task: $e');
      rethrow;
    }
  }
}
