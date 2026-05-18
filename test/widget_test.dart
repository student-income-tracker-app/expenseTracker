import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD
import 'package:flutter_firebase_app_2/AIChatbot.dart';
import 'package:flutter_firebase_app_2/AddIncome.dart';
import 'package:flutter_firebase_app_2/AddExpense.dart';
import 'package:flutter_firebase_app_2/DetailedStatement.dart';
import 'package:flutter_firebase_app_2/Home.dart';
import 'package:flutter_firebase_app_2/Recommendation.dart';
import 'package:flutter_firebase_app_2/Account.dart';

void main() {
  Future<void> pumpTestHome(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomePage(
            testBudgets: {
              'Food': 10,
              'Shopping': 20,
              'Transport': 30,
            },
          ),
        ),
      ),
    );
  }

  testWidgets('Add income requires an amount when Add is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddIncomePage()));

    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

  testWidgets('Add income rejects zero amount', (WidgetTester tester) async {
=======
import 'package:flutter_firebase_app_2/AddIncome.dart';
import 'package:flutter_firebase_app_2/AddExpense.dart';
import 'package:flutter_firebase_app_2/DetailedStatement.dart';

void main() {
  testWidgets('Add income validates amount', (WidgetTester tester) async {
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
    await tester.pumpWidget(const MaterialApp(home: AddIncomePage()));

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

<<<<<<< HEAD
  testWidgets('Add income accepts valid amount format',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddIncomePage()));

    await tester.enterText(find.byType(TextField).first, '10');
    await tester.pump();

    expect(find.text('Please enter a valid amount'), findsNothing);
    expect(find.text('Amount cannot start with leading zeros'), findsNothing);
  });

  testWidgets('Add income rejects leading zero amount',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddIncomePage()));

    await tester.enterText(find.byType(TextField).first, '01');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Amount cannot start with leading zeros'), findsOneWidget);
  });

  test('Payment balance is zero when income is deleted', () {
    final balance = calculatePaymentBalance(0, 25);

    expect(balance, 0);
  });

  test('Total budget sums allocated category budgets', () {
    final total = totalBudgetFromUserData({
      'budgets': {'Food': 50, 'Transport': 30, 'Empty': 0},
    });

    expect(total, 80);
  });

  test('Net worth and savings equal income minus expenses', () {
    final balance = calculatePaymentBalance(190, 20);

    expect(balance, 170);
  });

  test('Total budget reflects current category balances after spending', () {
    final beforeSpend = totalBudgetFromUserData({
      'budgets': {'Food': 20, 'Shopping': 20, 'Gym': 30},
    });
    final afterSpend = totalBudgetFromUserData({
      'budgets': {'Food': 10, 'Shopping': 10, 'Gym': 30},
    });

    expect(beforeSpend, 70);
    expect(afterSpend, 50);
  });

  test('Expenses include all recorded transactions', () {
    final total = totalExpenseFromUserData({
      'budgets': {'Food': 20},
      'expenses': {
        'e1': {'category': 'Food', 'amount': 10},
        'e2': {'category': 'Shopping', 'amount': 49},
      },
    });

    expect(total, 59);
  });

  test('Savings is zero when no income and no budgets despite stale netWorth',
      () {
    expect(
      totalAvailableFromUserData({
        'account': {'netWorth': 10},
        'incomes': {},
        'budgets': {},
      }),
      0,
    );
  });

  test('Savings equals income when no active budget despite stale netWorth',
      () {
    expect(
      totalAvailableFromUserData({
        'account': {'netWorth': 40},
        'incomes': {'i1': {'source': 'Salary', 'amount': 30}},
        'budgets': {},
        'expenses': {'e1': {'category': 'Food', 'amount': 40}},
      }),
      30,
    );
  });

  test('Old expenses do not reduce savings when no category budget remains',
      () {
    final userData = {
      'account': {'netWorth': 50},
      'incomes': {
        'i1': {'source': 'Salary', 'amount': 50},
      },
      'budgets': {},
      'expenses': {
        'e1': {'category': 'Food', 'amount': 20},
      },
    };

    expect(totalExpenseFromUserData(userData), 20);
    expect(totalAvailableFromUserData(userData), 50);
  });

  test('Budget allocation does not reduce total available', () {
    expect(
      totalAvailableFromUserData({
        'account': {'netWorth': 40},
        'incomes': {'i1': {'source': 'Salary', 'amount': 90}},
        'budgets': {'Food': 50},
        'expenses': {},
      }),
      90,
    );
  });

  test('Category delete refunds only remaining budget not spent amount', () {
    const remainingBudget = 30.0;
    const netWorthBeforeDelete = 40.0;

    final netWorthAfterDelete = netWorthBeforeDelete + remainingBudget;

    expect(netWorthAfterDelete, 70);
    expect(
      totalAvailableFromUserData({
        'account': {'netWorth': netWorthAfterDelete},
        'incomes': {'i1': {'source': 'Salary', 'amount': 90}},
        'budgets': {},
        'expenses': {'e1': {'category': 'Food', 'amount': 20}},
      }),
      90,
    );
  });

  test('Allocating budget does not deduct old expense history', () {
    expect(
      totalAvailableFromUserData({
        'account': {'netWorth': 90},
        'incomes': {'i1': {'source': 'Salary', 'amount': 100}},
        'budgets': {'Food': 10},
        'expenses': {
          'e1': {'category': 'Food', 'amount': 20},
          'e2': {'category': 'Food', 'amount': 10},
          'e3': {'category': 'Shopping', 'amount': 10},
        },
      }),
      100,
    );
  });

  test('Spending reduces savings via lower category budget', () {
    expect(
      totalAvailableFromUserData({
        'account': {'netWorth': 90},
        'incomes': {'i1': {'source': 'Salary', 'amount': 100}},
        'budgets': {'Food': 0},
        'expenses': {
          'e1': {'category': 'Food', 'amount': 10},
        },
      }),
      90,
    );
  });

  testWidgets('Add expense rejects zero amount', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AddExpensePage(initialCategory: 'Food')),
    );
