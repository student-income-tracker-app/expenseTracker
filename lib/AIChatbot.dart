import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hello! Choose a ready question or ask me about expenses, income, budget, reports, login, features, and financial advice.',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _sendUserText(text);
    _messageController.clear();
  }

  void _sendUserText(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: _buildBotReply(text), isUser: false));
    });
  }

  String _buildBotReply(String input) {
    final q = _normalizeQuestion(input);

    for (final section in _faqSections) {
      for (final item in section.items) {
        if (_normalizeQuestion(item.question) == q) {
          return item.answer;
        }
      }
    }

    if (q.contains('income') || q.contains('دخل')) {
      return 'Open dashboard and click Add Income.';
    }

    if (q.contains('budget') || q.contains('ميزانية')) {
      return 'Go to budget section and enter amount.';
    }

    if (q.contains('expense') || q.contains('مصروف')) {
      return 'Open dashboard and click Add Expense.';
    }

    if (q.contains('search') || q.contains('بحث')) {
      return 'Yes, using the search feature.';
    }

    if (q.contains('report') ||
        q.contains('statement') ||
        q.contains('تقرير')) {
      return 'Open the report page.';
    }

    if (q.contains('chart') ||
        q.contains('recommend') ||
        q.contains('prediction') ||
        q.contains('توصية')) {
      return 'Income, expenses, and savings analysis.';
    }

    if (q.contains('hello') ||
        q.contains('hi') ||
        q.contains('مرحبا') ||
        q.contains('السلام')) {
      return 'Hi! Choose a ready question or ask about this finance app.';
    }

    return 'I can answer questions about expenses, income, budget, reports, login, features, and financial advice.';
  }

  String _normalizeQuestion(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _showReadyQuestions() {
    final palette = AppPalette.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Ready Questions',
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final section in _faqSections)
                        ExpansionTile(
                          title: Text(
                            section.title,
                            style: TextStyle(
                              color: palette.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          iconColor: palette.primary,
                          collapsedIconColor: palette.primary,
                          children: [
                            for (final item in section.items)
                              ListTile(
                                title: Text(
                                  item.question,
                                  style: TextStyle(color: palette.primary),
                                ),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  _sendUserText(item.question);
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            const SizedBox(height: 4),
            Text(
              'Chatbot',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: palette.primary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.bubbleFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListView.separated(
                    itemCount: _messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _ChatBubble(
                          text: message.text,
                          isUser: message.isUser,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _readyQuestionsChip(),
                  _quickQuestionChip('How do I add an expense?'),
                  _quickQuestionChip('How do I add income?'),
                  _quickQuestionChip('How do I create a budget?'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: palette.inputFill,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9\u0600-\u06FF\s\.\,\!\?\-]'),
                          ),
                        ],
                        style: TextStyle(color: palette.primary),
                        decoration: InputDecoration(
                          hintText: 'Ask about this app',
                          hintStyle: TextStyle(
                              color: palette.primary.withOpacity(0.6)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send, color: palette.primary),
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

  Widget _quickQuestionChip(String text) {
    final palette = AppPalette.of(context);
    return ActionChip(
      label: Text(
        text,
        style: TextStyle(color: palette.primary, fontSize: 12),
      ),
      backgroundColor: palette.inputFill,
      side: BorderSide(color: palette.cardBorder),
      onPressed: () => _sendUserText(text),
    );
  }

  Widget _readyQuestionsChip() {
    final palette = AppPalette.of(context);
    return ActionChip(
      avatar: Icon(Icons.list_alt, color: palette.primary, size: 18),
      label: Text(
        'Ready questions',
        style: TextStyle(color: palette.primary, fontSize: 12),
      ),
      backgroundColor: palette.inputFill,
      side: BorderSide(color: palette.cardBorder),
      onPressed: _showReadyQuestions,
    );
  }
}

const List<_FaqSection> _faqSections = [
  _FaqSection(
    title: 'Questions About Expenses',
    items: [
      _FaqItem(
          'How do I add an expense?', 'Open dashboard and click Add Expense.'),
      _FaqItem(
          'How can I delete an expense?', 'Press the delete icon and confirm.'),
      _FaqItem('How do I update an expense?',
          'Select the expense and edit the details.'),
      _FaqItem('How can I track my spending?',
          'Use reports and charts in the dashboard.'),
      _FaqItem('Where can I see my expenses?',
          'In the report and dashboard sections.'),
      _FaqItem('How do I categorize expenses?',
          'Select a category when adding expense.'),
      _FaqItem(
          'What category should I use for food?', 'Use the Food category.'),
      _FaqItem('How can I reduce my expenses?', 'Reduce unnecessary spending.'),
      _FaqItem('Why are my expenses too high?',
          'Because spending exceeds your budget.'),
      _FaqItem(
          'How do I stop overspending?', 'Follow your budget plan carefully.'),
    ],
  ),
  _FaqSection(
    title: 'Questions About Income',
    items: [
      _FaqItem('How do I add income?', 'Open dashboard and click Add Income.'),
      _FaqItem(
          'How can I update income?', 'Select income and edit the amount.'),
      _FaqItem('How do I delete income?', 'Press delete and confirm removal.'),
      _FaqItem(
          'Where can I see my income?', 'In reports and dashboard summary.'),
      _FaqItem('How is total income calculated?',
          'By adding all income entries together.'),
    ],
  ),
  _FaqSection(
    title: 'Questions About Budget',
    items: [
      _FaqItem('How do I create a budget?',
          'Go to budget section and enter amount.'),
      _FaqItem('How can I manage my budget?', 'Monitor expenses regularly.'),
      _FaqItem('What is a budget?', 'A plan for controlling spending.'),
      _FaqItem('Why is budgeting important?', 'It helps avoid overspending.'),
      _FaqItem(
          'How do I avoid exceeding my budget?', 'Spend within the set limit.'),
      _FaqItem('Why did I receive a budget warning?',
          'Because spending is near the limit.'),
      _FaqItem(
          'How can I save money as a student?', 'Reduce unnecessary expenses.'),
      _FaqItem('What happens when my budget reaches 90%?',
          'The app sends a warning notification.'),
    ],
  ),
  _FaqSection(
    title: 'Questions About Reports & Charts',
    items: [
      _FaqItem('How do I view reports?', 'Open the report page.'),
      _FaqItem('Where can I see charts?', 'In the dashboard chart section.'),
      _FaqItem('What do the charts show?',
          'Income, expenses, and savings analysis.'),
      _FaqItem(
          'How can charts help me?', 'They help visualize spending habits.'),
      _FaqItem('How do I analyze my spending?',
          'Review reports and charts regularly.'),
    ],
  ),
  _FaqSection(
    title: 'Questions About Login & Security',
    items: [
      _FaqItem(
          'How do I create an account?', 'Click Sign Up and enter details.'),
      _FaqItem('How do I log in?', 'Enter email and password.'),
      _FaqItem('I forgot my password.', 'Use the Forgot Password option.'),
      _FaqItem('How do I reset my password?',
          'Verify OTP and create a new password.'),
      _FaqItem(
          'What is OTP verification?', 'A security code for verification.'),
      _FaqItem('Is my data secure?', 'Yes, data is protected securely.'),
      _FaqItem('How does Firebase authentication work?',
          'It verifies users securely using Firebase.'),
    ],
  ),
  _FaqSection(
    title: 'Questions About Features',
    items: [
      _FaqItem('What can this app do?',
          'Track income, expenses, budgets, and reports.'),
      _FaqItem('What is the purpose of this application?',
          'To help students manage finances.'),
      _FaqItem('What are the main features?',
          'Budgeting, reports, charts, notifications, and chatbot.'),
      _FaqItem(
          'Does the app support dark mode?', 'Yes, users can switch themes.'),
      _FaqItem('Can I search transactions?', 'Yes, using the search feature.'),
      _FaqItem('Can I filter records?', 'Yes, by category or date.'),
      _FaqItem('How do notifications work?',
          'They alert users about budgets and reminders.'),
      _FaqItem('What is the recommendation feature?',
          'It gives spending improvement suggestions.'),
      _FaqItem(
          'What is the AI chatbot?', 'A virtual assistant for user support.'),
    ],
  ),
  _FaqSection(
    title: 'Financial Advice Questions',
    items: [
      _FaqItem('How can I save more money?',
          'Reduce unnecessary spending and follow a budget.'),
      _FaqItem('How can students manage money better?',
          'By tracking income and expenses regularly.'),
      _FaqItem('What are smart spending habits?',
          'Spending on needs instead of wants.'),
      _FaqItem('Why should students track expenses?',
          'To avoid overspending and manage money wisely.'),
      _FaqItem('How do I control impulse buying?',
          'Plan purchases and stick to your budget.'),
      _FaqItem('Why is financial management important?',
          'It helps control spending and improve savings.'),
      _FaqItem('How can I improve financial discipline?',
          'Track spending and follow a monthly plan.'),
    ],
  ),
];

class _FaqSection {
  final String title;
  final List<_FaqItem> items;

  const _FaqSection({required this.title, required this.items});
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem(this.question, this.answer);
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUser ? palette.inputFill : palette.bubbleFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Text(
        text,
        style: TextStyle(color: palette.primary),
      ),
    );
  }
}
