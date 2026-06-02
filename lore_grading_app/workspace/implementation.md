# Flutter Grading App Implementation Plan

We will create a premium-looking Flutter grading application for students. It will feature a sleek Dashboard, a full-featured To-Do list, and a comprehensive Grades viewer. The design will utilize rich, harmonious color palettes, modern typography, micro-interactions, and a clean card/glassmorphic aesthetic.

To ensure future integration with a teacher API is easy, we will structure the state management using `provider` so that the mock data repositories can easily be swapped with real HTTP service classes later.

---

## User Review Required

We are designing this application to be visually striking and production-ready. Please review the proposed list of features and architecture:

> [!IMPORTANT]
> - **State Management**: We are using the `provider` package to manage app state locally. When you receive the teacher API, we can easily swap the local repository/mock layer with an HTTP service calling the API.
> - **Visual Theme**: We are creating a custom modern dark/light scheme with violet, electric blue, and emerald accent gradients.
> - **Navigation**: A premium bottom navigation bar to switch between the Dashboard, Grades, and Todo screens.

---

## Proposed Changes

### Core Models

#### [NEW] [grade.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/models/grade.dart)
Define the `Grade` model with:
- `id` (String)
- `subject` (String)
- `assignmentName` (String)
- `score` (double)
- `maxScore` (double)
- `weight` (double) - weight percentage in course (e.g., 0.15 for 15%)
- `date` (DateTime)
- `teacherComments` (String)
- `category` (String) - e.g. Homework, Quiz, Exam, Project

### State Management (Providers)

#### [NEW] [todo_provider.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/provider/todo_provider.dart)
Manage task status, adding, editing, completing, and deleting tasks. It will persist tasks locally (optional, can save to memory/mock or shared preferences) and offer filter options (All, Pending, Completed).

#### [NEW] [grade_provider.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/provider/grade_provider.dart)
Manage student grades. It will offer computed properties:
- Overall GPA (on a 4.0 scale) and weighted class average.
- List of grades grouped by subject.
- Grade distribution metrics for charts.
- Recent grades (e.g., last 3 graded assignments).

---

### UI Screens

#### [NEW] [dashboard_screen.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/screens/dashboard_screen.dart)
The main student landing screen featuring:
- **Header Card**: Beautiful gradient card showing the student's name, overall GPA (e.g., 3.82 / A), and class rank or overall progress ring.
- **Subject Grid**: Horizontal scroll of subjects showing the current letter grade and progress bar for each subject (e.g., Math: A, Science: B+).
- **Upcoming Tasks**: Mini-view of the top 3 upcoming due items from the Todo Provider.
- **Recent Grades**: Scrollable list of the latest graded items.

#### [NEW] [todo_screen.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/screens/todo_screen.dart)
The task management screen featuring:
- Tab controllers or custom chip filters (All, Pending, Completed).
- Custom cards with checkmark animation, priority level colors, and time-remaining badges.
- Bottom sheet modal for adding/editing tasks (fields: Title, Description, Subject, Due Date, Priority).

#### [NEW] [grading_screen.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/screens/grading_screen.dart)
The grades archive screen featuring:
- Subject filter chips.
- Interactive list: Tap a grade to expand and reveal full details, including a weighted percentage bar and the teacher's feedback text in a nice speech bubble design.
- Simple visual bar chart showing grade progress over time.

#### [NEW] [main_navigation_screen.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/screens/main_navigation_screen.dart)
App container managing navigation states between Dashboard, Grades, and Todo lists with a sleek floating or glassmorphic bottom navigation bar.

---

### Main & Configuration

#### [MODIFY] [main.dart](file:///c:/Users/840G3/Documents/Flutter/lore_grading_app/lib/main.dart)
- Replace default placeholder code.
- Initialize providers (`MultiProvider`).
- Set up custom theme configuration (modern dark mode by default, or sleek deep space theme with rounded shapes and custom transitions).
- Point `home` to `MainNavigationScreen`.

---

## Verification Plan

### Manual Verification
- Run the Flutter app on Windows or Web target.
- Verify adding, completing, editing, and deleting a Todo task.
- Verify changing filters on the Todo screen.
- Verify tapping grades to see detailed popups.
- Verify correct calculation of overall GPA and average grades on the Dashboard.
