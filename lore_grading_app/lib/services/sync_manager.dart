import 'dart:developer' as developer;
import 'package:lore_grading_app/mock/mock_firebase_service.dart';
import 'package:lore_grading_app/services/database_helper.dart';
import 'package:lore_grading_app/models/task.dart';
import 'package:lore_grading_app/models/grade.dart';

class SyncManager {
  static final SyncManager instance = SyncManager._init();
  final MockFirebaseService _mockFirebase = MockFirebaseService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  SyncManager._init();

  // --- Task Syncing ---

  Future<void> syncTasks(bool isOnline) async {
    if (!isOnline) {
      developer.log('SyncManager: Device is offline. Queueing tasks locally.');
      return;
    }

    developer.log('SyncManager: Device is online. Starting task synchronization...');
    try {
      // 1. Process soft-deleted tasks (delete on remote first, then clear locally)
      final deletedTasks = await _dbHelper.getDeletedTasks();
      if (deletedTasks.isNotEmpty) {
        developer.log('SyncManager: Found ${deletedTasks.length} soft-deleted tasks to sync.');
        for (var row in deletedTasks) {
          final id = row['id'] as String;
          await _mockFirebase.deleteTask(id);
          await _dbHelper.deleteTaskHard(id);
        }
        developer.log('SyncManager: Soft-deleted tasks synced and purged locally.');
      }

      // 2. Upload local unsynced creations and updates
      final unsyncedTasks = await _dbHelper.getUnsyncedTasks();
      if (unsyncedTasks.isNotEmpty) {
        developer.log('SyncManager: Found ${unsyncedTasks.length} unsynced tasks to upload.');
        final List<String> syncedIds = [];
        for (var row in unsyncedTasks) {
          final map = Map<String, dynamic>.from(row);
          // sqlite stores boolean as integer, convert back for firestore
          map['isCompleted'] = map['isCompleted'] == 1;
          
          // Remove internal sync columns before uploading
          map.remove('is_synced');
          map.remove('is_deleted');

          await _mockFirebase.uploadTask(map);
          syncedIds.add(map['id'] as String);
        }
        await _dbHelper.markTasksAsSynced(syncedIds);
        developer.log('SyncManager: Uploaded and marked ${syncedIds.length} tasks as synced.');
      }

      // 3. Pull new updates from remote Firestore to SQLite (Conflict resolution: local unsynced takes priority)
      final remoteTasksJson = await _mockFirebase.fetchTasks();
      developer.log('SyncManager: Fetched ${remoteTasksJson.length} tasks from cloud database.');
      for (var remoteJson in remoteTasksJson) {
        final id = remoteJson['id'] as String;
        
        // Check if there is an unsynced local version of this task
        final isSynced = await _dbHelper.isTaskSynced(id);
        final rawTasks = await _dbHelper.getRawTasks();
        final localExists = rawTasks.any((row) => row['id'] == id);

        if (!localExists || isSynced) {
          // It's safe to overwrite/insert the remote version locally
          final task = Task.fromJson(remoteJson);
          await _dbHelper.insertTask(task, isSynced: 1);
        } else {
          developer.log('SyncManager: Conflict detected for task ID: $id. Unsynced local modification takes priority.');
        }
      }
      developer.log('SyncManager: Task synchronization completed successfully.');
    } catch (e) {
      developer.log('SyncManager: Error synchronizing tasks: $e');
    }
  }

  // --- Grade Syncing ---

  Future<void> syncGrades(bool isOnline) async {
    if (!isOnline) {
      developer.log('SyncManager: Device is offline. Cannot sync grades.');
      return;
    }

    developer.log('SyncManager: Device is online. Synchronizing grades...');
    try {
      // Grades are usually managed by the teacher, so this is mostly a PULL operation.
      // 1. Fetch remote grades from Firestore
      final remoteGradesJson = await _mockFirebase.fetchGrades();
      developer.log('SyncManager: Fetched ${remoteGradesJson.length} grades from cloud.');

      // 2. Overwrite local grades database with cloud data
      for (var remoteJson in remoteGradesJson) {
        final grade = Grade.fromJson(remoteJson);
        await _dbHelper.insertGrade(grade, isSynced: 1);
      }
      developer.log('SyncManager: Grades synchronized successfully.');
    } catch (e) {
      developer.log('SyncManager: Error synchronizing grades: $e');
    }
  }
}
