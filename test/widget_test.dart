// Widget smoke tests for FitTrack.
//
// IMPORTANT: never call `tester.pumpAndSettle()` here. MealLogScreen runs a
// looping FAB pulse (`repeat(reverse: true)`) and every screen lives inside
// an IndexedStack, so at least one animation is always in flight and
// pumpAndSettle would spin until it times out. Pump explicit durations
// instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitness_tracker/main.dart';
import 'package:fitness_tracker/providers/fitness_provider.dart';
import 'package:fitness_tracker/widgets/custom_bottom_nav.dart';

/// Pumps the app on a tall surface — the default 800x600 test window leaves
/// most of each screen unbuilt (the lists are lazy), which makes taps on
/// lower content fail — then lets the staggered reveal animations finish.
Future<void> _bootApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const FitnessApp());
  await tester.pump(const Duration(milliseconds: 800));
}

FitnessProvider _providerOf(WidgetTester tester) {
  final context = tester.element(find.byType(CustomBottomNav));
  return Provider.of<FitnessProvider>(context, listen: false);
}

void main() {
  testWidgets('boots to the dashboard without exceptions', (tester) async {
    await _bootApp(tester);

    expect(tester.takeException(), isNull);
    // Greeting name and the weekly summary card are unique to the dashboard.
    expect(find.text('ZIA'), findsOneWidget);
    expect(find.text('WEEKLY SUMMARY'), findsOneWidget);
  });

  testWidgets('shows the five bottom-nav destinations', (tester) async {
    await _bootApp(tester);

    for (final label in ['Home', 'Workout', 'Meals', 'Progress', 'Goals']) {
      expect(find.text(label), findsOneWidget, reason: '$label tab missing');
    }
  });

  testWidgets('tapping a nav item changes the selected tab', (tester) async {
    await _bootApp(tester);
    final provider = _providerOf(tester);

    expect(provider.selectedIndex, 0);

    await tester.tap(find.text('Goals'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(provider.selectedIndex, 4);

    await tester.tap(find.text('Workout'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(provider.selectedIndex, 1);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the Goals tab renders without the border assertion',
      (tester) async {
    // Regression: the overall-progress header used a non-uniform Border
    // together with a borderRadius, which throws at paint time.
    await _bootApp(tester);

    _providerOf(tester).setIndex(4);
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.takeException(), isNull);
    expect(find.text('OVERALL PROGRESS'), findsOneWidget);
    expect(find.text('ACTIVE GOALS'), findsOneWidget);
  });

  testWidgets('every tab renders without throwing', (tester) async {
    await _bootApp(tester);
    final provider = _providerOf(tester);

    for (var index = 0; index < 5; index++) {
      provider.setIndex(index);
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull, reason: 'tab $index threw');
    }
  });

  testWidgets('START WORKOUT moves the user to the workout tab',
      (tester) async {
    await _bootApp(tester);
    final provider = _providerOf(tester);

    await tester.tap(find.text('START WORKOUT'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(provider.selectedIndex, 1);
  });

  testWidgets('adding a goal through the sheet updates the list',
      (tester) async {
    await _bootApp(tester);
    final provider = _providerOf(tester);

    provider.setIndex(4);
    await tester.pump(const Duration(milliseconds: 600));

    final before = provider.goals.length;

    await tester.tap(find.text('ADD GOAL'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(
        find.widgetWithText(TextField, 'Goal Title'), 'Sleep');
    await tester.enterText(
        find.widgetWithText(TextField, 'Current Value'), '6');
    await tester.enterText(
        find.widgetWithText(TextField, 'Target Value'), '8');

    // The page's button is an OutlinedButton; the sheet's submit is an
    // ElevatedButton — that distinguishes the two identical labels.
    await tester.tap(find.widgetWithText(ElevatedButton, 'ADD GOAL'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(provider.goals.length, before + 1);
    expect(provider.goals.last.title, 'Sleep');
  });

  testWidgets('a goal with a blank title is rejected with an error',
      (tester) async {
    await _bootApp(tester);
    final provider = _providerOf(tester);

    provider.setIndex(4);
    await tester.pump(const Duration(milliseconds: 600));

    final before = provider.goals.length;

    await tester.tap(find.text('ADD GOAL'));
    await tester.pump(const Duration(milliseconds: 500));

    // Submit with everything empty.
    await tester.tap(find.widgetWithText(ElevatedButton, 'ADD GOAL'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(provider.goals.length, before, reason: 'nothing should be added');
    expect(find.text('Enter a goal title'), findsOneWidget);
  });
}
