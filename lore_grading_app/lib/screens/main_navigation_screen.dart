import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lore_grading_app/provider/todo_provider.dart';
import 'package:lore_grading_app/provider/grade_provider.dart';
import 'package:lore_grading_app/provider/connection_provider.dart';
import 'package:lore_grading_app/provider/theme_provider.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

      // Trigger initial background sync with Firestore
      connProv.triggerSync(
        onSyncStart: () {},
        onSyncComplete: () {
          // Refresh providers after sync finishes to pull any new Firestore items
          todoProv.loadTasks();
          gradeProv.loadGrades();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    // Callback to open drawer on mobile/narrow screens
    final VoidCallback? onMenuPressed = isWide
        ? null
        : () {
            _scaffoldKey.currentState?.openDrawer();
          };

    final List<Widget> screens = [
      DashboardScreen(onMenuPressed: onMenuPressed),
      GradingScreen(onMenuPressed: onMenuPressed),
      TodoScreen(onMenuPressed: onMenuPressed),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide
          ? null
          : Drawer(elevation: 4, child: _buildSidebar(context, isDrawer: true)),
      body: Row(
        children: [
          if (isWide) _buildSidebar(context, isDrawer: false),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final connectionProvider = Provider.of<ConnectionProvider>(context);

    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / App Title
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LORE Grading',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'JL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jena mae Lore',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Honor Student',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSidebarNavItem(
                    context: context,
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                    isDrawer: isDrawer,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarNavItem(
                    context: context,
                    index: 1,
                    icon: Icons.assignment_outlined,
                    activeIcon: Icons.assignment,
                    label: 'Grade Report',
                    isDrawer: isDrawer,
                  ),
                  const SizedBox(height: 8),
                  _buildSidebarNavItem(
                    context: context,
                    index: 2,
                    icon: Icons.check_circle_outline,
                    activeIcon: Icons.check_circle,
                    label: 'Task Manager',
                    isDrawer: isDrawer,
                  ),
                ],
              ),
            ),

            // Footer Section (Toggles)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Connection Toggle Row
                    InkWell(
                      onTap: () {
                        if (isDrawer) {
                          Navigator.pop(context); // Close drawer first
                        }
                        connectionProvider.toggleConnection(
                          onSyncStart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Syncing local queue with Firestore...',
                                    ),
                                  ],
                                ),
                                duration: Duration(milliseconds: 1200),
                              ),
                            );
                          },
                          onSyncComplete: () {
                            Provider.of<TodoProvider>(
                              context,
                              listen: false,
                            ).loadTasks();
                            Provider.of<GradeProvider>(
                              context,
                              listen: false,
                            ).loadGrades();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sync complete! Firestore updated.',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  connectionProvider.isOnline
                                      ? Icons.wifi
                                      : Icons.wifi_off,
                                  size: 20,
                                  color: connectionProvider.isOnline
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  connectionProvider.isOnline
                                      ? 'Online'
                                      : 'Offline',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: connectionProvider.isOnline
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: connectionProvider.isOnline,
                              activeThumbColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              inactiveTrackColor: Colors.red.withOpacity(0.2),
                              onChanged: (_) {
                                if (isDrawer) {
                                  Navigator.pop(context);
                                }
                                connectionProvider.toggleConnection(
                                  onSyncStart: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Syncing local queue with Firestore...',
                                            ),
                                          ],
                                        ),
                                        duration: Duration(milliseconds: 1200),
                                      ),
                                    );
                                  },
                                  onSyncComplete: () {
                                    Provider.of<TodoProvider>(
                                      context,
                                      listen: false,
                                    ).loadTasks();
                                    Provider.of<GradeProvider>(
                                      context,
                                      listen: false,
                                    ).loadGrades();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Sync complete! Firestore updated.',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 16),

                    // Theme Toggle Row
                    InkWell(
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.dark_mode_outlined
                                      : Icons.light_mode_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  themeProvider.isDarkMode
                                      ? 'Dark Mode'
                                      : 'Light Mode',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (_) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDrawer,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        if (isDrawer) {
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withOpacity(0.2)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(width: 4),
            const SizedBox(width: 12),
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
