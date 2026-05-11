import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_app_2/AddIncome.dart';
import 'package:flutter_firebase_app_2/AddExpense.dart';
import 'package:flutter_firebase_app_2/DetailedStatement.dart';

void main() {
  testWidgets('Add income validates amount', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddIncomePage()));

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

  testWidgets('Add expense validates amount', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpensePage(initialCategory: 'Food')));

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

  testWidgets('Update expense validates budget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddExpensePage(
          editBudget: true,
          initialCategory: 'Food',
          initialBudget: 10,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).last, '0');
    await tester.tap(find.text('Update'));
    await tester.pump();

    expect(find.text('Please enter valid data'), findsOneWidget);
  });

  testWidgets('Detailed statement search shows results only after search', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    expect(find.text('Choose a date range and tap Search.'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(find.text('No transactions found.'), findsOneWidget);
  });
}
