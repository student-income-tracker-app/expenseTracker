import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';

class AIChatbotPage extends StatelessWidget {
  const AIChatbotPage({super.key});

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
              'AI Chatbot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: palette.primary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.bubbleFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ChatBubble(
                        text: 'Hey 👋 how can I help you',
                        isUser: false,
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: _ChatBubble(
                          text: 'How to add income',
                          isUser: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _ChatBubble(
                        text:
                            'First u need to add amount in payment card then go to home click add income and add your income source name and amount.',
                        isUser: false,
                      ),
                    ],
                  ),
                ),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9\s\.\,\!\?\-]'),
                          ),
                        ],
                        style: TextStyle(color: palette.primary),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: palette.primary.withOpacity(0.6)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.send, color: palette.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

