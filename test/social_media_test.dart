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

  Future<void> loginWithCredentials(WidgetTester tester, String username, String password) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(const StudentApp());
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), username);
    await tester.enterText(textFields.at(1), password);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  Future<void> openSocialMedia(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Social'));
    await tester.pumpAndSettle();
  }

  testWidgets('Test 1 & 2: Login with admin and open Social Media showing sample posts',
      (WidgetTester tester) async {
    await loginWithCredentials(tester, 'admin', 'admin123');
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await openSocialMedia(tester);
    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
    expect(find.text('JaneSmith'), findsOneWidget);
    expect(find.text('Just finished a great book!'), findsOneWidget);
  });

  testWidgets('Test 3: Submit a post with empty fields shows validation message',
      (WidgetTester tester) async {
    await loginWithCredentials(tester, 'admin', 'admin123');
    await openSocialMedia(tester);

    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pump();
    expect(find.text('Complete both fields before submitting!'), findsOneWidget);
  });

  testWidgets('Test 4: Submit a post with an invalid URL shows URL validation message',
      (WidgetTester tester) async {
    await loginWithCredentials(tester, 'admin', 'admin123');
    await openSocialMedia(tester);

    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final sheetInputs = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetInputs.at(0), 'My caption');
    await tester.enterText(sheetInputs.at(1), 'invalid-url-without-scheme');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pump();
    expect(find.text('Enter a valid HTTP or HTTPS image URL.'), findsOneWidget);
  });

  testWidgets('Test 5, 6, 7, 8: Valid post, Like twice, add comment, blank comment',
      (WidgetTester tester) async {
    await loginWithCredentials(tester, 'admin', 'admin123');
    await openSocialMedia(tester);

    // Create post
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final sheetInputs = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetInputs.at(0), 'My first Flutter social media post!');
    await tester.enterText(sheetInputs.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Confirm post is at top with username admin
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('My first Flutter social media post!'), findsOneWidget);

    // Like and unlike
    final likeButtons = find.widgetWithText(TextButton, 'Like');
    await tester.tap(likeButtons.first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Liked'));
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsNothing);

    // Re-like it
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    // Add comment
    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    await tester.enterText(commentField, 'Nice picture!');
    await tester.tap(find.byTooltip('Send comment').first);
    await tester.pumpAndSettle();

    expect(find.text('Nice picture!'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);

    // Blank comment
    await tester.enterText(commentField, '   ');
    await tester.tap(find.byTooltip('Send comment').first);
    await tester.pumpAndSettle();
    expect(find.text('1 Comments'), findsOneWidget);
  });

  testWidgets('Test 9 & 10: State preserved when switching tabs',
      (WidgetTester tester) async {
    await loginWithCredentials(tester, 'admin', 'admin123');
    await openSocialMedia(tester);

    // Create a post and like it
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final sheetInputs = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetInputs.at(0), 'Preserved post');
    await tester.enterText(sheetInputs.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    // Switch to Dashboard
    await tester.tap(find.widgetWithText(NavigationDestination, 'Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    // Switch back to Social
    await tester.tap(find.widgetWithText(NavigationDestination, 'Social'));
    await tester.pumpAndSettle();
    expect(find.text('Preserved post'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
  });

  testWidgets('Test 11: Logout, register new user, login, and create post with new username',
      (WidgetTester tester) async {
    await loginWithCredentials(tester, 'admin', 'admin123');

    // Go to Profile and logout
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);

    // Tap Register
    await tester.tap(find.widgetWithText(TextButton, "Don't have an account? Register"));
    await tester.pumpAndSettle();
    expect(find.text('Create an Account'), findsOneWidget);

    // Register user
    final regInputs = find.byType(TextFormField);
    await tester.enterText(regInputs.at(0), 'geoff');
    await tester.enterText(regInputs.at(1), 'secret123');
    await tester.enterText(regInputs.at(2), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Dismiss any snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Login with registered user
    final loginInputs = find.byType(TextFormField);
    await tester.enterText(loginInputs.at(0), 'geoff');
    await tester.enterText(loginInputs.at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(DemoAuth.currentUsername, 'geoff');

    // Go to Social Media
    await openSocialMedia(tester);

    // Create post as geoff
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final sheetInputs = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetInputs.at(0), 'Hello from Geoff!');
    await tester.enterText(sheetInputs.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post username is geoff
    expect(find.text('geoff'), findsOneWidget);
    expect(find.text('Hello from Geoff!'), findsOneWidget);
  });
}
