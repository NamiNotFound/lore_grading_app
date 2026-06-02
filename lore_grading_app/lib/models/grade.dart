class Grade {
  final String id;
  final String subject;
  final String assignmentName;
  final double score;
  final double maxScore;
  final double weight; // e.g. 0.15 for 15%
  final DateTime date;
  final String teacherComments;
  final String category; // Homework, Quiz, Exam, Project, etc.

  Grade({
    required this.id,
    required this.subject,
    required this.assignmentName,
    required this.score,
    required this.maxScore,
    required this.weight,
    required this.date,
    required this.teacherComments,
    required this.category,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0.0;

  String get letterGrade {
    final pct = percentage;
    if (pct >= 90) return 'A';
    if (pct >= 80) return 'B';
    if (pct >= 70) return 'C';
    if (pct >= 60) return 'D';
    return 'F';
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      assignmentName: json['assignmentName'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 100.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.1,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      teacherComments: json['teacherComments'] ?? '',
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'assignmentName': assignmentName,
      'score': score,
      'maxScore': maxScore,
      'weight': weight,
      'date': date.toIso8601String(),
      'teacherComments': teacherComments,
      'category': category,
    };
  }
}
