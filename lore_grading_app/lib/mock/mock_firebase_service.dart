import 'dart:developer' as developer;

class MockFirebaseService {
  // Static in-memory lists representing the remote Firestore collections
  static final List<Map<String, dynamic>> _remoteTasks = [
    {
      'id': 't1',
      'title': 'Math Assignment: Calculus Limits',
      'description': 'Solve problems 1 to 15 on page 42. Show all workings.',
      'dueDate': DateTime.now().add(const Duration(days: 1, hours: 3)).toIso8601String(),
      'isCompleted': false,
    },
    {
      'id': 't2',
      'title': 'Chemistry Lab Report',
      'description': 'Write up the observations and conclusion for the Titration experiment.',
      'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'isCompleted': false,
    },
    {
      'id': 't3',
      'title': 'English Literature Reading',
      'description': 'Read Chapters 4 and 5 of "To Kill a Mockingbird" and write a summary paragraph.',
      'dueDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'isCompleted': true,
    },
  ];

  static final List<Map<String, dynamic>> _remoteGrades = [
    {
      'id': 'g1',
      'subject': 'Mathematics',
      'assignmentName': 'Calculus Quiz 1',
      'score': 18.5,
      'maxScore': 20.0,
      'weight': 0.10,
      'date': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      'teacherComments': 'Great work! You demonstrated an excellent understanding of limits.',
      'category': 'Quiz',
    },
    {
      'id': 'g2',
      'subject': 'Mathematics',
      'assignmentName': 'Midterm Exam',
      'score': 84.0,
      'maxScore': 100.0,
      'weight': 0.30,
      'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'teacherComments': 'Very good score. Pay attention to minor arithmetic details next time.',
      'category': 'Exam',
    },
    {
      'id': 'g3',
      'subject': 'Mathematics',
      'assignmentName': 'Derivatives Homework',
      'score': 10.0,
      'maxScore': 10.0,
      'weight': 0.05,
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'teacherComments': 'Perfect submission!',
      'category': 'Homework',
    },
    {
      'id': 'g4',
      'subject': 'Science',
      'assignmentName': 'Physics Forces Lab',
      'score': 42.0,
      'maxScore': 50.0,
      'weight': 0.15,
      'date': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
      'teacherComments': 'Lab methodology was sound, but conclusion paragraph lacked detail.',
      'category': 'Lab',
    },
    {
      'id': 'g5',
      'subject': 'Science',
      'assignmentName': 'Chemistry Acid-Base Quiz',
      'score': 22.0,
      'maxScore': 25.0,
      'weight': 0.10,
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'teacherComments': 'Excellent titration analysis.',
      'category': 'Quiz',
    },
    {
      'id': 'g6',
      'subject': 'English Literature',
      'assignmentName': 'Poetry Analysis Essay',
      'score': 91.0,
      'maxScore': 100.0,
      'weight': 0.25,
      'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'teacherComments': 'Beautiful prose and excellent insight into the symbolism of the poem.',
      'category': 'Project',
    },
  ];

  // Helper to simulate API network response delays
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // --- Task API Operations ---

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    developer.log('MockFirebaseService: Fetching tasks from cloud...');
    await _simulateNetworkDelay();
    return List<Map<String, dynamic>>.from(_remoteTasks);
  }

  Future<void> uploadTask(Map<String, dynamic> taskJson) async {
    developer.log('MockFirebaseService: Uploading task to cloud... ID: ${taskJson['id']}');
    await _simulateNetworkDelay();
    
    // Remove if already exists (updating)
    _remoteTasks.removeWhere((item) => item['id'] == taskJson['id']);
    _remoteTasks.add(taskJson);
    developer.log('MockFirebaseService: Task uploaded successfully.');
  }

  Future<void> deleteTask(String id) async {
    developer.log('MockFirebaseService: Deleting task from cloud... ID: $id');
    await _simulateNetworkDelay();
    _remoteTasks.removeWhere((item) => item['id'] == id);
    developer.log('MockFirebaseService: Task deleted from cloud.');
  }

  // --- Grade API Operations ---

  Future<List<Map<String, dynamic>>> fetchGrades() async {
    developer.log('MockFirebaseService: Fetching grades from cloud...');
    await _simulateNetworkDelay();
    return List<Map<String, dynamic>>.from(_remoteGrades);
  }

  Future<void> uploadGrade(Map<String, dynamic> gradeJson) async {
    developer.log('MockFirebaseService: Uploading grade to cloud... ID: ${gradeJson['id']}');
    await _simulateNetworkDelay();
    _remoteGrades.removeWhere((item) => item['id'] == gradeJson['id']);
    _remoteGrades.add(gradeJson);
    developer.log('MockFirebaseService: Grade uploaded successfully.');
  }
}
