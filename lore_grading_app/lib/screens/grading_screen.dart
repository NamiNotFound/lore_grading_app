import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lore_grading_app/provider/grade_provider.dart';
import 'package:lore_grading_app/models/grade.dart';
import 'package:intl/intl.dart';

class GradingScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const GradingScreen({super.key, this.onMenuPressed});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  // Track expanded grade card IDs
  final Set<String> _expandedGradeIds = {};

  void _toggleExpansion(String id) {
    setState(() {
      if (_expandedGradeIds.contains(id)) {
        _expandedGradeIds.remove(id);
      } else {
        _expandedGradeIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final theme = Theme.of(context);

    // Calculate subject average for the header card
    String averageText = '';
    String letter = '';
    if (gradeProvider.selectedSubjectFilter == 'All') {
      averageText = '${gradeProvider.overallAverage.toStringAsFixed(1)}%';
      letter = gradeProvider.overallLetterGrade;
    } else {
      final average =
          gradeProvider.subjectAverages[gradeProvider.selectedSubjectFilter] ??
          0.0;
      averageText = '${average.toStringAsFixed(1)}%';
      if (average >= 90) {
        letter = 'A';
      } else if (average >= 80) {
        letter = 'B';
      } else if (average >= 70) {
        letter = 'C';
      } else if (average >= 60) {
        letter = 'D';
      } else {
        letter = 'F';
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        title: const Text(
          'Grade Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Dynamic Subject Filter Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: gradeProvider.uniqueSubjects.length,
                itemBuilder: (context, index) {
                  final subject = gradeProvider.uniqueSubjects[index];
                  final isSelected =
                      gradeProvider.selectedSubjectFilter == subject;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(subject),
                      selected: isSelected,
                      onSelected: (_) {
                        gradeProvider.setSubjectFilter(subject);
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Average Score Summary Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary.withOpacity(0.15),
                      theme.colorScheme.primary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gradeProvider.selectedSubjectFilter == 'All'
                              ? 'OVERALL ACADEMIC AVERAGE'
                              : '${gradeProvider.selectedSubjectFilter.toUpperCase()} AVERAGE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          averageText,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grades List View
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: gradeProvider.filteredGrades.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final grade = gradeProvider.filteredGrades[index];
                  final isExpanded = _expandedGradeIds.contains(grade.id);
                  return _buildGradeItem(context, grade, isExpanded);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeItem(BuildContext context, Grade grade, bool isExpanded) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM d, yyyy').format(grade.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _toggleExpansion(grade.id),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Row
                  Row(
                    children: [
                      // Letter indicator
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: _getGradeColor(
                            grade.percentage,
                            theme,
                          ).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          grade.letterGrade,
                          style: TextStyle(
                            color: _getGradeColor(grade.percentage, theme),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              grade.assignmentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  grade.subject,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    grade.category,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Scores
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${grade.score.toStringAsFixed(1)}/${grade.maxScore.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${grade.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Expanded Section
                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Stats Row (Weight & Date)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailStat(
                          'Weight',
                          '${(grade.weight * 100).toStringAsFixed(0)}%',
                          Icons.scale,
                        ),
                        _buildDetailStat(
                          'Graded On',
                          formattedDate,
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Teacher Comment Bubble
                    Text(
                      'Instructor Feedback',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              grade.teacherComments.isNotEmpty
                                  ? '"${grade.teacherComments}"'
                                  : '"No feedback comments provided."',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.85,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _getGradeColor(double pct, ThemeData theme) {
    if (pct >= 90) return Colors.green;
    if (pct >= 80) return theme.colorScheme.primary;
    if (pct >= 70) return Colors.orange;
    if (pct >= 60) return Colors.amber;
    return Colors.red;
  }
}
