import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:granada_navigation_app/demo_auth.dart';
import 'package:granada_navigation_app/main.dart';
import 'package:granada_navigation_app/social_media/create_post_sheet.dart';

void main() {
  setUp(() {
    DemoAuth.logout();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  Future<void> launchApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(const StudentApp());
    await tester.pumpAndSettle();
  }

  Future<void> loginAdmin(WidgetTester tester) async {
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'admin');
    await tester.enterText(textFields.at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  testWidgets('Test 1: Open the application - Login appears first',
      (WidgetTester tester) async {
    await launchApp(tester);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('Test 2: Submit empty login fields - Validation messages appear',
      (WidgetTester tester) async {
    await launchApp(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('Test 3: Enter incorrect credentials - Login is rejected',
      (WidgetTester tester) async {
    await launchApp(tester);
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'wronguser');
    await tester.enterText(textFields.at(1), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('Test 4 & 5: Enter admin / admin123 - Dashboard opens with greeting',
      (WidgetTester tester) async {
    await launchApp(tester);
    await loginAdmin(tester);

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Welcome, admin!'), findsOneWidget);
  });

  testWidgets('Test 6 & 7: Calculator operations & state preservation across tab switches',
      (WidgetTester tester) async {
    await launchApp(tester);
    await loginAdmin(tester);

    // Open Calculator tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Calculator'));
    await tester.pumpAndSettle();

    // Enter 10 and 5
    final numInputs = find.byType(TextField);
    await tester.enterText(numInputs.at(0), '10');
    await tester.enterText(numInputs.at(1), '5');

    // Tap +
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pumpAndSettle();

    // Check result 15.0
    expect(find.text('15.0'), findsOneWidget);

    // Switch tabs to Dashboard and return to Calculator
    await tester.tap(find.widgetWithText(NavigationDestination, 'Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Calculator'));
    await tester.pumpAndSettle();

    // Verify inputs and result remain
    expect(find.text('15.0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('Test 8, 9, 10: Social post, like, comment, and state preservation across tab switches',
      (WidgetTester tester) async {
    await launchApp(tester);
    await loginAdmin(tester);

    // Open Social tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Social'));
    await tester.pumpAndSettle();

    // Create a social post
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final sheetInputs = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetInputs.at(0), 'Admin testing post');
    await tester.enterText(sheetInputs.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Test 8: Post displays the logged-in username
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('Admin testing post'), findsOneWidget);

    // Test 9: Like a post and add a comment
    final likeButtons = find.widgetWithText(TextButton, 'Like');
    await tester.tap(likeButtons.first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    await tester.enterText(commentField, 'Great admin comment');
    await tester.tap(find.byTooltip('Send comment').first);
    await tester.pumpAndSettle();

    expect(find.text('Great admin comment'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);

    // Test 10: Switch tabs and return to Social
    await tester.tap(find.widgetWithText(NavigationDestination, 'Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Social'));
    await tester.pumpAndSettle();

    expect(find.text('Admin testing post'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Great admin comment'), findsOneWidget);
  });

  testWidgets('Test 11 & 12: Open Profile and Logout',
      (WidgetTester tester) async {
    await launchApp(tester);
    await loginAdmin(tester);

    // Open Profile
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();

    // Check student info and username
    expect(find.text('Geoff Patrick L. Granada'), findsOneWidget);
    expect(find.text('557191'), findsOneWidget);
    expect(find.text('BSIT — 3447'), findsOneWidget);
    expect(find.text('Logged in as: admin'), findsOneWidget);

    // Tap Logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Verify Login appears and DemoAuth session is cleared
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);
  });

  testWidgets('Test 13 & 14: Register a valid account, log in, view dashboard greeting, and create post',
      (WidgetTester tester) async {
    await launchApp(tester);

    // Tap Register
    await tester.tap(find.widgetWithText(TextButton, "Don't have an account? Register"));
    await tester.pumpAndSettle();

    // Fill valid registration
    final regInputs = find.byType(TextFormField);
    await tester.enterText(regInputs.at(0), 'geoff_user');
    await tester.enterText(regInputs.at(1), 'password123');
    await tester.enterText(regInputs.at(2), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Dismiss any snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Login with registered user
    final loginInputs = find.byType(TextFormField);
    await tester.enterText(loginInputs.at(0), 'geoff_user');
    await tester.enterText(loginInputs.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Test 13: Dashboard displays the registered username
    expect(find.text('Welcome, geoff_user!'), findsOneWidget);

    // Open Social tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Social'));
    await tester.pumpAndSettle();

    // Create post
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final sheetInputs = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetInputs.at(0), 'Post by geoff_user');
    await tester.enterText(sheetInputs.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Test 14: Post displays the registered username
    expect(find.text('geoff_user'), findsOneWidget);
    expect(find.text('Post by geoff_user'), findsOneWidget);
  });
}
