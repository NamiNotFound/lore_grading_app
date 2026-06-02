import 'package:flutter/foundation.dart';
import 'package:lore_grading_app/models/grade.dart';
import 'package:lore_grading_app/services/database_helper.dart';

class GradeProvider with ChangeNotifier {
  List<Grade> _grades = [];
  bool _isLoading = false;
  String _selectedSubjectFilter = 'All';

  List<Grade> get allGrades => List.unmodifiable(_grades);
  String get selectedSubjectFilter => _selectedSubjectFilter;
  bool get isLoading => _isLoading;

  Future<void> loadGrades() async {
    _isLoading = true;
    notifyListeners();

    try {
      _grades = await DatabaseHelper.instance.getGrades();
    } catch (e) {
      if (kDebugMode) print('Error loading grades: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSubjectFilter(String subject) {
    _selectedSubjectFilter = subject;
    notifyListeners();
  }

  List<String> get uniqueSubjects {
    final subjects = _grades.map((g) => g.subject).toSet().toList();
    subjects.sort();
    return ['All', ...subjects];
  }

  List<Grade> get filteredGrades {
    if (_selectedSubjectFilter == 'All') {
      return _grades;
    }
    return _grades.where((g) => g.subject == _selectedSubjectFilter).toList();
  }

  List<Grade> get recentGrades {
    final sorted = List<Grade>.from(_grades);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(4).toList();
  }

  Map<String, double> get subjectAverages {
    final Map<String, List<Grade>> grouped = {};
    for (var grade in _grades) {
      grouped.putIfAbsent(grade.subject, () => []).add(grade);
    }

    final Map<String, double> averages = {};
    grouped.forEach((subject, subjectGrades) {
      double totalScorePercentage = 0.0;
      for (var grade in subjectGrades) {
        totalScorePercentage += grade.percentage;
      }
      averages[subject] = totalScorePercentage / subjectGrades.length;
    });

    return averages;
  }

  double get overallAverage {
    final averages = subjectAverages.values;
    if (averages.isEmpty) return 0.0;
    return averages.reduce((a, b) => a + b) / averages.length;
  }

  double get gpa {
    final averages = subjectAverages;
    if (averages.isEmpty) return 0.0;

    double totalGpaPoints = 0.0;
    averages.forEach((subject, pct) {
      totalGpaPoints += _gpaPointsFromPercentage(pct);
    });

    return totalGpaPoints / averages.length;
  }

  String get overallLetterGrade {
    final avg = overallAverage;
    if (avg >= 90) return 'A';
    if (avg >= 80) return 'B';
    if (avg >= 70) return 'C';
    if (avg >= 60) return 'D';
    return 'F';
  }

  double _gpaPointsFromPercentage(double pct) {
    if (pct >= 90) return 4.0;
    if (pct >= 85) return 3.7;
    if (pct >= 80) return 3.3;
    if (pct >= 75) return 3.0;
    if (pct >= 70) return 2.7;
    if (pct >= 65) return 2.3;
    if (pct >= 60) return 2.0;
    if (pct >= 55) return 1.7;
    if (pct >= 50) return 1.0;
    return 0.0;
  }
}
