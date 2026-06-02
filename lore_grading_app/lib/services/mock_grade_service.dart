import 'dart:developer' as developer;

class MockGradeService {
  // In-memory list representing grades (mocking external API response)
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

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // --- Grade API Operations ---

  Future<List<Map<String, dynamic>>> fetchGrades() async {
    developer.log('MockGradeService: Fetching grades from mock API endpoint...');
    await _simulateNetworkDelay();
    return List<Map<String, dynamic>>.from(_remoteGrades);
  }
}
