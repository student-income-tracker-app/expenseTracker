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
            Icon(Icons.account_balance_wallet_outlined,
                color: palette.primary),
            SizedBox(height: 4),
            Text(
              'About App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: palette.primary,
              ),
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
              "Expense Tracker is a smart and user-friendly financial management app designed especially for students. "
                  "It helps users easily record their income and expenses, organize spending into categories, "
                  "and track their budgets in real time.\n\n"
                  "The app also provides clear visual insights, such as charts and summaries, "
                  "to help users understand their spending habits and make better financial decisions.\n\n"
                  "By using this app, students can build strong money management skills and stay in control of their finances.",
              style: TextStyle(
                fontSize: 14,
                color: palette.primary,
                height: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