=======
  testWidgets('Add expense validates amount', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpensePage(initialCategory: 'Food')));
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

<<<<<<< HEAD
  testWidgets('Add expense rejects leading zero amount',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AddExpensePage(initialCategory: 'Food')),
    );

    await tester.enterText(find.byType(TextField).first, '01');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Amount cannot start with leading zeros'), findsOneWidget);
  });

  test('Add expense blocks deduction when income is zero', () {
    final totalIncome = totalIncomeFromUserData({
      'incomes': {
        'income1': {'source': 'Salary', 'amount': 0},
      },
    });

    expect(totalIncome, 0);
  });

  testWidgets('Update expense validates budget amount',
      (WidgetTester tester) async {
=======
  testWidgets('Update expense validates budget', (WidgetTester tester) async {
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
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

<<<<<<< HEAD
    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

  testWidgets('Search transactions: press Search without input',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(find.text('No transactions found.'), findsOneWidget);
  });

  testWidgets('Search transactions: do not perform search',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    expect(find.text('Choose a date range and tap Search.'), findsOneWidget);
    expect(find.text('No transactions found.'), findsNothing);
  });

  testWidgets('Search transactions: enter dates and press search',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    await tester.tap(find.text('Date from'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Date to'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
=======
    expect(find.text('Please enter valid data'), findsOneWidget);
  });

  testWidgets('Detailed statement search shows results only after search', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    expect(find.text('Choose a date range and tap Search.'), findsOneWidget);
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(find.text('No transactions found.'), findsOneWidget);
  });
<<<<<<< HEAD

  testWidgets('Search transactions: sort by latest',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    await tester.tap(find.text('Search'));
    await tester.pump();
    await tester.tap(find.text('Newest'));
    await tester.pump();

    expect(find.text('Newest'), findsOneWidget);
  });

  testWidgets('Search transactions: sort by oldest',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetailedStatementPage()));

    await tester.tap(find.text('Search'));
    await tester.pump();
    await tester.tap(find.text('Oldest'));
    await tester.pump();

    expect(find.text('Oldest'), findsOneWidget);
  });

  testWidgets('Category suggestions in Home: open Home page',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('Category suggestions in Home: type "f"',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.enterText(find.byType(TextField).first, 'f');
    await tester.pump();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Shopping'), findsNothing);
  });

  testWidgets('Category suggestions in Home: type partial text "tr"',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.enterText(find.byType(TextField).first, 'tr');
    await tester.pump();

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('Category suggestions in Home: type full category name',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.enterText(find.byType(TextField).first, 'Transport');
    await tester.pump();

    expect(find.text('Transport'), findsWidgets);
    expect(find.text('Food'), findsNothing);
    expect(find.text('Shopping'), findsNothing);
  });

  testWidgets('Category suggestions in Home: enter invalid text',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.enterText(find.byType(TextField).first, 'xyz');
    await tester.pump();

    expect(find.text('Not found'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
    expect(find.text('Transport'), findsNothing);
  });

  testWidgets('Delete expenses / income: press delete icon',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(find.text('Do you actually want to delete it?'), findsOneWidget);
  });

  testWidgets('Delete expenses / income: click "Cancel"',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Do you actually want to delete it?'), findsNothing);
    expect(find.text('Allowance'), findsOneWidget);
  });

  testWidgets('Delete expenses / income: press delete icon again',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(find.text('Do you actually want to delete it?'), findsOneWidget);
  });

  testWidgets('Delete expenses / income: click "Yes"',
      (WidgetTester tester) async {
    await pumpTestHome(tester);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('Do you actually want to delete it?'), findsNothing);
    expect(find.text('Allowance'), findsNothing);
  });

  test('Contextual reminders: add expenses amount', () {
    final remainingBudget = calculateRemainingBudget(100, 25);

    expect(remainingBudget, 75);
  });

  test('Contextual reminders: deduct 90% of amount', () {
    final remainingBudget = calculateRemainingBudget(100, 90);

    expect(
        shouldShowBudgetCloseReminder(
          originalBudget: 100,
          remainingBudget: remainingBudget,
        ),
        isTrue);
  });

  testWidgets('Prediction appears separately with category name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RecommendationPage(
          message: 'Your food spending is the highest this month.',
          predictionCategory: 'Food',
        ),
      ),
    );

    expect(find.text('Recommendation'), findsOneWidget);
    expect(find.text('Prediction'), findsOneWidget);
    expect(
      find.text(
        'The predicted highest Expense for next month is expected to be Food.',
      ),
      findsOneWidget,
    );
    expect(find.text('compared to this month'), findsNothing);
  });

  testWidgets('Prediction hides category name for new user',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RecommendationPage(
          message: 'No spending data yet.',
          predictionCategory: '',
        ),
      ),
    );

    expect(find.text('Prediction'), findsOneWidget);
    expect(find.text('No spending category yet.'), findsOneWidget);
    expect(find.text('Category:'), findsNothing);
  });

  testWidgets('AI chatbot answers ready expense question',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AIChatbotPage()));

    await tester.tap(find.text('How do I add an expense?'));
    await tester.pump();

    expect(find.text('Open dashboard and click Add Expense.'), findsOneWidget);
  });
=======
>>>>>>> 871b46f34f1a7a0221a9e584e9289562bdeac8b0
}
