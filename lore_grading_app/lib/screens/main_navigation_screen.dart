import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lore_grading_app/provider/todo_provider.dart';
import 'package:lore_grading_app/provider/grade_provider.dart';
import 'package:lore_grading_app/provider/connection_provider.dart';
import 'package:lore_grading_app/screens/dashboard_screen.dart';
import 'package:lore_grading_app/screens/grading_screen.dart';
import 'package:lore_grading_app/screens/todo_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load local SQLite database records on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todoProv = Provider.of<TodoProvider>(context, listen: false);
      final gradeProv = Provider.of<GradeProvider>(context, listen: false);
      final connProv = Provider.of<ConnectionProvider>(context, listen: false);

      todoProv.loadTasks();
      gradeProv.loadGrades();

      // Trigger initial background sync with mock cloud database
      connProv.triggerSync(
        onSyncStart: () {},
        onSyncComplete: () {
          // Refresh providers after sync finishes to pull any new cloud items
          todoProv.loadTasks();
          gradeProv.loadGrades();
        },
      );
    });
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    GradingScreen(),
    TodoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBody: true, // Allows the body to flow underneath the transparent navigation bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 76,
              color: theme.cardColor.withOpacity(0.85),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                  _buildNavItem(1, Icons.assignment_outlined, Icons.assignment, 'Grades'),
                  _buildNavItem(2, Icons.check_circle_outline, Icons.check_circle, 'To-Do'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.5);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Row(
                children: [
                  if (isSelected) const SizedBox(width: 8),
                  if (isSelected)
                    Text(
                      label,
                      style: TextStyle(
                        color: activeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
