import 'package:flutter/material.dart';
import 'app_palette.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: palette.primary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: palette.primary),
            SizedBox(height: 4),
            Text(
              'About App',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: palette.primary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.cardFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'The Student Income and Expense Tracker is an intelligent and user-friendly '
              'financial management tool designed specifically to support students in developing '
              'better money habits. The app makes it easy to record income and expenses, organize '
              'spending into categories, and monitor budgets in real time. With clear visual reports, '
              'such as charts and graphs, students can quickly understand where their money goes and '
              'identify areas where they may need to adjust their spending.',
              style:
                  TextStyle(fontSize: 14, color: palette.primary, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
